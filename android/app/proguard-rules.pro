# ===============================================================
# iGlows ProGuard / R8 rules
# Tujuan: obfuscation rumit + shrink + tetap aman untuk Flutter,
# Firebase, image_picker, webview_flutter, local notifications, dsb.
# ===============================================================

# --- Mode obfuscation agresif ---
-allowaccessmodification
-repackageclasses 'o'
-overloadaggressively
-mergeinterfacesaggressively
-optimizationpasses 5
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*

# Buang semua log Android di release (anti-leak info internal).
-assumenosideeffects class android.util.Log {
    public static *** v(...);
    public static *** d(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

# Hapus debug print Dart sisa (kalau ada wrapper).
-assumenosideeffects class java.io.PrintStream {
    public *** println(...);
    public *** print(...);
}

# Jangan sertakan source file / line number asli.
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable

# --- Flutter engine ---
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# --- Firebase ---
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firestore model reflection.
-keepclassmembers class * {
    @com.google.firebase.firestore.PropertyName <fields>;
    @com.google.firebase.firestore.PropertyName <methods>;
}

# --- WebView (salon map embed) ---
-keep class * extends android.webkit.WebViewClient { *; }
-keep class * extends android.webkit.WebChromeClient { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# --- Local notifications + timezone ---
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# --- Image picker / native exif ---
-keep class androidx.exifinterface.** { *; }
-dontwarn androidx.exifinterface.**

# --- Multidex ---
-keep class androidx.multidex.** { *; }

# --- Kotlin metadata (dipakai banyak plugin) ---
-keep class kotlin.Metadata { *; }
-keepattributes RuntimeVisibleAnnotations,AnnotationDefault

# --- Anti tampering hint: jangan keep nama field "BuildConfig" trivial ---
-keep class **.R$* { *; }

# Jangan throw warning untuk dependency opsional yang gak dipakai.
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
