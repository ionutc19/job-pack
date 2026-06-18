import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val keyProperties = Properties().apply {
    val keyPropertiesFile = rootProject.file("key.properties")
    if (keyPropertiesFile.exists()) {
        keyPropertiesFile.inputStream().use { load(it) }
    }
}

android {
    namespace = "com.ionutc19.jobcoach"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.ionutc19.jobcoach"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["admobAppId"] = findProperty("ADMOB_APP_ID")?.toString()
            ?: "ca-app-pub-1738145743199175~1335978994"
    }

    signingConfigs {
        create("release") {
            storeFile = file(keyProperties.getProperty("storeFile", ""))
            storePassword = keyProperties.getProperty("storePassword", "")
            keyAlias = keyProperties.getProperty("keyAlias", "")
            keyPassword = keyProperties.getProperty("keyPassword", "")
        }
    }

    buildTypes {
        release {
            signingConfig = if (keyProperties.containsKey("storeFile")) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
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
