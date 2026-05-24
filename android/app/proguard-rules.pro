# ─── Flutter ──────────────────────────────────────────────────────────────────
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter engine references Play Core deferred components even when the app
# doesn't use them. Silence R8 warnings about the missing classes.
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# ─── Google ML Kit Text Recognition ───────────────────────────────────────────
# Without these the on-device OCR model loader gets stripped by R8.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }
-keep class com.google_mlkit_commons.** { *; }
-keep class com.google_mlkit_text_recognition.** { *; }
-dontwarn com.google.mlkit.**

# ─── Sqflite ──────────────────────────────────────────────────────────────────
-keep class com.tekartik.sqflite.** { *; }

# ─── image_picker ─────────────────────────────────────────────────────────────
-keep class io.flutter.plugins.imagepicker.** { *; }

# ─── flutter_image_compress ──────────────────────────────────────────────────
-keep class com.fluttercandies.flutter_image_compress.** { *; }

# ─── PDF / printing ──────────────────────────────────────────────────────────
-keep class net.nfet.flutter.printing.** { *; }

# ─── Kotlin metadata ─────────────────────────────────────────────────────────
-keep class kotlin.Metadata { *; }
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod
