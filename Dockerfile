FROM openjdk:alpine
WORKDIR /opt
COPY /target/*.jar /app.jar

EXPOSE 11130
ENTRYPOINT ["java", "-jar", "./app.jar"]

