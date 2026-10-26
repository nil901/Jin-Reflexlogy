# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# country_state_city package - Prevent obfuscation of data classes
-keep class com.example.country_state_city.** { *; }
-keep class country_state_city.** { *; }
-keep class com.jin.reflexology.country_state_city.** { *; }

# Keep generic signatures for Gson/JSON serialization (if used)
-keepattributes Signature
-keepattributes *Annotation*

# Keep line number information for better stack traces
-keepattributes SourceFile,LineNumberTable

# Keep enum fields
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable objects
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep Serializable objects
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep all classes from the app's package
-keep class com.jin.reflexology.** { *; }
-dontwarn com.jin.reflexology.**

# Keep data classes used for JSON serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ============================================
# FIX FOR R8 MISSING CLASSES (Play Core)
# ============================================
# These rules prevent R8 from removing Play Core classes
# that are required by some plugins but not directly used

# Keep all Play Core classes
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Specifically keep splitinstall and splitcompat classes
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Keep in-app review and update classes (if used)
-keep class com.google.android.play.core.appupdate.** { *; }
-keep class com.google.android.play.core.review.** { *; }

# Keep all play.services classes
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep all firebase classes (if used)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep all google play services auth classes
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Keep all support library classes
-keep class androidx.** { *; }
-dontwarn androidx.**

# Keep Kotlin classes
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# Keep coroutines
-keep class kotlinx.** { *; }
-dontwarn kotlinx.**

# Keep all classes from plugins that might use Play Core
-keep class com.google.androidbrowserhelper.** { *; }
-dontwarn com.google.androidbrowserhelper.**

# Keep classes used by Razorpay, PayPal, and other payment SDKs
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

-keep class com.paypal.** { *; }
-dontwarn com.paypal.**

# Keep classes for file picker and other native plugins
-keep class com.pichillilorenzo.** { *; }
-dontwarn com.pichillilorenzo.**

# Keep classes for image picker
-keep class io.flutter.plugins.imagepicker.** { *; }
-dontwarn io.flutter.plugins.imagepicker.**

# Keep classes for camera plugin
-keep class io.flutter.plugins.camera.** { *; }
-dontwarn io.flutter.plugins.camera.**

# Keep classes for path provider
-keep class io.flutter.plugins.pathprovider.** { *; }
-dontwarn io.flutter.plugins.pathprovider.**

# Keep classes for shared preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences.**

# Keep classes for url launcher
-keep class io.flutter.plugins.urllauncher.** { *; }
-dontwarn io.flutter.plugins.urllauncher.**

# Keep classes for connectivity plus
-keep class io.flutter.plugins.connectivity.** { *; }
-dontwarn io.flutter.plugins.connectivity.**

# Keep classes for permission handler
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# Keep classes for geolocator
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# Keep classes for video player
-keep class io.flutter.plugins.videoplayer.** { *; }
-dontwarn io.flutter.plugins.videoplayer.**

# Keep classes for webview
-keep class io.flutter.plugins.webviewflutter.** { *; }
-dontwarn io.flutter.plugins.webviewflutter.**

# Keep classes for syncfusion
-keep class com.syncfusion.** { *; }
-dontwarn com.syncfusion.**

# Keep classes for PDF viewer
-keep class com.shockwave.** { *; }
-dontwarn com.shockwave.**

# Keep classes for screenshot
-keep class com.pravera.flutter_screenshot.** { *; }
-dontwarn com.pravera.flutter_screenshot.**

# Keep classes for photo view
-keep class com.example.photo_view.** { *; }
-dontwarn com.example.photo_view.**

# Keep classes for file_picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-dontwarn com.mr.flutter.plugin.filepicker.**

# Keep classes for dropdown_search
-keep class com.example.dropdown_search.** { *; }
-dontwarn com.example.dropdown_search.**

# Keep classes for cached_network_image
-keep class io.flutter.plugins.cachednetworkimage.** { *; }
-dontwarn io.flutter.plugins.cachednetworkimage.**

# Keep classes for share_plus
-keep class dev.flutter.plugins.share_plus.** { *; }
-dontwarn dev.flutter.plugins.share_plus.**

# Keep classes for carousel_slider
-keep class com.example.carousel_slider.** { *; }
-dontwarn com.example.carousel_slider.**

# Keep classes for animate_do
-keep class com.example.animate_do.** { *; }
-dontwarn com.example.animate_do.**

# Keep classes for hexcolor
-keep class com.example.hexcolor.** { *; }
-dontwarn com.example.hexcolor.**

# Keep classes for intl
-keep class com.example.intl.** { *; }
-dontwarn com.example.intl.**

# Keep classes for book_flip and page_flip
-keep class com.example.book_flip.** { *; }
-dontwarn com.example.book_flip.**

-keep class com.example.page_flip.** { *; }
-dontwarn com.example.page_flip.**

# Keep classes for country_state_city
-keep class com.example.country_state_city.** { *; }
-dontwarn com.example.country_state_city.**

# Keep classes for country_state_city_picker
-keep class com.example.country_state_city_picker.** { *; }
-dontwarn com.example.country_state_city_picker.**

# Keep classes for country_flags
-keep class com.example.country_flags.** { *; }
-dontwarn com.example.country_flags.**

# Keep classes for phonepe_payment_sdk
-keep class com.phonepe.** { *; }
-dontwarn com.phonepe.**

# Keep classes for get (GetX)
-keep class com.example.get.** { *; }
-dontwarn com.example.get.**

# Keep classes for flutter_riverpod
-keep class com.example.flutter_riverpod.** { *; }
-dontwarn com.example.flutter_riverpod.**

# Keep classes for youtube_player_flutter
-keep class com.example.youtube_player_flutter.** { *; }
-dontwarn com.example.youtube_player_flutter.**

# Keep classes for dio
-keep class com.example.dio.** { *; }
-dontwarn com.example.dio.**

# Keep classes for html parser
-keep class org.jsoup.** { *; }
-dontwarn org.jsoup.**

# Keep classes for image processing
-keep class com.example.image.** { *; }
-dontwarn com.example.image.**

# Keep classes for crypto
-keep class com.example.crypto.** { *; }
-dontwarn com.example.crypto.**

# Keep classes for pdf generation
-keep class com.example.pdf.** { *; }
-dontwarn com.example.pdf.**

# Keep classes for flutter_image_compress
-keep class com.example.flutter_image_compress.** { *; }
-dontwarn com.example.flutter_image_compress.**

# Keep classes for geocoding
-keep class com.example.geocoding.** { *; }
-dontwarn com.example.geocoding.**

# Keep classes for dropdown_search
-keep class com.example.dropdown_search.** { *; }
-dontwarn com.example.dropdown_search.**

# Keep classes for syncfusion_flutter_pdfviewer
-keep class com.syncfusion.** { *; }
-dontwarn com.syncfusion.**

# Keep classes for syncfusion_flutter_gauges
-keep class com.syncfusion.** { *; }
-dontwarn com.syncfusion.**
