import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_frequency_tracker.dart';
import 'ad_load_state.dart';
import 'ads_config.dart';
import 'test_ad_ids.dart';

/// Bọc vòng đời Interstitial Ad: tải trước, giữ sẵn, hiện khi cần rồi tự
/// tải lại quảng cáo tiếp theo - app gọi [load] một lần lúc khởi động rồi
/// [showIfReady] ở điểm chuyển màn hình cần hiện quảng cáo, không phải tự
/// quản `InterstitialAd?` như code cũ.
class DspInterstitialAdService {
  DspInterstitialAdService({
    required this.adUnitId,
    DspAdFrequencyTracker? frequencyTracker,
    this.onPaidEvent,
  }) : frequencyTracker = frequencyTracker ?? DspAdFrequencyTracker();

  final String adUnitId;
  final DspAdFrequencyTracker frequencyTracker;

  /// Gọi khi ghi nhận doanh thu quy đổi - xem `DspBannerAdView.onPaidEvent`.
  final void Function(
    Ad ad,
    double valueMicros,
    PrecisionType precision,
    String currencyCode,
  )?
  onPaidEvent;

  InterstitialAd? _ad;
  AdLoadState _state = const AdIdle();
  AdLoadState get state => _state;

  Future<void> load() async {
    if (DspAdsConfig.isHideAd) return;
    _state = const AdLoading();
    final effectiveId = DspAdsConfig.resolveAdUnitId(
      adUnitId: adUnitId,
      androidTestId: DspTestAdIds.androidInterstitial,
      iosTestId: DspTestAdIds.iosInterstitial,
    );
    await InterstitialAd.load(
      adUnitId: effectiveId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
            onPaidEvent?.call(ad, valueMicros, precision, currencyCode);
          };
          _ad = ad;
          _state = const AdLoaded();
        },
        onAdFailedToLoad: (error) {
          _ad = null;
          _state = AdFailed(error.message);
        },
      ),
    );
  }

  /// Hiện quảng cáo nếu đã tải xong và chưa vi phạm [frequencyTracker]. Trả
  /// về `true` nếu đã hiện được. Tự [load] lại cho lần sau sau khi đóng.
  Future<bool> showIfReady() async {
    if (DspAdsConfig.isHideAd) return false;
    final ad = _ad;
    if (ad == null || !frequencyTracker.canShow) return false;

    final done = Completer<void>();
    void finishAndReload() {
      if (!done.isCompleted) done.complete();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        _state = const AdIdle();
        finishAndReload();
        load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _ad = null;
        _state = AdFailed(error.message);
        finishAndReload();
        load();
      },
    );

    frequencyTracker.markShown();
    _state = const AdShown();
    await ad.show();
    await done.future;
    return true;
  }

  void dispose() => _ad?.dispose();
}
