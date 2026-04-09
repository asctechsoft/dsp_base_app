@Deprecated("Use 'package:dsp_base/convenience_imports.dart' instead")
library;

import "package:dsp_base/convenience_imports.dart";
import "package:package_info_plus/package_info_plus.dart";

class MixedUtils {
  /// Returns the current version code (build number) of the app
  /// This corresponds to the build number in pubspec.yaml (e.g., 1.4.17+4 -> returns 4)
  static Future<int> currentVersionCode() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return int.tryParse(packageInfo.buildNumber) ?? 0;
    } catch (e, stack) {
      commCrashOnTry(e, stack, hint: "currentVersionCode");
      // Fallback to hardcoded value if package_info_plus fails
      return 1;
    }
  }

  static int currentTimeMillis() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static int currentTimeSeconds() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  // Click debouncing constants (matching Kotlin implementation)
  static const int timerBetweenClick = 300;
  static const int timerBetweenClickMedium = 650;
  static const int timerBetweenClickLong = 950;
  static const int timerBetweenClickShort = 150;

  static int _lastValidClickTime = 0;

  /// Returns true if click should be blocked (not enough time has passed since last click)
  /// Replicates the Kotlin isNotAllowClick function
  static bool isNotAllowClick([int customTime = timerBetweenClick]) {
    return !_isAllowClick(customTime);
  }

  /// Private helper: returns true if enough time has passed since last click
  /// Updates the last click time if allowed
  static bool _isAllowClick(int customTime) {
    final now = currentTimeMillis();
    if (now - _lastValidClickTime > customTime) {
      _lastValidClickTime = now;
      return true;
    }
    return false;
  }

  static bool isNotAllowClickShort() {
    return isNotAllowClick(timerBetweenClickShort);
  }

  static bool isNotAllowClickLong() {
    return isNotAllowClick(timerBetweenClickLong);
  }
}
