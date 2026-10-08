/// Giới hạn tần suất hiện quảng cáo toàn màn hình - tránh spam Interstitial/
/// AppOpen liên tục làm phiền người dùng.
///
/// Hai điều kiện độc lập, cả hai đều phải qua thì [canShow] mới `true`:
/// khoảng cách thời gian ([minInterval]) và số màn hình đã đi qua kể từ lần
/// hiện gần nhất ([minScreenCount]). Cả hai ngưỡng đọc từ đâu (hardcode hay
/// Remote Config) là việc của app gọi - class này không biết gì về Remote
/// Config, chỉ đếm.
class DspAdFrequencyTracker {
  DspAdFrequencyTracker({
    this.minInterval = const Duration(minutes: 1),
    this.minScreenCount = 0,
  });

  final Duration minInterval;

  /// Số màn hình tối thiểu phải đi qua kể từ lần hiện gần nhất trước khi
  /// được hiện tiếp - `0` tắt hẳn điều kiện này. App tự tăng qua
  /// [onScreenView] (ví dụ từ `NavigatorObserver`/GetX `routingCallback`).
  final int minScreenCount;

  DateTime? _lastShownAt;
  int _screensSinceLastShown = 0;

  /// Gọi mỗi khi app chuyển màn hình - nuôi điều kiện [minScreenCount].
  void onScreenView() => _screensSinceLastShown++;

  /// Có được hiện quảng cáo ngay bây giờ không.
  bool get canShow {
    final last = _lastShownAt;
    if (last != null && DateTime.now().difference(last) < minInterval) {
      return false;
    }
    if (minScreenCount > 0 && _screensSinceLastShown < minScreenCount) {
      return false;
    }
    return true;
  }

  /// Gọi ngay sau khi quảng cáo đã hiện thành công.
  void markShown() {
    _lastShownAt = DateTime.now();
    _screensSinceLastShown = 0;
  }
}
