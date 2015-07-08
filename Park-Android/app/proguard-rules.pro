# This is a configuration file for ProGuard.
# http://proguard.sourceforge.net/index.html#manual/usage.html

# Optimizations: If you don't want to optimize, use the
# proguard-android.txt configuration file instead of this one, which
# turns off the optimization flags.  Adding optimization introduces
# certain risks, since for example not all optimizations performed by
# ProGuard works on all versions of Dalvik.  The following flags turn
# off various optimizations known to have issues, but the list may not
# be complete or up to date. (The "arithmetic" optimization can be
# used if you are only targeting Android 2.0 or later.)  Make sure you
# test thoroughly if you go this route.
-optimizations !code/simplification/cast,!code/allocation/*,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify
-repackageclasses ''

# The remainder of this file is identical to the non-optimized version
# of the Proguard configuration file (except that the other file has
# flags to turn off optimization).

#-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

-keepattributes *Annotation*
#-keep public class com.google.vending.licensing.ILicensingService
#-keep public class com.android.vending.licensing.ILicensingService


# For native methods, see http://proguard.sourceforge.net/manual/examples.html#native
#-keepclasseswithmembernames class * {
#    native <methods>;
#}

# keep setters in Views so that animations can still work.
# see http://proguard.sourceforge.net/manual/examples.html#beans
#-keepclassmembers public class * extends android.view.View {
#   void set*(***);
#   *** get*();
#}

# We want to keep methods in Activity that could be used in the XML attribute onClick
#-keepclassmembers class * extends android.app.Activity {
#   public void *(android.view.View);
#}

# For enumeration classes, see http://proguard.sourceforge.net/manual/examples.html#enumerations
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

-keepclassmembers class **.R$* {
    public static <fields>;
}

#-keep public class android.support.**

# The support library contains references to newer platform versions.
# Don't warn about those in case this app is linking against an older
# platform version.  We know about them, and they are safe.
-dontwarn android.support.**

-assumenosideeffects class android.util.Log { *; }


-keep class * extends java.util.ListResourceBundle {
    protected Object[][] getContents();
}

-keep public class com.google.android.gms.common.internal.safeparcel.SafeParcelable {
    public static final *** NULL;
}

-keepnames @com.google.android.gms.common.annotation.KeepName class *
-keepclassmembernames class * {
    @com.google.android.gms.common.annotation.KeepName *;
}

-keepnames class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

-keep class com.loopj.android.** { *; }
-keep interface com.loopj.android.** { *; }

-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

-keepattributes JavascriptInterface

-keep public class com.dashang.park.QQActivity$QQInterface
-keep public class * implements com.dashang.park.QQActivity$QQInterface
-keepclassmembers class com.dashang.park.QQActivity$QQInterface {
    <methods>;
}

-keep public class com.dashang.park.MainActivity$MapInterface
-keep public class * implements com.dashang.park.MainActivity$MapInterface
-keepclassmembers class com.dashang.park.MainActivity$MapInterface {
    <methods>;
}
-keep class org.xwalk.core.** {
*;
}
-keep class org.chromium.** {
*;
}
-keepattributes **

-keep class com.tencent.mm.sdk.openapi.WXMediaMessage {*;}
-keep class com.tencent.mm.sdk.openapi.** implements com.tencent.mm.sdk.openapi.WXMediaMessage$IMediaObject {*;}