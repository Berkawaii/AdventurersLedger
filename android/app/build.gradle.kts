plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    // Temporarily removed App Distribution for development
    // id("com.google.firebase.appdistribution")
}

android {
    namespace = "com.example.adventurers_ledger"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Firebase plugin'leriyle uyumlu NDK sürümü

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.adventurers_ledger"
        minSdk = 23 // Firebase Auth için minimum SDK 23 olmalı
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signing with the debug keys for now
            signingConfig = signingConfigs.getByName("debug")
            
            // Disable minification to avoid R8 issues
            isMinifyEnabled = false
            isShrinkResources = false
            
            // Keep proguard rules for reference
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // Firebase App Distribution temporarily removed
            // firebaseAppDistribution {
            //     releaseNotes = "Firebase App Distribution ile test sürümü"
            //     groups = "testers"
            // }
        }
        debug {
            // Disable minification for debug builds too
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Add only OkHttp dependency
    implementation("com.squareup.okhttp:okhttp:2.7.5")
}

// App Distribution yapılandırmasını geçici olarak kaldırıldı
// apply(from = "firebase-appdistribution.gradle")
