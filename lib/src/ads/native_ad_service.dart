import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_load_state.dart';
import 'ads_config.dart';
import 'test_ad_ids.dart';

/// Bọc vòng đời Native Ad tách rời khỏi widget - app gọi [load] sớm (ví dụ
/// lúc khởi động) rồi tự quyết định khi nào render qua [render], thay vì
/// [DspNativeAdView] (tải ngay khi widget mount, không tách được "tải trước,
/// hiện sau" như một bottom sheet chờ đúng lúc mới bung ra).
///
/// Hỗ trợ cả hai cách hiện Native Ad của `google_mobile_ads`: [templateType]
/// (mẫu dựng sẵn của Google) hoặc [factoryId] (factory native tự đăng ký ở
/// `MainActivity`/`AppDelegate` để vẽ theo layout riêng của app) - đúng một
/// trong hai, không cả hai.
class DspNativeAdService {
  DspNativeAdService({
    required this.adUnitId,
    this.templateType,
    this.factoryId,
    this.customOptions,
    this.nativeAdOptions,
    this.onPaidEvent,
  }) : assert(
         (templateType != null) ^ (factoryId != null),
         'Truyền đúng một trong hai: templateType hoặc factoryId.',
       );

  final String adUnitId;
  final TemplateType? templateType;
  final String? factoryId;
  final Map<String, Object>? customOptions;
  final NativeAdOptions? nativeAdOptions;

  /// Gọi khi ghi nhận doanh thu quy đổi - xem `DspBannerAdView.onPaidEvent`.
  final void Function(
    Ad ad,
    double valueMicros,
    PrecisionType precision,
    String currencyCode,
  )?
  onPaidEvent;

  NativeAd? _ad;
  AdLoadState _state = const AdIdle();
  AdLoadState get state => _state;
  bool get isLoaded => _state is AdLoaded && _ad != null;

  Future<void> load() async {
    if (DspAdsConfig.isHideAd) return;
    _state = const AdLoading();
    final effectiveId = DspAdsConfig.resolveAdUnitId(
      adUnitId: adUnitId,
      androidTestId: DspTestAdIds.androidNative,
      iosTestId: DspTestAdIds.iosNative,
    );
    final completer = Completer<void>();
    _ad = NativeAd(
      adUnitId: effectiveId,
      request: const AdRequest(),
      factoryId: factoryId,
      nativeTemplateStyle: templateType != null
          ? NativeTemplateStyle(templateType: templateType!)
          : null,
      customOptions: customOptions,
      nativeAdOptions: nativeAdOptions,
      listener: NativeAdListener(
        onAdLoaded: (_) {
          _state = const AdLoaded();
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _ad = null;
          _state = AdFailed(error.message);
          if (!completer.isCompleted) completer.complete();
        },
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          onPaidEvent?.call(ad, valueMicros, precision, currencyCode);
        },
      ),
    )..load();
    await completer.future;
  }

  /// Widget hiện quảng cáo đã tải - ô trống cùng [height] nếu chưa tải xong,
  /// để layout không giật khi gọi trước khi [isLoaded].
  Widget render({double height = 250}) {
    if (DspAdsConfig.isHideAd) return const SizedBox.shrink();
    final ad = _ad;
    if (!isLoaded || ad == null) {
      return SizedBox(height: height);
    }
    return SizedBox(width: double.infinity, height: height, child: AdWidget(ad: ad));
  }

  void dispose() => _ad?.dispose();
}
