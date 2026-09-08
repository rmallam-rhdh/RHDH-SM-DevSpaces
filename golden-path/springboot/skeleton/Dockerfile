# Multi-stage build — Gradle bootJar then UBI runtime (OpenShift non-root UID 185)
FROM registry.access.redhat.com/ubi9/openjdk-${{ values.javaVersion }}:latest AS build
WORKDIR /workspace
COPY gradlew settings.gradle.kts build.gradle.kts gradle.properties gradle/ ./
COPY src ./src
RUN chmod +x gradlew && ./gradlew bootJar --no-daemon -x test

FROM registry.access.redhat.com/ubi9/openjdk-${{ values.javaVersion }}-runtime:latest
WORKDIR /app
COPY --from=build /workspace/build/libs/*.jar /app/app.jar
USER 185
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
