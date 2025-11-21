plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase plugins
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

android {
    namespace = "com.awkati.taskflow"
    compileSdk = 36  // Updated to SDK 36 for plugin compatibility
    buildToolsVersion = "34.0.0"  // Use Linux-compatible build tools
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.awkati.taskflow"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 36  // Updated to SDK 36 for plugin compatibility
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    // Force compatible androidx.activity version for Gradle plugin 8.7.3
    constraints {
        implementation("androidx.activity:activity:1.9.3") {
            because("Version 1.11.0+ requires Gradle plugin 8.9.1")
        }
        implementation("androidx.activity:activity-ktx:1.9.3") {
            because("Version 1.11.0+ requires Gradle plugin 8.9.1")
        }
    }
}

flutter {
    source = "../.."
}
