// android/app/build.gradle.kts (keep as is)

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // For Firebase integration
}

android {
    namespace = "com.example.dacs4_werun_2_0"  // Replace with your app's namespace
    compileSdk = 36  // Or the latest version
    ndkVersion = "28.1.13356709"  // Optional, adjust if needed for native libraries

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.dacs4_werun_2_0"  // Replace with your app ID
        minSdk = 23  // Minimum for MapLibre GL, adjust if higher is required
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true  // Enable if your app exceeds 64K methods (common with Firebase)
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for release builds
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    // Dependencies are managed via pubspec.yaml in Flutter, so no need to add here unless custom
}