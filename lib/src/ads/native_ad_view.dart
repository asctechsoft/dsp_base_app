import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_config.dart';
import 'test_ad_ids.dart';

/// Widget hiện Native Ad, tự tải/dispose theo vòng đời widget - app chỉ cần
/// đặt vào cây UI. Hỗ trợ cả hai cách render của `google_mobile_ads`: mẫu
/// dựng sẵn của Google ([DspNativeAdView.new], `NativeTemplateStyle` - không
/// cần code native, nhưng KHÔNG co giãn full màn hình được, chỉ hiện đúng
/// kích thước tự nhiên của nội dung) hoặc factory riêng đã đăng ký native
/// ([DspNativeAdView.factory] - layout tự thiết kế, có thể full màn hình
/// thật sự; xem `DspNativeAdService` nếu cần tách load khỏi render).
///
/// Tự áp [DspAdsConfig.isHideAd]/[DspAdsConfig.isAdTestIds] như
/// [DspBannerAdView] - xem đó để biết lý do.
class DspNativeAdView extends StatefulWidget {
  const DspNativeAdView({
    super.key,
    required this.adUnitId,
    this.templateType = TemplateType.medium,
    this.height = 320,
    this.onPaidEvent,
  }) : factoryId = null;

  /// A native ad rendered by a factory registered natively
  /// (`GoogleMobileAdsPlugin.registerNativeAdFactory` ở Android/iOS) thay vì
  /// mẫu dựng sẵn của Google - dùng khi app cần layout riêng theo đúng theme,
  /// hoặc cần full màn hình thật sự (mẫu dựng sẵn không co giãn được).
  const DspNativeAdView.factory({
    super.key,
    required this.adUnitId,
    required String this.factoryId,
    this.height = 320,
    this.onPaidEvent,
  }) : templateType = null;

  final String adUnitId;
  final TemplateType? templateType;
  final String? factoryId;
  final double height;

  /// Gọi khi ghi nhận doanh thu quy đổi - xem [DspBannerAdView.onPaidEvent].
  final void Function(
    Ad ad,
    double valueMicros,
    PrecisionType precision,
    String currencyCode,
  )?
  onPaidEvent;

  @override
  State<DspNativeAdView> createState() => _DspNativeAdViewState();
}

class _DspNativeAdViewState extends State<DspNativeAdView> {
  NativeAd? _ad;
  bool _loaded = false;
  late final Worker _hideWorker;

  @override
  void initState() {
    super.initState();
    _hideWorker = ever<bool>(DspAdsConfig.isHideAdRx, (_) => _onHideChanged());
    _load();
  }

  void _onHideChanged() {
    if (!mounted) return;
    if (!DspAdsConfig.isHideAd && _ad == null) _load();
    setState(() {});
  }

  void _load() {
    if (DspAdsConfig.isHideAd) return;
    final effectiveId = DspAdsConfig.resolveAdUnitId(
      adUnitId: widget.adUnitId,
      androidTestId: DspTestAdIds.androidNative,
      iosTestId: DspTestAdIds.iosNative,
    );
    _ad = NativeAd(
      adUnitId: effectiveId,
      request: const AdRequest(),
      factoryId: widget.factoryId,
      nativeTemplateStyle: widget.templateType != null
          ? NativeTemplateStyle(templateType: widget.templateType!)
          : null,
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _ad = null;
        },
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          widget.onPaidEvent?.call(ad, valueMicros, precision, currencyCode);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _hideWorker.dispose();
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (DspAdsConfig.isHideAd) return const SizedBox.shrink();
    if (!_loaded || _ad == null) return SizedBox(height: widget.height);
    return SizedBox(height: widget.height, child: AdWidget(ad: _ad!));
  }
}
