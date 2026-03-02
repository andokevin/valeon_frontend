plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.app.valeon"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.app.valeon"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            storeFile = file("../keystore/votre-cle-release.jks")
            storePassword = "valeon"
            keyAlias = "votre_alias"
            keyPassword = "valeon"
        }
        // Supprimez ou modifiez cette section - elle n'existe pas par défaut
        // create("debug") {
        //     // Soit vous la supprimez, soit vous la configurez correctement
        // }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
        }
        
        debug {
            // Pour debug, utilisez la configuration de signature de debug par défaut
            // ou commentez cette ligne si vous voulez utiliser la signature automatique
            // signingConfig = signingConfigs.getByName("debug")
            // Version correcte :
            signingConfig = signingConfigs.getByName("debug") // À supprimer si pas configuré
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    
    // Firebase avec BoM compatible
    implementation(platform("com.google.firebase:firebase-bom:33.10.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    
    // Facebook SDK
    implementation("com.facebook.android:facebook-android-sdk:17.0.2")
    
    // MultiDex
    implementation("androidx.multidex:multidex:2.0.1")
}