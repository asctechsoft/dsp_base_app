import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// One Analytics event — `name` + `parameters` in one type instead of free
/// strings scattered through the app. The app defines its own
/// [DspAnalyticsEvent] constants and logs them via [DspAnalytics.log].
@immutable
class DspAnalyticsEvent {
  const DspAnalyticsEvent(this.name, [this.parameters]);

  final String name;
  final Map<String, Object>? parameters;
}

/// GetX service wrapping `FirebaseAnalytics`. Pass an instance to the
/// constructor in tests; otherwise `FirebaseAnalytics.instance` is resolved
/// lazily, so it can be built before Firebase is initialised.
class DspAnalytics extends GetxService {
  DspAnalytics([FirebaseAnalytics? analytics]) : _override = analytics;

  static DspAnalytics get to => Get.find<DspAnalytics>();

  final FirebaseAnalytics? _override;
  FirebaseAnalytics get _analytics => _override ?? FirebaseAnalytics.instance;

  Future<void> log(DspAnalyticsEvent event) =>
      _analytics.logEvent(name: event.name, parameters: event.parameters);

  Future<void> setUserId(String? id) => _analytics.setUserId(id: id);

  Future<void> setUserProperty(String name, String? value) =>
      _analytics.setUserProperty(name: name, value: value);

  Future<void> logScreenView(String screenName) =>
      _analytics.logScreenView(screenName: screenName);
}
