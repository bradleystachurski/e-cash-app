allprojects {
    repositories {
        google()
        mavenCentral()
    }
    
    // Apply byte-buddy version constraint to all modules to fix Java 24 bytecode issue
    configurations.all {
        resolutionStrategy {
            force("net.bytebuddy:byte-buddy:1.14.18")
            force("net.bytebuddy:byte-buddy-agent:1.14.18")
        }
    }
}

// Custom build directory causes Flutter to not find APK
// val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
// rootProject.layout.buildDirectory.value(newBuildDir)

// subprojects {
//     val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
//     project.layout.buildDirectory.value(newSubprojectBuildDir)
// }
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
