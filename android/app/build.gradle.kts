import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {

    namespace = "com.jin.reflexology"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // 🔥 FORCE NDK 27 to match plugin requirements


    // ✅ ADD THIS BLOCK (IMPORTANT)
    defaultConfig {

        applicationId = "com.jin.reflexology"

        minSdk = flutter.minSdkVersion   // 🔥 MUST BE 21+
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // 🔥 ADD THESE TO FIX NDK COMPATIBILITY
        ndk {
            // Specify ABI filters for better compatibility
            abiFilters += setOf("arm64-v8a", "armeabi-v7a", "x86_64", "x86")
        }
        
        // 🔥 ADD THESE TO FIX PLUGIN COMPATIBILITY
        externalNativeBuild {
            cmake {
                cppFlags += "-std=c++17"
                arguments += "-DANDROID_STL=c++_shared"
            }
        }
    }


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Signing Config
    signingConfigs {
<<<<<<< HEAD
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
=======
    create("release") {
        val keyAliasVal = keystoreProperties["keyAlias"]?.toString()
        val keyPasswordVal = keystoreProperties["keyPassword"]?.toString()
        val storeFileVal = keystoreProperties["storeFile"]?.toString()
        val storePasswordVal = keystoreProperties["storePassword"]?.toString()

        if (
            keyAliasVal != null &&
            keyPasswordVal != null &&
            storeFileVal != null &&
            storePasswordVal != null
        ) {
            keyAlias = keyAliasVal
            keyPassword = keyPasswordVal
            storeFile = file(storeFileVal)
            storePassword = storePasswordVal
>>>>>>> 47273cb05f712ab9bd50e88a411836648250b559
        }
    }

    // Build Types
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = false
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
