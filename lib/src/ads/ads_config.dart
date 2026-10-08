import 'dart:convert';
import 'dart:io' show Platform;

import 'package:android_id/android_id.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';

/// Global ads switches every ad service/view checks before loading or
/// rendering an ad. Backed by GetX [RxBool]s so views read them inside `Obx`
/// and rebuild when they flip; the plain static getters/setters serve
/// non-reactive call sites (ad services, `if (DspAdsConfig.isHideAd)`).
/// `DspAdsController` exposes the very same observables.
class DspAdsConfig {
  DspAdsConfig._();

  static final RxBool isHideAdRx = false.obs;
  static final RxBool isAdTestIdsRx = false.obs;

  /// Hides every ad (banner/native/interstitial/rewarded/app open)
  /// regardless of load state - flip on for a debug/test build.
  static bool get isHideAd => isHideAdRx.value;
  static set isHideAd(bool value) => isHideAdRx.value = value;

  /// Forces every ad request to use Google's official test ad unit ids
  /// instead of the real ones - flip on outside a shipped release build so
  /// development traffic never hits real inventory (Google can flag an
  /// AdMob account for abnormal real-ad request volume from test devices).
  static bool get isAdTestIds => isAdTestIdsRx.value;
  static set isAdTestIds(bool value) => isAdTestIdsRx.value = value;

  /// Resolves the ad unit id a service should actually request: the real
  /// [adUnitId] normally, or the matching platform id from
  /// [androidTestId]/[iosTestId] (see [DspTestAdIds]) when [isAdTestIds] is
  /// on.
  static String resolveAdUnitId({
    required String adUnitId,
    required String androidTestId,
    required String iosTestId,
  }) {
    if (!isAdTestIds) return adUnitId;
    return Platform.isAndroid ? androidTestId : iosTestId;
  }

  /// MD5 hash of this device's Android ID (or iOS vendor ID), uppercased hex
  /// - the format `MobileAds.instance.updateRequestConfiguration(
  /// RequestConfiguration(testDeviceIds: [...]))` expects to mark a
  /// non-emulator device as an AdMob test device even when requesting real
  /// ad unit ids.
  /// https://developers.google.com/admob/android/test-ads#add_your_test_device
  static Future<String> getAdMobTestDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      var deviceId = '';

      if (Platform.isAndroid) {
        const androidIdPlugin = AndroidId();
        final androidId = await androidIdPlugin.getId();
        if ((androidId ?? '').isNotEmpty) {
          deviceId = androidId!;
        } else {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id;
        }
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
      }

      final digest = md5.convert(utf8.encode(deviceId.toLowerCase()));
      return digest.toString().toUpperCase();
    } catch (_) {
      return 'UNKNOWN-DEVICE-ID';
    }
  }
}
