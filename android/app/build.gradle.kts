import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// โหลด key.properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {

    namespace = "com.cat_is_pink.attendance_system"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.cat_is_pink.attendance_system"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 🚩 (2026-08-31) เดิมสร้าง signingConfig นี้โดยไม่เช็คว่ามี key.properties จริงมั้ย
    // ทั้งที่ตอนโหลดด้านบนเช็คอยู่ — `keystoreProperties["storeFile"]` เลยเป็น null
    // แล้ว `as String` ล้มด้วย "null cannot be cast to non-null type kotlin.String"
    // บล็อกนี้ถูกประเมินตอน configure จึงพังทั้ง debug และ release ไม่ใช่แค่ release
    // → เครื่องที่ไม่มี keystore (ซึ่ง gitignore ไว้) build Android ไม่ได้เลยสักโหมด
    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // ไม่มี keystore ก็ยัง build release ได้ แต่เซ็นด้วย debug key
            // (ตัวที่เอาขึ้น store จริงต้องมี key.properties เสมอ)
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
