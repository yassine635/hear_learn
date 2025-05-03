# Keep all ML Kit vision classes (text recognition, etc.)
-keep class com.google.mlkit.vision.** { *; }
-keep class com.google.mlkit.common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }

# Prevent warnings
-dontwarn com.google.mlkit.**