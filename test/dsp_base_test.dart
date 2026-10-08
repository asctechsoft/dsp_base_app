import 'package:dsp_base/dsp_base.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdLoadState', () {
    test('sealed branches are distinguished by switch', () {
      String describe(AdLoadState s) => switch (s) {
        AdIdle() => 'idle',
        AdLoading() => 'loading',
        AdLoaded() => 'loaded',
        AdFailed(:final error) => 'failed:$error',
        AdShown() => 'shown',
      };
      expect(describe(const AdIdle()), 'idle');
      expect(describe(const AdFailed('timeout')), 'failed:timeout');
    });
  });

  group('DspAdFrequencyTracker', () {
    test('allows the first ad, blocks right after one was shown', () {
      final tracker = DspAdFrequencyTracker(
        minInterval: const Duration(minutes: 1),
      );
      expect(tracker.canShow, true);
      tracker.markShown();
      expect(tracker.canShow, false);
    });
  });

  group('DspAdsConfig.resolveAdUnitId', () {
    tearDown(() => DspAdsConfig.isAdTestIds = false);

    test('returns the real id unless test ids are on', () {
      expect(
        DspAdsConfig.resolveAdUnitId(
          adUnitId: 'real',
          androidTestId: 'a',
          iosTestId: 'i',
        ),
        'real',
      );
    });
  });
}
