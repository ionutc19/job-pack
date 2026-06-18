## Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }

## Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

## Google Play Billing (in_app_purchase)
-keep class com.android.vending.billing.** { *; }
-keep class com.google.android.gms.internal.play_billing.** { *; }

## file_picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-keep class androidx.lifecycle.** { *; }

## Keep annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
