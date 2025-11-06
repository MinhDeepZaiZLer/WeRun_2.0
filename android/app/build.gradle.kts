plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.dacs4_werun_2_0"
    compileSdk = flutter.compileSdkVersion

    // XÓA DÒNG NÀY: ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.dacs4_werun_2_0"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // CHỈ GIỮ LẠI 1 DÒNG NÀY
    ndkVersion = "27.0.12077973"

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    buildTypes.each {
        it.resValue "string", "mapbox_access_token", (project.properties['MAPBOX_PUBLIC_TOKEN'] ?: "")
    }
}

flutter {
    source = "../.."
}