allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // Redirect hanya untuk modul yang satu drive dengan project (:app).
    // Plugin dari Pub Cache (drive C:) memakai build folder bawaannya.
    val sameDrive = project.projectDir.toPath().root == rootProject.projectDir.toPath().root
    if (sameDrive) {
        project.layout.buildDirectory.value(newBuildDir.dir(project.name))
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}