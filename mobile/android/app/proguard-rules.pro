## Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }

## Google Play Core (deferred components, referenced by Flutter engine)
-dontwarn com.google.android.play.core.**

## Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

## Google Play Billing (in_app_purchase)
-keep class com.android.vending.billing.** { *; }
-keep class com.google.android.gms.internal.play_billing.** { *; }

## file_picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }

## AndroidX Startup (InitializationProvider — crashes on launch if stripped)
-keep class androidx.startup.** { *; }

## AndroidX WorkManager (used by google_mobile_ads for background scheduling)
-keep class androidx.work.** { *; }

## AndroidX Room (WorkManager's internal database)
-keep class androidx.room.** { *; }
-keep class * extends androidx.room.RoomDatabase { *; }
-keep @androidx.room.Entity class * { *; }
-keep @androidx.room.Dao class * { *; }

## AndroidX Lifecycle
-keep class androidx.lifecycle.** { *; }

## Keep annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
