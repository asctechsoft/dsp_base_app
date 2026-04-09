// ignore_for_file: prefer_constructors_over_static_methods

@Deprecated("Use 'package:dsp_base/advertisements.dart' instead")
library;

import "package:dsp_base/advertisements/ad_test_ids.dart";
import "package:dsp_base/advertisements/adverts_config.dart";
import "package:dsp_base/convenience_imports.dart";
import "package:get/get.dart";
import "package:google_mobile_ads/google_mobile_ads.dart";

class OpenAdController extends GetxController {
  bool isAdLoaded = false;
  bool isAdLoading = false;
  bool _isShowingAd = false;
  String? _adUnitId;

  static OpenAdController newInstance({required String adUnitId, String? tag}) {
    return Get.put(
      OpenAdController(),
      tag: "$adUnitId${tag ?? ""}",
    )..setAdUnitId(adUnitId);
  }

  static OpenAdController getInstance({required String adUnitId, String? tag}) {
    return Get.find<OpenAdController>(tag: "$adUnitId${tag ?? ""}");
  }

  void setAdUnitId(String adUnitId) {
    _adUnitId = AdvertsConfig.instance.isAdTestIds ? AdTestIds.appOpenAdId : adUnitId;
  }

  /// Maximum duration allowed between loading and showing the ad.
  final Duration maxCacheDuration = const Duration(hours: 4);

  /// Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadedTime;

  AppOpenAd? _openAd;

  void requestOpenAd() {
    if (AdvertsConfig.instance.isHideAd) return;
    if (_adUnitId == null || _adUnitId!.isEmpty) {
      CommLogger.d("Open ad unit ID is not set.");
      return;
    }
    if (isAdLoading) return;

    isAdLoading = true;

    AppOpenAd.load(
      adUnitId: _adUnitId!,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _openAd = ad;

          isAdLoaded = true;
          isAdLoading = false;
          _appOpenLoadedTime = DateTime.now();
        },
        onAdFailedToLoad: (LoadAdError error) {
          isAdLoaded = false;
          isAdLoading = false;
          _openAd?.dispose();
          _openAd = null;
        },
      ),
    );
  }

  void showAd({Function? onAdDismiss}) {
    if (AdvertsConfig.instance.isHideAd) return;
    if (isAdLoading) {
      CommLogger.d("Open ad is currently loading.");
      return;
    }

    if (!isAdLoaded || _openAd == null) {
      CommLogger.d("Open ad is not loaded yet.");
      requestOpenAd();
      return;
    }

    if (_isShowingAd) {
      CommLogger.d("Tried to show ad while already showing an ad.");
      return;
    }

    final currentTime = MixedUtils.currentTimeMillis();
    final oldTime = AdvertsConfig.getLastTimeShowedFullAd();
    if (currentTime - oldTime < RconfAssist.getInt(RconfComm.COMM_DELAY_INTER_ADS) * CommFigs.MILLIS_SECOND) {
      CommLogger.d("Ad was shown recently. Not showing another ad yet.");
      return;
    }

    if (AdvertsConfig.instance.getScreenCount() < RconfAssist.getInt(RconfComm.COMM_DELAY_INTER_ADS_BY_SCREEN_COUNT)) {
      return;
    }

    if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadedTime!)) {
      CommLogger.d("Maximum cache duration exceeded. Loading another ad.");
      _openAd!.dispose();
      _openAd = null;
      requestOpenAd();
      return;
    }

    AdvertsConfig.instance.resetScreenCount();

    _openAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;

        AdvertsConfig.setLastTimeShowedFullAd(MixedUtils.currentTimeMillis());
      },
      onAdImpression: (ad) {},
      onAdFailedToShowFullScreenContent: (ad, err) {
        _isShowingAd = false;
        isAdLoaded = false;
        isAdLoading = false;
        ad.dispose();

        requestOpenAd();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;

        isAdLoaded = false;
        isAdLoading = false;
        ad.dispose();
        _appOpenLoadedTime = null;
        requestOpenAd();

        if (onAdDismiss != null) {
          onAdDismiss();
        }
      },
      onAdClicked: (ad) {},
    );
    _openAd?.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
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

    try {
      _openAd?.setImmersiveMode(true);
      _openAd?.show();
    } catch (e) {
      CommLogger.e("Error showing open ad: $e");
      _isShowingAd = false;
      isAdLoaded = false;
      isAdLoading = false;
      _openAd?.dispose();
      _openAd = null;
      requestOpenAd();
    }
  }
}
