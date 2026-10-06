plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin
}

android {
    namespace = "com.example.signbridge"  // Add this line

    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.signbridge"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}




flutter {
    source = "../.."
}

tasks.register("startBackendServer") {
    doFirst {
        println("🚀 Launching Python Backend Server...")
        try {
            val isWindows = System.getProperty("os.name").lowercase().contains("windows")
            if (isWindows) {
                ProcessBuilder("cmd", "/c", "start", "SignBridge AI Backend Server", "cmd", "/c", "cd /d ..\\..\\backend && python api_server.py")
                    .start()
            }
        } catch (e: Exception) {
            println("⚠️ Could not auto-start backend: ${e.message}")
        }
    }
}

tasks.named("preBuild") {
    dependsOn("startBackendServer")
}
