import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Static Remote Config reads plus a persisted local override. The override
/// ([setTestString]) lets a debug/test build pin a value without a live
/// experiment; it is only honoured when the caller passes
/// `testOptionEnabled: true`. Initialisation and change notifications live in
/// [DspRemoteConfigRepository].
class DspRemoteConfig {
  DspRemoteConfig._();

  static const String _testKeyPrefix = 'dsp_remote_config_test_';

  static SharedPreferences? _prefs;

  static Future<void> _ensurePrefs() async =>
      _prefs ??= await SharedPreferences.getInstance();

  static String getString(String key, {bool testOptionEnabled = false}) {
    if (testOptionEnabled) {
      final override = _prefs?.getString(_testKeyPrefix + key);
      if (override != null) return override;
    }
    return FirebaseRemoteConfig.instance.getString(key);
  }

  static bool getBool(String key) => FirebaseRemoteConfig.instance.getBool(key);
  static int getInt(String key) => FirebaseRemoteConfig.instance.getInt(key);
  static double getDouble(String key) =>
      FirebaseRemoteConfig.instance.getDouble(key);

  static Future<void> setTestString(
    String key,
    String value, {
    required bool testOptionEnabled,
  }) async {
    if (!testOptionEnabled) return;
    await _ensurePrefs();
    await _prefs!.setString(_testKeyPrefix + key, value);
  }
}

/// GetX service that initialises Remote Config and bumps [revision] when
/// values may have changed (first fetch, realtime update). The app passes its
/// own `defaults` to [start] — the package hardcodes no key or project. Read
/// values with [DspRemoteConfig] or the convenience getters here.
class DspRemoteConfigRepository extends GetxService {
  DspRemoteConfigRepository({FirebaseRemoteConfig? remoteConfig})
    : _override = remoteConfig;

  final FirebaseRemoteConfig? _override;
  FirebaseRemoteConfig get _rc => _override ?? FirebaseRemoteConfig.instance;

  static DspRemoteConfigRepository get to =>
      Get.find<DspRemoteConfigRepository>();

  /// Bumped whenever values may have changed — read it inside `Obx` to
  /// rebuild on a new fetch or realtime update.
  final RxInt revision = 0.obs;

  /// Whether the first fetch+activate finished (successfully or not).
  final RxBool isReady = false.obs;

  /// Sets defaults, then fetches and activates once. A failed fetch (e.g. no
  /// network on first run) falls back to the defaults and never blocks
  /// startup. Use `Duration.zero` for [minimumFetchInterval] only in dev —
  /// Firebase throttles fetches per day.
  Future<void> start({
    required Map<String, Object> defaults,
    Duration fetchTimeout = const Duration(seconds: 10),
    Duration minimumFetchInterval = const Duration(hours: 1),
  }) async {
    await DspRemoteConfig._ensurePrefs();
    try {
      await _rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: fetchTimeout,
          minimumFetchInterval: minimumFetchInterval,
        ),
      );
      await _rc.setDefaults(defaults);
      await _rc.fetchAndActivate();
    } catch (e) {
      debugPrint('DspRemoteConfigRepository: fetch failed, using defaults: $e');
    }
    isReady.value = true;
    revision.value++;
    try {
      _rc.onConfigUpdated.listen((update) async {
        await _rc.activate();
        revision.value++;
      });
    } catch (_) {
      // Realtime updates unsupported on this platform — fetch-on-start only.
    }
  }

  String getString(String key, {bool testOptionEnabled = false}) =>
      DspRemoteConfig.getString(key, testOptionEnabled: testOptionEnabled);
  bool getBool(String key) => _rc.getBool(key);
  int getInt(String key) => _rc.getInt(key);
  double getDouble(String key) => _rc.getDouble(key);
}
