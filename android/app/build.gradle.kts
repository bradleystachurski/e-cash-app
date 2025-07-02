plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.carbine"
    compileSdk = if (project.hasProperty("flutter.compileSdkVersion")) {
        project.property("flutter.compileSdkVersion").toString().toInt()
    } else {
        35
    }
    
    configurations.all {
        exclude(group = "io.flutter", module = "x86_profile")
    }
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = "21"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.carbine"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = if (project.hasProperty("flutter.minSdkVersion")) {
            project.property("flutter.minSdkVersion").toString().toInt()
        } else {
            21
        }
        targetSdk = if (project.hasProperty("flutter.targetSdkVersion")) {
            project.property("flutter.targetSdkVersion").toString().toInt()
        } else {
            35
        }
        versionCode = if (project.hasProperty("flutter.versionCode")) {
            project.property("flutter.versionCode").toString().toInt()
        } else {
            1
        }
        versionName = if (project.hasProperty("flutter.versionName")) {
            project.property("flutter.versionName").toString()
        } else {
            "1.0"
        }
        
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
