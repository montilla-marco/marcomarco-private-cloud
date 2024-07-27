FROM eclipse-temurin:21

COPY build/libs/ms-hello-0.0.1-SNAPSHOT.jar /opt/app/microservice.jar

ENTRYPOINT ["java", "-Xms256m", "-Xmx256m", "-Djava.util.concurrent.forkjoinpool.common.parallelism=4", "-jar", "/opt/app/microservice.jar"]