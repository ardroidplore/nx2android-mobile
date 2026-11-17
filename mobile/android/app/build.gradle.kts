plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "org.nx2android.mobile"
    compileSdk = 35
    defaultConfig {
        applicationId = "org.nx2android.mobile"
        minSdk = 26
        targetSdk = 28
        versionCode = 1
        versionName = "0.1.0-experimental"
    }
}
