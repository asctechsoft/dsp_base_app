@Deprecated("Use 'package:dsp_base/convenience_imports.dart' instead")
library;

import "dart:io";
import "package:dsp_base/comm_app.dart";
import "package:dsp_base/convenience_imports.dart";
import "package:firebase_analytics/firebase_analytics.dart";
import "package:firebase_crashlytics/firebase_crashlytics.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:firebase_remote_config/firebase_remote_config.dart";
import "package:flutter/services.dart";

class FirebaseAssist {
  // ================================ Remote Config ================================
  static FirebaseRemoteConfig? _mFirebaseRemoteConfig;
  static bool _isRCFetchCompleted = false;
  static bool isAnalyticsEnabled = true;

  static bool get isRCFetchCompleted => _isRCFetchCompleted;

  static Future<void> fetchRemoteConfig({
    required String xmlFilePath,
    VoidCallback? onSuccessFetch,
    VoidCallback? onCompleteFetch,
  }) async {
    final remoteConfig = _mFirebaseRemoteConfig ?? FirebaseRemoteConfig.instance;

    if (_mFirebaseRemoteConfig == null) {
      _mFirebaseRemoteConfig = remoteConfig;

      final configSettings = RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: CommFigs.IS_SHOW_TEST_OPTION ? Duration.zero : const Duration(hours: 2),
      );

      await remoteConfig.setConfigSettings(configSettings);

      // Load defaults from XML file
      final defaults = await _loadDefaultsFromXmlFile(xmlFilePath);
      await remoteConfig.setDefaults(defaults);
    }

