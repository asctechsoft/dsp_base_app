import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'ads/dsp_ads.dart';
import 'consent/dsp_consent.dart';
import 'firebase/analytics_utils.dart';
import 'firebase/dsp_firebase.dart';
import 'firebase/remote_config_utils.dart';

/// Composition root: registers every service/controller with GetX (permanent,
/// so they survive route changes) and runs the startup in the right order —
/// Firebase -> Remote Config -> consent -> ads. [start] never throws.
/// Afterwards reach any piece with `Get.find<T>()` or its `.to` getter.
///
/// ```dart
/// await DspBase.start(
///   remoteConfigDefaults: {'my_key': ''},
///   useTestAdIds: kDebugMode,
/// );
/// DspAnalytics.to.log(const DspAnalyticsEvent('app_open'));
/// ```
class DspBase {
  DspBase._();

  /// Registers the services (idempotent) without starting anything.
  static void register() {
    _putOnce(() => DspFirebaseService());
    _putOnce(() => DspAnalytics());
    _putOnce(() => DspRemoteConfigRepository());
    _putOnce(() => DspConsentService());
    _putOnce(() => DspAdsController(consent: Get.find<DspConsentService>()));
  }

  static void _putOnce<T extends Object>(T Function() create) {
    if (!Get.isRegistered<T>()) Get.put<T>(create(), permanent: true);
  }

  /// Registers and starts everything. Remote Config is skipped when Firebase
  /// core fails to come up; ads still start (they do not need Firebase).
  static Future<void> start({
    FirebaseOptions? firebaseOptions,
    bool enableAppCheck = true,
    bool? appCheckDebugProvider,
    bool enableCrashlytics = true,
    Map<String, Object> remoteConfigDefaults = const {},
    bool hideAds = false,
    bool useTestAdIds = false,
    bool registerTestAdDevice = false,
    bool debugEeaConsent = false,
  }) async {
    register();
    final firebaseUp = await DspFirebaseService.to.start(
      options: firebaseOptions,
      enableAppCheck: enableAppCheck,
      appCheckDebugProvider: appCheckDebugProvider,
      enableCrashlytics: enableCrashlytics,
    );
    if (firebaseUp) {
      await DspRemoteConfigRepository.to.start(defaults: remoteConfigDefaults);
    }
    await DspAdsController.to.start(
      hideAds: hideAds,
      useTestAdIds: useTestAdIds,
      registerTestDevice: registerTestAdDevice,
      debugEeaConsent: debugEeaConsent,
    );
  }
}
