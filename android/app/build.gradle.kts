plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val uploadStoreFile =
    (project.findProperty("MYAPP_UPLOAD_STORE_FILE") as String?)
        ?.takeIf { it.isNotBlank() }
        ?.let { rootProject.file(it) }

android {
    namespace = "com.example.attendance_client"
     compileSdk = flutter.compileSdkVersion
     ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.apnitor.massivedynamic"
        // applicationId = "com.apnitor.massivedynamictest"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = project.findProperty("MYAPP_UPLOAD_KEY_ALIAS") as String?
            keyPassword = project.findProperty("MYAPP_UPLOAD_KEY_PASSWORD") as String?
            storeFile = uploadStoreFile
            storePassword = project.findProperty("MYAPP_UPLOAD_STORE_PASSWORD") as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
