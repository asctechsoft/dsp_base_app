import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'app_check_utils.dart';
import 'crashlytics_utils.dart';

/// GetX service for the Firebase bootstrap: core, then App Check, then
/// Crashlytics. [start] never throws — a failing step is logged and skipped
/// so the app still starts (offline, missing config, ...). Remote Config is
/// initialised separately by `DspRemoteConfigRepository` because its defaults
/// are app-specific.
class DspFirebaseService extends GetxService {
  static DspFirebaseService get to => Get.find<DspFirebaseService>();

  /// Safe to read anywhere (e.g. a zone error handler): true once Firebase
  /// core is up.
  static bool get isCoreReady => Firebase.apps.isNotEmpty;

  final RxBool isInitialized = false.obs;

  /// Returns whether Firebase core came up.
  Future<bool> start({
    FirebaseOptions? options,
    bool enableAppCheck = true,
    bool? appCheckDebugProvider,
    bool enableCrashlytics = true,
  }) async {
    try {
      await Firebase.initializeApp(options: options);
    } catch (e) {
      debugPrint('DspFirebaseService: Firebase.initializeApp failed: $e');
      return false;
    }
    isInitialized.value = true;
    if (enableAppCheck) {
      try {
        await DspAppCheck.activate(useDebugProvider: appCheckDebugProvider);
      } catch (e) {
        debugPrint('DspFirebaseService: App Check activation failed: $e');
      }
    }
    if (enableCrashlytics) {
      try {
        await DspCrashlytics.install();
      } catch (e) {
        debugPrint('DspFirebaseService: Crashlytics install failed: $e');
      }
    }
    return true;
  }
}
