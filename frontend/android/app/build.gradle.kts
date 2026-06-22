plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    // ADD THIS FOR FIREBASE (if using Google Services)
    // id("com.google.gms.google-services") // Uncomment this if you use Google Services
}

android {
    namespace = "com.example.smartai"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.smartai"
        minSdk = flutter.minSdkVersion  // ← CHANGE: Firebase requires minSdk >= 21
        targetSdk = 34  // ← CHANGE: Use specific version
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true  // ← ADD THIS: Required for Firebase
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// ADD THIS FOR FIREBASE (at the bottom)
dependencies {
    // Firebase BoM (Bill of Materials)
    implementation(platform("com.google.firebase:firebase-bom:34.15.0"))
    
    // Firebase Auth
    implementation("com.google.firebase:firebase-auth")
    
    // Firebase Firestore
    implementation("com.google.firebase:firebase-firestore")
    
    // Firebase Storage
    implementation("com.google.firebase:firebase-storage")
    
    // Google Sign-In
    implementation("com.google.android.gms:play-services-auth:21.3.0")
    
    // MultiDex support
    implementation("androidx.multidex:multidex:2.0.1")
}
