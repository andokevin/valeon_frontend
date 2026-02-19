// android/build.gradle
plugins {
    // Plugin Google Services pour Firebase
    id("com.google.gms.google-services") version "4.4.4" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Configuration du répertoire de build (version simplifiée)
rootProject.buildDir = "../build"
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}

// Assure l'ordre d'évaluation
subprojects {
    project.evaluationDependsOn(":app")
}

// Tâche de nettoyage
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}