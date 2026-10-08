import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_frequency_tracker.dart';
import 'ad_load_state.dart';
import 'ads_config.dart';
import 'test_ad_ids.dart';

/// Bọc vòng đời Rewarded Ad - trả phần thưởng qua callback
/// `onUserEarnedReward` khi người dùng xem hết quảng cáo.
class DspRewardedAdService {
  DspRewardedAdService({
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

  RewardedAd? _ad;
  AdLoadState _state = const AdIdle();
  AdLoadState get state => _state;

  Future<void> load() async {
    if (DspAdsConfig.isHideAd) return;
    _state = const AdLoading();
    final effectiveId = DspAdsConfig.resolveAdUnitId(
      adUnitId: adUnitId,
      androidTestId: DspTestAdIds.androidRewarded,
      iosTestId: DspTestAdIds.iosRewarded,
    );
    await RewardedAd.load(
      adUnitId: effectiveId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
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

  /// Hiện quảng cáo, gọi [onUserEarnedReward] khi người dùng xem xong. Trả
  /// về `true` nếu đã hiện được quảng cáo - **không** đồng nghĩa người dùng
  /// nhận thưởng, họ vẫn có thể thoát giữa chừng.
  Future<bool> showIfReady({
    required void Function(AdWithoutView ad, RewardItem reward)
    onUserEarnedReward,
  }) async {
    if (DspAdsConfig.isHideAd) return false;
    final ad = _ad;
    if (ad == null) return false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        _state = const AdIdle();
        load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _ad = null;
        _state = AdFailed(error.message);
        load();
      },
    );

    frequencyTracker.markShown();
    _state = const AdShown();
    await ad.show(onUserEarnedReward: onUserEarnedReward);
    return true;
  }

  void dispose() => _ad?.dispose();
}
