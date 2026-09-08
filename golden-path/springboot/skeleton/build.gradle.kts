plugins {
    java
    id("org.springframework.boot") version "${{ values.springBootVersion }}"
    id("io.spring.dependency-management") version "1.1.6"
    id("com.diffplug.spotless") version "6.25.0"
    id("org.sonarqube") version "6.0.1.5171"
}

group = "${{ values.groupId }}"
version = "0.0.1-SNAPSHOT"

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(${{ values.javaVersion }})
    }
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:2.7.0")

    testImplementation("org.springframework.boot:spring-boot-starter-test")
}

tasks.withType<Test> {
    useJUnitPlatform()
}

tasks.register<Test>("integrationTest") {
    description = "Runs integration tests against a deployed environment"
    group = "verification"
    useJUnitPlatform()
    shouldRunAfter(tasks.test)
    systemProperty(
        "app.base-url",
        project.findProperty("app.base-url") ?: System.getenv("APP_BASE_URL") ?: "",
    )
}

spotless {
    java {
        googleJavaFormat()
    }
    kotlinGradle {
        ktlint()
    }
}

sonar {
    properties {
        property("sonar.projectKey", "${{ values.sonarProjectKey }}")
    }
}
