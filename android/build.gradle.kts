<<<<<<< HEAD
import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

// Flutter & Android Gradle 8 compatible root build file

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // Keep mavenLocal if you truly need it, else remove to avoid stale artifacts
        mavenLocal()
        // Local engine path is optional; leave only if you use a custom local engine
        // maven { url = uri("C:/flutter/bin/cache/artifacts/engine") }

        // Required to fetch Flutter embedding/engine artifacts
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
=======
import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

// Flutter & Android Gradle 8 compatible root build file

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // Keep mavenLocal if you truly need it, else remove to avoid stale artifacts
        mavenLocal()
        // Local engine path is optional; leave only if you use a custom local engine
        // maven { url = uri("C:/flutter/bin/cache/artifacts/engine") }

        // Required to fetch Flutter embedding/engine artifacts
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
>>>>>>> b04c7a0090379fb6c22faabf0a565f64e84d2966
}