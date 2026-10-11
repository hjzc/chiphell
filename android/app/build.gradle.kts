import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
 //zorro add
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.zorro.chiphell"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.zorro.chiphell"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        //zorro add
        //ndk {
           // abiFilters += listOf("arm64-v8a")  // 只包含 64 位 ARM 架构，应用体积最小
            // 如果需要支持更多架构，可以添加多个过滤器
            // abiFilters 'arm64-v8a', 'armeabi-v7a' // 同时支持 64 位和 32 位 ARM
        //}
    }

    //zorro add
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            //signingConfig = signingConfigs.getByName("debug")
            //zorro add
            signingConfig = signingConfigs.getByName("release")
            //ndk{ // 必须加入这部分，否则可能导致编译成功的release包在真机中会闪退
               // abiFilters "armeabi-v7a"
            //}

            //开启混淆：设置为true时，ProGuard或R8会移除未使用代码、重命名类/方法名，减小APK体积并提高安全性 。 ‌12
            //关闭混淆：设置为false时，仅保留原始代码结构，便于调试
            isMinifyEnabled = true
            //minifyEnabled = true
            //shrinkResources是一个与Android打包相关的配置项，用于控制是否在构建APK时缩减资源文件
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

        }
        
        debug {
            //signingConfig = signingConfigs.getByName("debug")
            applicationIdSuffix="test"
            //ndk {
                //这里要加上，否则debug包会出问题,后面三个为可选，x86建议加上不然部分模拟器回报错
               // abiFilters "armeabi", "armeabi-v7a", "arm64-v8a",  "x86"
            //}
        }

    }
}

flutter {
    source = "../.."
}
