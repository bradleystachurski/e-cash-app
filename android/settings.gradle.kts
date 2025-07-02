pluginManagement {
    val flutterToolsGradleDir = System.getenv("FLUTTER_TOOLS_GRADLE_DIR")
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    // Use writable Flutter tools gradle directory if available, otherwise fall back to read-only
    val gradleDir = if (flutterToolsGradleDir != null && file(flutterToolsGradleDir).exists()) {
        flutterToolsGradleDir
    } else {
        "$flutterSdkPath/packages/flutter_tools/gradle"
    }
    
    includeBuild(gradleDir)

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.2.1" apply false
    id("org.jetbrains.kotlin.android") version "1.9.20" apply false
}

include(":app")
