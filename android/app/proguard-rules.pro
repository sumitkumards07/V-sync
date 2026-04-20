## Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## Flutter Rust Bridge / JNI
-keep class com.aspect.** { *; }
-keep class ** extends io.flutter.embedding.engine.plugins.FlutterPlugin { *; }

## Keep all native methods (Rust FFI)
-keepclasseswithmembernames class * {
    native <methods>;
}

## Prevent stripping annotations used by serialization
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

## Keep Gson / JSON serialization models if any
-keep class com.vsync.app.** { *; }

## Suppress warnings for common Flutter dependencies
-dontwarn io.flutter.embedding.**
-dontwarn com.google.android.play.core.**
