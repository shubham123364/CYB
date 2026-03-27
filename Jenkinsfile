pipeline {
    agent any

    environment {
        APP_NAME = 'java-app'
        IMAGE_NAME = 'shubhamx0/java-app:latest'
        SONARQUBE_SERVER = 'SonarQube'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Application - Java 17') {
            steps {
                sh '''
                    docker exec java17-builder bash -c "
                      cd /workspace &&
                      mvn clean package -DskipTests
                    "
                '''
            }
        }

        stage('Run Unit Tests - Java 11') {
            steps {
                sh '''
                    docker exec java11-tester bash -c "
                      cd /workspace &&
                      mvn test
                    "
                '''
            }
        }

        stage('Static Code Analysis - SonarQube') {
            steps {
                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                        sh '''
                            docker exec java11-analyzer bash -c "
                              cd /workspace &&
                              mvn sonar:sonar \
                                -Dsonar.projectKey=java-app \
                                -Dsonar.host.url=http://sonarqube:9000 \
                                -Dsonar.login=$SONAR_TOKEN
                            "
                        '''
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t $IMAGE_NAME -f Dockerfile.app .
                '''
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $IMAGE_NAME
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    kubectl apply -f k8s/deployment.yaml
                    kubectl rollout restart deployment/java-app
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Check console output.'
        }
    }
}
