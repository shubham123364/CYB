FROM eclipse-temurin:11-jre

WORKDIR /app

COPY target/java-app.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
