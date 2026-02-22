plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.app.valeon"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // ✅ Correction : utiliser = true avec le préfixe "is"
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // jvmTarget est déprécié mais fonctionne encore, on garde pour l'instant
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
    
    // Alternative moderne (si vous voulez migrer)
    // kotlin {
    //     compilerOptions {
    //         jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    //     }
    // }

    defaultConfig {
        applicationId = "com.app.valeon"
        minSdk = flutter.minSdkVersion  // ⚠️ Important : minimum 21 pour le desugaring
        targetSdk = 36
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
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")  // Version mise à jour

    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.12.0"))  // Dernière version stable

    // Firebase products
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-firestore") // Si besoin

    // Facebook SDK
    implementation("com.facebook.android:facebook-android-sdk:17.0.2")  // Dernière version stable
}