// android/build.gradle.kts (Project-level build.gradle.kts - corrected Kotlin DSL syntax)

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = file("../build")
subprojects {
    buildDir = file("${rootProject.buildDir}/${name}")
}
subprojects {
    evaluationDependsOn(":app")
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}