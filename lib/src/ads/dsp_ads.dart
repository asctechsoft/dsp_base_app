import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../consent/dsp_consent.dart';
import 'ads_config.dart';

/// GetX controller for the ads lifecycle: UMP consent -> `isHideAd` ->
/// Mobile Ads SDK init -> optional test-device registration. The consent
/// service is injected so it can be replaced in tests.
class DspAdsController extends GetxController {
  DspAdsController({required this.consent});

  static DspAdsController get to => Get.find<DspAdsController>();

  final DspConsentService consent;

  /// Same observables as `DspAdsConfig.isHideAdRx`/`isAdTestIdsRx`.
  RxBool get isHideAd => DspAdsConfig.isHideAdRx;
  RxBool get isAdTestIds => DspAdsConfig.isAdTestIdsRx;

  /// Whether the Mobile Ads SDK finished initialising.
  final RxBool isSdkInitialized = false.obs;

  bool _forceHide = false;

  /// Never throws — a failing step is logged and skipped. [hideAds] forces
  /// every ad off (e.g. a NoAds debug flavour) on top of "consent forbids
  /// requesting ads". [useTestAdIds] swaps in Google's test ad unit ids.
  /// [registerTestDevice] marks this device as an AdMob test device — dev/QA
  /// builds only.
  Future<void> start({
    bool hideAds = false,
    bool useTestAdIds = false,
    bool registerTestDevice = false,
    bool debugEeaConsent = false,
  }) async {
    _forceHide = hideAds;
    DspAdsConfig.isAdTestIds = useTestAdIds;

    await consent.gather(debugEea: debugEeaConsent);
    refreshHidden();

    try {
      await MobileAds.instance.initialize();
      isSdkInitialized.value = true;
      if (registerTestDevice) {
        await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(
            testDeviceIds: [await DspAdsConfig.getAdMobTestDeviceId()],
          ),
        );
      }
    } catch (e) {
      debugPrint('DspAdsController: MobileAds initialization failed: $e');
    }
  }

  /// Recomputes `isHideAd` from the force-hide flag and the latest consent
  /// state — call after the user changes their privacy choice.
  void refreshHidden() {
    DspAdsConfig.isHideAd = _forceHide || !consent.state.value.canRequestAds;
  }
}
