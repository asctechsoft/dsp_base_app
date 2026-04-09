// ignore_for_file: prefer_constructors_over_static_methods

@Deprecated("Use 'package:dsp_base/advertisements.dart' instead")
library;

import "package:dsp_base/advertisements/ad_test_ids.dart";
import "package:dsp_base/advertisements/adverts_config.dart";
import "package:dsp_base/app_material.dart";
import "package:dsp_base/convenience_imports.dart";
import "package:get/get.dart";
import "package:google_mobile_ads/google_mobile_ads.dart";

class BannerAdController extends GetxController {
  RxBool isBannerAdLoaded = false.obs;
  BannerAd? _bannerAd;
  bool isAdLoading = false;
  AdSize _adSize = AdSize.banner;
  AdRequest? _adRequest;
  String? _adUnitId;

  static BannerAdController newInstance({required String adUnitId, String? tag}) {
    return Get.put(
      BannerAdController(),
      tag: "$adUnitId${tag ?? ""}",
    )..setAdUnitId(adUnitId);
  }

  static BannerAdController getInstance({required String adUnitId, String? tag}) {
    return Get.find<BannerAdController>(tag: "$adUnitId${tag ?? ""}");
  }

  Future<void> setupAdsSizeOnScreenBottom() async {
    final AdSize? processedAdSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      ScreenUtils.getScreenWidth().truncate(),
    );
    if (processedAdSize != null) {
      _adSize = processedAdSize;
    }
  }

  void setupAdsSizeInContent(double width) {
    _adSize = AdSize.getCurrentOrientationInlineAdaptiveBannerAdSize(width.truncate());
  }

  void setAdRequest(AdRequest adRequest) {
    _adRequest = adRequest;
  }

  void setAdUnitId(String adUnitId) {
    _adUnitId = AdvertsConfig.instance.isAdTestIds ? AdTestIds.bannerAdId : adUnitId;
  }

  void requestBannerAd() {
    if (AdvertsConfig.instance.isHideAd) return;
    if (_adUnitId == null || _adUnitId!.isEmpty) return;
    if (isAdLoading) return;
    isAdLoading = true;

    AdvertsConfig.instance.generalBannerAdRequest ??= const AdRequest();

    _adRequest = _adRequest ?? AdvertsConfig.instance.generalBannerAdRequest!;

    _bannerAd = BannerAd(
      adUnitId: _adUnitId!,
      request: _adRequest!,
      size: _adSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isBannerAdLoaded.value = true;
          isAdLoading = false;
        },
        onAdFailedToLoad: (ad, error) {
          isBannerAdLoaded.value = false;
          isAdLoading = false;
          ad.dispose();
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {},
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {
          requestBannerAdAgain();
        },
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) {},

        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
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
        },
      ),
    )..load();
  }

  void requestBannerAdAgain() {
    _bannerAd?.dispose();
    _bannerAd = null;
    isBannerAdLoaded.value = false;
    requestBannerAd();
  }

  double get currentBannerAdHeight {
    if (!isBannerAdLoaded.value || _bannerAd == null) {
      return 0;
    }
    return _bannerAd!.size.height.toDouble();
  }

  double get currentBannerAdWidth {
    if (!isBannerAdLoaded.value || _bannerAd == null) {
      return 0;
    }
    return _bannerAd!.size.width.toDouble();
  }

  Widget renderBannerAd() {
    if (AdvertsConfig.instance.isHideAd) {
      return const SizedBox.shrink();
    }

    return Obx(
      () => isBannerAdLoaded.value
          ? SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : const SizedBox.shrink(),
    );
  }
}