    if (PrefAssist.getBoolean(PrefComm.FETCH_RC_ONCE)) {
      await remoteConfig.activate();
      await _onRCActivateComplete(onSuccessFetch);
      _isRCFetchCompleted = true;
      onCompleteFetch?.call();

      final lastFetchTime = PrefAssist.getInt(PrefComm.FETCH_RC_SUCCESS_MILLIS);
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      if (currentTime - lastFetchTime < CommFigs.MILLIS_HOUR) {
        return;
      }

      try {
        await remoteConfig.fetch();
        await PrefAssist.setInt(PrefComm.FETCH_RC_SUCCESS_MILLIS, currentTime);
        // AdvertsConfig.instance.updateEnableAdsBooleans(); // Uncomment when AdvertsConfig is available
      } catch (e, stack) {
        commCrashOnTry(e, stack, hint: "fetchRemoteConfig");
        debugLog("Firebase fetchRC Error: $e");
      }
    } else {
      debugLog("Firebase fetchRC not fetched");
      await remoteConfig.activate();

      try {
        final success = await remoteConfig.fetchAndActivate();
        debugLog("Firebase fetchRC success: $success");
        if (success) {
          final currentTime = DateTime.now().millisecondsSinceEpoch;
          await PrefAssist.setInt(
            PrefComm.FETCH_RC_SUCCESS_MILLIS,
            currentTime,
          );
          await _onRCActivateComplete(onSuccessFetch);
        } else {
          debugLog("Firebase fetchRC Error: fetchAndActivate failed");
        }
      } catch (e, stack) {
        commCrashOnTry(e, stack, hint: "fetchRemoteConfig");
        debugLog("Firebase fetchRC Error: $e");
      }

      _isRCFetchCompleted = true;
      onCompleteFetch?.call();
    }
  }

  static Future<void> _onRCActivateComplete(
    VoidCallback? onSuccessFetch,
  ) async {
    PrefAssist.setBoolean(PrefComm.FETCH_RC_ONCE, true);
    onSuccessFetch?.call();
  }

  static Future<Map<String, dynamic>> _loadDefaultsFromXmlFile(
    String xmlFilePath,
  ) async {
    try {
      // Load XML file content
      final xmlContent = await rootBundle.loadString(xmlFilePath);

      // Parse XML and convert to Map
      // Note: This is a simplified parser. You might want to use a proper XML parser
      // like xml package for more complex XML structures
      final defaults = <String, dynamic>{};

      // Parse custom XML format: <entry><key>KEY</key><value>VALUE</value></entry>
      final entryPattern = RegExp(
        r"<entry>\s*<key>([^<]+)</key>\s*<value>([^<]+)</value>\s*</entry>",
        multiLine: true,
      );

      // Extract all entries
      for (final Match match in entryPattern.allMatches(xmlContent)) {
        final key = match.group(1)!.trim();
        final value = match.group(2)!.trim();

        // Try to parse as different types
        if (value.toLowerCase() == "true" || value.toLowerCase() == "false") {
          defaults[key] = value.toLowerCase() == "true";
        } else if (RegExp(r"^\d+$").hasMatch(value)) {
          defaults[key] = int.tryParse(value) ?? 0;
        } else {
          defaults[key] = value;
        }
      }

      return defaults;
    } catch (e, stack) {
      commCrashOnTry(e, stack, hint: "loadDefaultsFromXmlFile");
      if (CommFigs.IS_SHOW_TEST_OPTION) {
        throw Exception("Failed to load XML defaults from $xmlFilePath: $e");
      }
      return <String, dynamic>{};
    }
  }

  // ================================ Analytics ================================
  static void logPaidAdvertsClicked(Map<String, Object>? params) {
    if (!isAnalyticsEnabled) return;
    FirebaseAnalytics.instance.logEvent(
      name: "paid_ad_impression",
      parameters: params,
    );
  }

  static void logPaidAdvertsX5Clicked(Map<String, Object>? params) {
    if (!isAnalyticsEnabled) return;
    FirebaseAnalytics.instance.logEvent(
      name: "ad_rev_imp_x5",
      parameters: params,
    );
  }

  static void logBttnClicked({
    required String tagScreen,
    required String tagButton,
    String? tagDialog,
  }) {
    if (!isAnalyticsEnabled) return;

    var btnName = "${tagScreen}_";
    if (tagDialog != null) btnName += "${tagDialog}_";
    btnName += tagButton;
    final params = <String, Object>{
      "click_btn_ev_name": btnName,
      "click_btn_ev_time": MixedUtils.currentTimeSeconds() - CommApp.startupTimeInSeconds,
    };

    FirebaseAnalytics.instance.logEvent(name: "click_btn_ev", parameters: params);
    FirebaseCrashlytics.instance.log("Button clicked: $btnName");
  }

  static void logScreenView(String screenName) {
    if (!isAnalyticsEnabled) return;
    final params = <String, Object>{
      "screen_view_ev_name": screenName,
      "screen_view_ev_delta_t": MixedUtils.currentTimeSeconds() - CommApp.foregroundTimeInSeconds,
      "screen_view_ev_time": MixedUtils.currentTimeSeconds() - CommApp.startupTimeInSeconds,
    };
    FirebaseAnalytics.instance.logEvent(name: "screen_view_ev", parameters: params);
    FirebaseCrashlytics.instance.log("Screen viewed: $screenName");
  }

  static void logOpenAppEvent(String where) {
    if (!isAnalyticsEnabled) return;
    final currentHour = DateTime.now().hour;
    final params = <String, Object>{
      "open_app_from_ev_where_time": "OAF_ev_${where}_$currentHour",
      "open_app_ev_is_first_time": PrefAssist.getBoolean("open_app_ev_is_first_time", defaultValue: true) ? "1" : "0",
    };
    FirebaseAnalytics.instance.logEvent(name: "open_app_from_ev", parameters: params);
  }

  // ================================ App Check ================================
  static Future<void> setupAppCheckCustomProviderFactory() async {
    if (!Platform.isAndroid) return;

    const ch = MethodChannel("amobi.module.flutter.common/firebase_utils");
    await ch.invokeMethod("setupAppCheckCustomProviderFactory");
  }

  // ================================ Cloud Messaging ================================
  static String? _fetchedFcmToken;

  static Future<String?> getFcmToken() async {
    if (!Platform.isAndroid && !Platform.isIOS) return null;

    if (_fetchedFcmToken != null) return _fetchedFcmToken;

    try {
      _fetchedFcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e, stack) {
      commCrashOnTry(e, stack, hint: "getFcmToken");
      _fetchedFcmToken = null;
    }

    return _fetchedFcmToken;
  }

  static void startListenOnFcmTokenRefresh({Function(String newToken)? onTokenRefresh}) {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _fetchedFcmToken = newToken;
      onTokenRefresh?.call(newToken);
      debugLog("Firebase FCM Token refreshed: $newToken");
    });
  }

  // Listen to FCM message interactions (when user taps on notification from killed/background state)
  static Future<void> startListenOnFcmMessageInteract({
    required Function(RemoteMessage message) onMessageInteract,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    // Get any messages which caused the application to open from a terminated state.
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      onMessageInteract(initialMessage);
    }

    // Also handle any interaction when the app is in the background using a stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageInteract);
  }

  static void startListeningIncomingMessage({Function(RemoteMessage message)? onMessage}) {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugLog("Firebase onMessage received: ${message.messageId}");

      onMessage?.call(message);
    });
  }
}
