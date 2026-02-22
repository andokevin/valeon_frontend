// android/build.gradle.kts
plugins {
    // Plugin Google Services pour Firebase
    id("com.google.gms.google-services") version "4.4.2" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Configuration du répertoire de build (version corrigée)
rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}

// Assure l'ordre d'évaluation
subprojects {
    project.evaluationDependsOn(":app")
}

// Tâche de nettoyage
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}