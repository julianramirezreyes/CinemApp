# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# WebView and JavaScriptInterface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepattributes JavascriptInterface
-keepattributes *Annotation*

# YouTube Player IFrame Plugin
-keep class com.pierfrancescosoffritti.androidyoutubeplayer.** { *; }
-keep class androidx.lifecycle.** { *; }

# Suppress warnings for Play Core classes used by Flutter but not present
-dontwarn com.google.android.play.core.**
