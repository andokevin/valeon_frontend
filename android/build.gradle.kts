allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}

// extract*Annotations (plugins) ne sert qu'à publier des AAR et télécharge ~50 Mo d'outils Lint
val extractAnnotationsTask = Regex("extract.*Annotations")
subprojects {
    tasks.matching { it.name.matches(extractAnnotationsTask) }.configureEach {
        enabled = false
    }
}
// Les tâches suivantes attendent typedefs.txt : on fournit une liste vide (valide)
gradle.taskGraph.whenReady {
    allTasks.filter { it.name.matches(extractAnnotationsTask) }.forEach { task ->
        task.outputs.files.filter { it.name.endsWith(".txt") && !it.exists() }.forEach { file ->
            file.parentFile.mkdirs()
            file.createNewFile()
        }
    }
}

// Correction importante : éviter l'erreur sur evaluationDependsOn
subprojects {
    afterEvaluate {
        if (project.path != ":app") {
            project.evaluationDependsOn(":app")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}