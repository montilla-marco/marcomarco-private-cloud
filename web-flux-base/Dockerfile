FROM eclipse-temurin:21

COPY build/libs/web-flux-base-0.1.0-SNAPSHOT.jar /opt/app/microservice.jar

ENTRYPOINT ["java", "-Xms256m", "-Xmx256m", "-Djava.util.concurrent.forkjoinpool.common.parallelism=4", "-jar", "/opt/app/microservice.jar"]