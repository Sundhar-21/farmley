-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

-keepattributes JavascriptInterface
-keepattributes *Annotation*

-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}

-optimizations !class/merging/vertical
-keep class com.razorpay.** {*;}
-keep class com.google.android.gms.wallet.** {*;}
-keep class com.google.android.gms.common.** {*;}
