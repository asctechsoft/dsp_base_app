@Deprecated("Use 'package:dsp_base/advertisements.dart' instead")
library;

import "dart:convert";
import "dart:io";

import "package:dsp_base/comm_figs.dart";
import "package:dsp_base/utils/firebase_assist.dart";
import "package:dsp_base/utils/pref_assist.dart";
import "package:android_id/android_id.dart";
import "package:crypto/crypto.dart";
import "package:device_info_plus/device_info_plus.dart";
import "package:flutter/cupertino.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:google_mobile_ads/google_mobile_ads.dart";

class AdvertsConfig {
  static AdvertsConfig instance = AdvertsConfig();

  bool isAdTestIds = CommFigs.IS_ALPHA;

  bool _isHideAd = CommFigs.IS_CLAUDE;

  bool get isHideAd => _isHideAd;

  set isHideAd(bool value) {
    _isHideAd = CommFigs.IS_CLAUDE ? true : value;
  }

  bool isShowingInterstitialAd = false;

  AdRequest? generalBannerAdRequest;

  /// Generate device hash ID for AdMob testing
  /// This method creates an MD5 hash of the Android ID as required by AdMob
  /// Based on: https://stackoverflow.com/questions/4524752/how-can-i-get-device-id-for-admob
  Future<String> getAdMobDeviceAndroidId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      var deviceId = "";

      if (Platform.isAndroid) {
        // Prefer true ANDROID_ID via plugin to match AdMob's expected hash
        const androidIdPlugin = AndroidId();
        final androidId = await androidIdPlugin.getId();

        // Fallback to device_info_plus if needed
        if ((androidId ?? "").isNotEmpty) {
          deviceId = androidId!;
        } else {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id; // may differ from ANDROID_ID
        }
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? "";
      }

      // Create MD5 hash of lowercased device ID, then uppercase hex (AdMob format)
      final bytes = utf8.encode(deviceId.toLowerCase());
      final digest = md5.convert(bytes);
      final hashId = digest.toString().toUpperCase();

      debugPrint("Add this to your testIdentifiers: [\"$hashId\"]");

      return hashId;
    } catch (e, stack) {
      commCrashOnTry(e, stack, hint: "getAdMobDeviceAndroidId");
      return "UNKNOWN-DEVICE-ID";
    }
  }

  // Constants for ad timing management
  static const String kLastTimeShowFullActionAds = "kLASTIME_SHOW_FULL_ACTION_ADS";
  static const String kValueMicrosCounted = "kVALUE_MICROS_COUNTED";
  static const String kValueMicrosRecorded = "kVALUE_MICROS_RECORDED";

  /// Clear the last time a full action ad was shown
  static Future<void> clearLastTimeShowedFullAd() async {
    await PrefAssist.setInt(kLastTimeShowFullActionAds, 0);
  }

  /// Set the last time a full action ad was shown
  static Future<void> setLastTimeShowedFullAd(int time) async {
    await PrefAssist.setInt(kLastTimeShowFullActionAds, time);
  }

  /// Get the last time a full action ad was shown
  /// Returns 0 if the stored time is in the future (invalid)
  static int getLastTimeShowedFullAd() {
    final lastTime = PrefAssist.getInt(kLastTimeShowFullActionAds);
    if (lastTime > DateTime.now().millisecondsSinceEpoch) {
      PrefAssist.setInt(kLastTimeShowFullActionAds, 0);
      return 0;
    }
    return lastTime;
  }

  void sendLogAdverts({
    required Ad ad,
    required double valueMicros,
    required PrecisionType precision,
    required String currencyCode,
    required String adUnitId,
    required String mediationAdapterClassName,
  }) {
    final precisionInt = switch (precision) {
      PrecisionType.estimated => 1,
      PrecisionType.publisherProvided => 2,
      PrecisionType.precise => 3,
      PrecisionType.unknown => 0,
    };

    final params = <String, Object>{
      "valuemicros": valueMicros,
      // These values below won't be used in ROAS recipe.
      // But log for purposes of debugging and future reference.
      "currency": currencyCode,
      "precision": precisionInt,
      "adunitid": adUnitId,
      "network": mediationAdapterClassName,
    };

    FirebaseAssist.logPaidAdvertsClicked(params);

    sendLogX5Adverts(
      valueMicros: valueMicros,
      currencyCode: currencyCode,
      precision: precision,
      adUnitId: adUnitId,
      mediationAdapterClassName: mediationAdapterClassName,
    );
  }

  void sendLogX5Adverts({
    required double valueMicros,
    required String currencyCode,
    required PrecisionType precision,
    required String adUnitId,
    required String mediationAdapterClassName,
  }) {
    final valueCounted = PrefAssist.getInt(kValueMicrosCounted);
    final valueRecorded = PrefAssist.getInt(kValueMicrosRecorded);

    if (valueCounted <= 4) {
      PrefAssist.setInt(kValueMicrosCounted, valueCounted + 1);
      PrefAssist.setInt(kValueMicrosRecorded, valueRecorded + valueMicros.toInt());
      return;
    }

    final precisionInt = switch (precision) {
      PrecisionType.estimated => 1,
      PrecisionType.publisherProvided => 2,
      PrecisionType.precise => 3,
      PrecisionType.unknown => 0,
    };

    final params = <String, Object>{
      "valuemicros": valueRecorded + valueMicros.toInt(),
      // These values below won't be used in ROAS recipe.
      // But log for purposes of debugging and future reference.
      "currency": currencyCode,
      "precision": precisionInt,
      "adunitid": adUnitId,
      "network": mediationAdapterClassName,
    };

    FirebaseAssist.logPaidAdvertsX5Clicked(params);

    PrefAssist.setInt(kValueMicrosCounted, 0);
    PrefAssist.setInt(kValueMicrosRecorded, 0);
  }

  int screenCount = 0;

  void incrementScreenCount({int amount = 1, bool noToast = false}) {
    screenCount += amount;
    if (false && !CommFigs.IS_PRODUCT && !noToast) {
      Fluttertoast.showToast(msg: "incrementScreenCount: $screenCount");
    }
  }

  int getScreenCount() {
    return screenCount;
  }

  void resetScreenCount() {
    if (screenCount == 0) return;
    screenCount = 0;
    if (false && !CommFigs.IS_PRODUCT) {
      Fluttertoast.showToast(msg: "resetScreenCount: $screenCount");
    }
  }
}
