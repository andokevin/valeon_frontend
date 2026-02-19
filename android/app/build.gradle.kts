plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.app.valeon"
    compileSdk = 34
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // ✅ Activation du desugaring pour flutter_local_notifications
        coreLibraryDesugaringEnabled true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.app.valeon"
        minSdk = 21  // ⚠️ Important : minimum 21 pour le desugaring
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Dépendance OBLIGATOIRE pour le desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.9.0"))

    // Firebase products
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth") // Si tu utilises Firebase Auth
    // implementation("com.google.firebase:firebase-firestore") // Si besoin

    // Facebook SDK - version stable recommandée
    implementation("com.facebook.android:facebook-android-sdk:17.0.0")
    // ⚠️ Évite "latest.release" en production, fixe une version
}