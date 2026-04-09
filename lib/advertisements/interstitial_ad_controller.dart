// ignore_for_file: prefer_constructors_over_static_methods

@Deprecated("Use 'package:dsp_base/advertisements.dart' instead")
library;

import "package:dsp_base/advertisements/ad_test_ids.dart";
import "package:dsp_base/advertisements/adverts_config.dart";
import "package:dsp_base/app_material.dart";
import "package:dsp_base/convenience_imports.dart";
import "package:get/get.dart";
import "package:google_mobile_ads/google_mobile_ads.dart";

class InterstitialAdController extends GetxController {
  bool isAdLoaded = false;
  bool isAdLoading = false;
  String? adUnitId;
  InterstitialAd? _interstitialAd;
  VoidCallback? onAdDismiss;

  static InterstitialAdController newInstance({required String adUnitId, String? tag}) {
    return Get.put(
      InterstitialAdController(),
      tag: "$adUnitId${tag ?? ""}",
    )..setAdUnitId(adUnitId);
  }

  static InterstitialAdController getInstance({required String adUnitId, String? tag}) {
    return Get.find<InterstitialAdController>(tag: "$adUnitId${tag ?? ""}");
  }

  void setAdUnitId(String adUnitId) {
    this.adUnitId = AdvertsConfig.instance.isAdTestIds ? AdTestIds.interstitialAdId : adUnitId;
  }

  void requestInterstitialAd() {
    if (AdvertsConfig.instance.isHideAd) return;
    if (adUnitId == null || adUnitId!.isEmpty) {
      CommLogger.d("Ad unit id is null or empty, cannot load interstitial ad.");
      return;
    }
    if (isAdLoading) return;
    isAdLoading = true;

    InterstitialAd.load(
      adUnitId: adUnitId!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          ad
            ..fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
              onAdShowedFullScreenContent: (ad) {},
              // Called when an impression occurs on the ad.
              onAdImpression: (ad) {},
              // Called when the ad failed to show full screen content.
              onAdFailedToShowFullScreenContent: (ad, err) {
                // Dispose the ad here to free resources.
                ad.dispose();
              },
              // Called when the ad dismissed full screen content.
              onAdDismissedFullScreenContent: (ad) {
                // Dispose the ad here to free resources.
                ad.dispose();
                AdvertsConfig.setLastTimeShowedFullAd(MixedUtils.currentTimeMillis());
                onAdDismiss?.call();
                AdvertsConfig.instance.isShowingInterstitialAd = false;

                requestAdAgain();
              },
              // Called when a click is recorded for an ad.
              onAdClicked: (ad) {},
            )
            ..onPaidEvent = (ad, valueMicros, precision, currencyCode) {
              final mediationAdapterClassName = ad.responseInfo?.mediationAdapterClassName;
              if (mediationAdapterClassName == null || mediationAdapterClassName.isEmpty) {
                return;
              }
              AdvertsConfig.instance.sendLogAdverts(
                ad: ad,
                valueMicros: valueMicros,
                precision: precision,
                currencyCode: currencyCode,
                adUnitId: ad.adUnitId,
                mediationAdapterClassName: mediationAdapterClassName,
              );
            };

          _interstitialAd = ad;

          isAdLoaded = true;
          isAdLoading = false;
        },
        onAdFailedToLoad: (LoadAdError error) {
          isAdLoaded = false;
          isAdLoading = false;
          _interstitialAd?.dispose();
          _interstitialAd = null;
        },
      ),
    );
  }

  void requestAdAgain() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    isAdLoaded = false;
    isAdLoading = false;
    requestInterstitialAd();
  }

  void setOnAdDismiss(VoidCallback onAdDismiss) {
    this.onAdDismiss = onAdDismiss;
  }

  Future<void> showAd({
    VoidCallback? onStartShowAd,
    int delayInMillis = 0,
  }) async {
    if (AdvertsConfig.instance.isHideAd) return;

    final currentTime = MixedUtils.currentTimeMillis();
    final oldTime = AdvertsConfig.getLastTimeShowedFullAd();
    if (currentTime - oldTime < RconfAssist.getInt(RconfComm.COMM_DELAY_INTER_ADS) * CommFigs.MILLIS_SECOND) {
      CommLogger.d("Ad was shown recently. Not showing another ad yet.");
      return;
    }

    if (AdvertsConfig.instance.getScreenCount() < RconfAssist.getInt(RconfComm.COMM_DELAY_INTER_ADS_BY_SCREEN_COUNT)) {
      return;
    }

    if (AdvertsConfig.instance.isShowingInterstitialAd) {
      CommLogger.d("Interstitial ad is showing => No need to show ad yet.");
      return;
    }

    if (!isAdLoaded || _interstitialAd == null) {
      CommLogger.d("Interstitial ad is not loaded yet.");
      requestAdAgain();
      return;
    }

    AdvertsConfig.instance.resetScreenCount();

    CommLogger.d("Show ad for id: $adUnitId");
    onStartShowAd?.call();
    if (delayInMillis > 0) {
      await Future.delayed(Duration(milliseconds: delayInMillis));
    }
    try {
      _interstitialAd?.setImmersiveMode(true);
      _interstitialAd?.show();
      AdvertsConfig.instance.isShowingInterstitialAd = true;
    } catch (e) {
      CommLogger.e("Error showing interstitial ad: $e");
      AdvertsConfig.instance.isShowingInterstitialAd = false;
      requestAdAgain();
    }
  }
}
