// ignore_for_file: prefer_constructors_over_static_methods

@Deprecated("Use 'package:dsp_base/advertisements.dart' instead")
library;

import "dart:io";

import "package:dsp_base/advertisements/ad_test_ids.dart";
import "package:dsp_base/advertisements/adverts_config.dart";
import "package:dsp_base/app_material.dart";
import "package:get/get.dart";
import "package:google_mobile_ads/google_mobile_ads.dart";

class NativeAdController extends GetxController {
  RxBool isAdLoaded = false.obs;
  NativeAd? _nativeAd;
  bool isAdLoading = false;
  String? adUnitId;
  String factoryId = "";
  double adHeight = 220;
  NativeAdOptions? nativeAdOptions;

  VoidCallback? onAdOpened;
  VoidCallback? onAdClicked;

  static NativeAdController newInstance({
    required String adUnitId,
    required String factoryId,
    String? tag,
    double? adHeight,
    NativeAdOptions? nativeAdOptions,
  }) {
    final controller =
        Get.put(
            NativeAdController(),
            tag: "$adUnitId$factoryId${tag ?? ""}",
          )
          ..setAdUnitId(adUnitId)
          ..setFactoryId(factoryId);

    if (adHeight != null) {
      controller.setAdHeight(adHeight);
    }
    if (nativeAdOptions != null) {
      controller.nativeAdOptions = nativeAdOptions;
    }

    return controller;
  }

  static NativeAdController getInstance({required String adUnitId, required String factoryId, String? tag}) {
    return Get.find<NativeAdController>(tag: "$adUnitId$factoryId${tag ?? ""}");
  }

  void release() {
    _nativeAd?.dispose();
    _nativeAd = null;

    isAdLoaded.value = false;
    isAdLoading = false;
    adUnitId = null;
    factoryId = "";
    adHeight = 220;
    nativeAdOptions = null;
    onAdOpened = null;
    onAdClicked = null;
  }

  @override
  void dispose() {
    release();
    super.dispose();
  }

  void requestAd() {
    // TODO: Make native ad for ios
    if (!Platform.isAndroid) return;

    if (AdvertsConfig.instance.isHideAd) return;

    if (isAdLoaded.value) return;

    if (adUnitId == null || adUnitId!.isEmpty) return;

    if (isAdLoading) return;
    isAdLoading = true;

    _nativeAd = NativeAd(
      adUnitId: adUnitId!,
      factoryId: factoryId,
      request: const AdRequest(),
      nativeAdOptions: nativeAdOptions,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          isAdLoaded.value = true;
          isAdLoading = false;
        },
        onAdFailedToLoad: (ad, error) {
          isAdLoaded.value = false;
          isAdLoading = false;
          ad.dispose();
        },
        onAdOpened: (Ad ad) {
          onAdOpened?.call();
        },
        onAdClicked: (Ad ad) {
          onAdClicked?.call();
        },
        onAdClosed: (Ad ad) {
          requestAdAgain();
        },
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

  void requestAdAgain() {
    // TODO: Make native ad for ios
    if (!Platform.isAndroid) return;

    _nativeAd?.dispose();
    _nativeAd = null;
    isAdLoaded.value = false;
    requestAd();
  }

  void setAdUnitId(String adUnitId) {
    this.adUnitId = AdvertsConfig.instance.isAdTestIds ? AdTestIds.nativeAdId : adUnitId;
  }

  void setFactoryId(String factoryId) {
    this.factoryId = factoryId;
  }

  void setAdHeight(double adHeight) {
    this.adHeight = adHeight;
  }

  void setOnAdOpened(VoidCallback onAdOpened) {
    this.onAdOpened = onAdOpened;
  }

  void setOnAdClicked(VoidCallback onAdClicked) {
    this.onAdClicked = onAdClicked;
  }

  Widget renderAd() {
    // TODO: Make native ad for ios
    if (!Platform.isAndroid) {
      return const SizedBox.shrink();
    }

    if (AdvertsConfig.instance.isHideAd) {
      return const SizedBox.shrink();
    }

    return Obx(
      () => _nativeAd != null && isAdLoaded.value
          ? SizedBox(
              width: double.infinity,
              height: adHeight,
              child: AdWidget(ad: _nativeAd!),
            )
          : const SizedBox.shrink(),
    );
  }
}
