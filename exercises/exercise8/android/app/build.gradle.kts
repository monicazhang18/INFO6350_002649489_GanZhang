plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services")    // ← 新增
}

android {
    namespace = "com.example.exercise8"
    compileSdk = 34                          // Firebase 现在需要 34+

    defaultConfig {
        applicationId = "com.example.exercise8"
        minSdk = 21
        targetSdk = 34                      // 同步升到 34+
        versionCode = 1
        versionName = "1.0"
    }

    ndkVersion = "27.0.12077973"            // Firestore 等需要这个版本

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.9.0")
    // Kotlin 标准库
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version")

    // Firebase
    implementation("com.google.firebase:firebase-auth-ktx:4.16.0")
    implementation("com.google.firebase:firebase-firestore-ktx:5.6.6")

    implementation("com.google.android.material:material:1.9.0")
}


flutter {
    source = "../.."
}
