import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_load_state.dart';
import 'ads_config.dart';
import 'test_ad_ids.dart';

/// Bọc App Open Ad - quảng cáo hiện khi người dùng quay lại app từ nền.
///
/// Quảng cáo đã tải có hạn dùng ([maxCacheDuration], mặc định 4 giờ theo
/// khuyến cáo của Google) - hiện quảng cáo đã tải quá lâu dễ bị tính là vi
/// phạm chính sách AdMob.
class DspAppOpenAdService {
  DspAppOpenAdService({
    required this.adUnitId,
    this.maxCacheDuration = const Duration(hours: 4),
    this.onPaidEvent,
  });

  final String adUnitId;
  final Duration maxCacheDuration;

  /// Gọi khi ghi nhận doanh thu quy đổi - xem `DspBannerAdView.onPaidEvent`.
  final void Function(
    Ad ad,
    double valueMicros,
    PrecisionType precision,
    String currencyCode,
  )?
  onPaidEvent;

  AppOpenAd? _ad;
  DateTime? _loadedAt;
  AdLoadState _state = const AdIdle();
  AdLoadState get state => _state;
  bool _isShowing = false;

  bool get _isAvailable {
    final ad = _ad;
    final loadedAt = _loadedAt;
    if (ad == null || loadedAt == null) return false;
    return DateTime.now().difference(loadedAt) < maxCacheDuration;
  }

  Future<void> load() async {
    if (DspAdsConfig.isHideAd) return;
    _state = const AdLoading();
    final effectiveId = DspAdsConfig.resolveAdUnitId(
      adUnitId: adUnitId,
      androidTestId: DspTestAdIds.androidAppOpen,
      iosTestId: DspTestAdIds.iosAppOpen,
    );
    await AppOpenAd.load(
      adUnitId: effectiveId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          ad.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
            onPaidEvent?.call(ad, valueMicros, precision, currencyCode);
          };
          _ad = ad;
          _loadedAt = DateTime.now();
          _state = const AdLoaded();
        },
        onAdFailedToLoad: (error) {
          _ad = null;
          _state = AdFailed(error.message);
        },
      ),
    );
  }

  /// Hiện quảng cáo nếu đã tải và còn hạn dùng. Trả về `true` nếu đã hiện.
  Future<bool> showIfAvailable() async {
    if (DspAdsConfig.isHideAd) return false;
    if (_isShowing || !_isAvailable) return false;
    final ad = _ad!;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _isShowing = true,
      onAdDismissedFullScreenContent: (ad) {
        _isShowing = false;
        ad.dispose();
        _ad = null;
        _state = const AdIdle();
        load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowing = false;
        ad.dispose();
        _ad = null;
        _state = AdFailed(error.message);
        load();
      },
    );

    _state = const AdShown();
    await ad.show();
    return true;
  }

  void dispose() => _ad?.dispose();
}
