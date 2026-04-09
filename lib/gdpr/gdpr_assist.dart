import "package:dsp_base/convenience_imports.dart";
import "package:flutter/services.dart";

/// GDPR assistance class for handling AdMob consent and privacy settings
/// Based on IAB TCF v2 framework for GDPR compliance
class GDPRAssist {
  static const MethodChannel _channel = MethodChannel("amobi.module.flutter.common/gdpr_assist");

  /// Check if AdMob ads are available based on GDPR consent
  static Future<bool> isAdmobAvailable() async {
    try {
      final result = await _channel.invokeMethod("isAdmobAvailable");
      return result as bool;
    } on PlatformException catch (e, stack) {
      commCrashOnTry(e, stack, hint: "isAdmobAvailable");
      throw Exception("Native GDPR function not available: ${e.message}");
    }
  }

  /// Check if GDPR applies to this user/region
  static Future<bool> isGDPR() async {
    try {
      final result = await _channel.invokeMethod("isGDPR");
      return result as bool;
    } on PlatformException catch (e, stack) {
      commCrashOnTry(e, stack, hint: "isGDPR");
      throw Exception("Native GDPR function not available: ${e.message}");
    }
  }

  /// Check if ads can be shown based on GDPR consent
  /// Minimum required for at least non-personalized ads
  static Future<bool> canShowAds() async {
    try {
      final result = await _channel.invokeMethod("canShowAds");
      return result as bool;
    } on PlatformException catch (e, stack) {
      commCrashOnTry(e, stack, hint: "canShowAds");
      throw Exception("Native GDPR function not available: ${e.message}");
    }
  }

  /// Check if personalized ads can be shown based on GDPR consent
  static Future<bool> canShowPersonalizedAds() async {
    try {
      final result = await _channel.invokeMethod("canShowPersonalizedAds");
      return result as bool;
    } on PlatformException catch (e, stack) {
      commCrashOnTry(e, stack, hint: "canShowPersonalizedAds");
      throw Exception("Native GDPR function not available: ${e.message}");
    }
  }
}
