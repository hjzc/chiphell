# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

#混淆时所采用的算法(谷歌推荐算法)
-optimizations !code/simplification/arithmetic,!field,!class/merging,!code/allocation/variable

#添加支持的jar(引入libs下的所有jar包)
#-libraryjars libs(*.jar;)

#将文件来源重命名为“SourceFile”字符串
-renamesourcefileattribute SourceFile

#保持注解不被混淆
-keepattributes *Annotation*
-keep class * extends java.lang.annotation.Annotation {*;}

#保持泛型不被混淆
-keepattributes Signature
#保持反射不被混淆
-keepattributes EnclosingMethod
#保持异常不被混淆
-keepattributes Exceptions
#保持内部类不被混淆
-keepattributes Exceptions,InnerClasses
#抛出异常时保留代码行号
-keepattributes SourceFile,LineNumberTable

#保持四大组件不被混淆
-keep public class * extends android.app.Fragment
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference

#保持 Google 原生服务需要的类不被混淆
#-keep public class com.google.vending.licensing.ILicensingService
#-keep public class com.android.vending.licensing.ILicensingService

# 保留继承的
-keep public class * extends android.support.v4.**
-keep public class * extends android.support.v7.**
-keep public class * extends android.support.annotation.**
-keep class com.google.android.material.** {*;}
-dontwarn com.google.android.material.**
-dontnote com.google.android.material.**

#保持枚举 enum 类不被混淆
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# 保留R文件的类不被混淆
-keep class **.R$* {*;}

#保护代码中的jsinterface注解不被混淆
-keepattributes *JavascriptInterface*

#WebView处理，项目中没有使用到webView忽略即可
#保持Android与JavaScript进行交互的类不被混淆
-keep class **.AndroidJavaScript { *; }
-keepclassmembers class * extends android.webkit.WebViewClient {
     public void *(android.webkit.WebView,java.lang.String,android.graphics.Bitmap);
     public boolean *(android.webkit.WebView,java.lang.String);
}
-keepclassmembers class * extends android.webkit.WebChromeClient {
     public void *(android.webkit.WebView,java.lang.String);
}

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# 引用的第三方库
-keep class dev.fluttercommunity.plus.**  { *; }
-keep interface dev.fluttercommunity.plus.**  { *; }

-keep class com.pichillilorenzo.**  { *; }
-keep interface com.pichillilorenzo.**  { *; }


-keep class net.jonhanson.**  { *; }
-keep interface net.jonhanson.**   { *; }

-keep class com.example.image_gallery_saver_plus.**  { *; }
-keep class dev.fluttercommunity.plus.**   { *; }

-keep class com.baseflow.permissionhandler.**   { *; }

-keep class dev.fluttercommunity.plus.**   { *; }
-keep interface dev.fluttercommunity.plus.**   { *; }

-keep class com.tekartik.**   { *; }
-keep class com.tekartik.sqflite.**   { *; }
-keep interface com.tekartik.sqflite.**   { *; }

-keep class io.flutter.plugins.**   { *; }
-keep interface io.flutter.plugins.**   { *; }

# 保留support下的所有类及其内部类,AndroidX
-keep class android.support.** {*;}
-dontwarn android.support.**
-keep interface android.support.** { *; }
-keep class androidx.** {*;}
-keep interface androidx.** {*;}
-keep public class * extends androidx.**
-dontwarn androidx.**

