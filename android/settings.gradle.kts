import java.io.File
import java.io.FileInputStream
import java.util.Properties
import org.gradle.authentication.http.BasicAuthentication
import org.gradle.api.artifacts.repositories.AuthenticationSupported

pluginManagement {
  val flutterSdkPath = run {
    val properties = java.util.Properties() // <-- SỬA 1: Dùng tên đầy đủ
    java.io.File(rootDir, "local.properties").inputStream().use { properties.load(it) } // <-- SỬA 2: Dùng tên đầy đủ
    val flutterSdkPath = properties.getProperty("flutter.sdk")
    require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
    flutterSdkPath
  }
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    id("com.google.gms.google-services") version "4.3.15" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

// ĐỌC LOCAL.PROPERTIES
val localProperties = Properties()
val localPropertiesFile = File(rootDir, "local.properties")
if (localPropertiesFile.exists()) {
    FileInputStream(localPropertiesFile).use { localProperties.load(it) }
}

val mapboxToken = localProperties.getProperty("MAPBOX_DOWNLOADS_TOKEN") ?: ""

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()

       
    }
}

include(":app")
