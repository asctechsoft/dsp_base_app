import 'dart:isolate';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Crashlytics wiring: Flutter framework errors, uncaught async errors and
/// errors raised on the root isolate. Call [install] once, right after
/// Firebase is initialised.
class DspCrashlytics {
  DspCrashlytics._();

  static Future<void> install({bool collectionEnabled = true}) async {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      collectionEnabled,
    );
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    Isolate.current.addErrorListener(
      RawReceivePort((pair) async {
        final errorAndStacktrace = pair as List<dynamic>;
        await FirebaseCrashlytics.instance.recordError(
          errorAndStacktrace.first,
          errorAndStacktrace.last as StackTrace?,
          fatal: true,
        );
      }).sendPort,
    );
  }

  /// Breadcrumb logged before an important operation, so a later crash keeps
  /// its context.
  static void log(String message) => FirebaseCrashlytics.instance.log(message);

  /// Records an error caught by try/catch (non-fatal unless [fatal]).
  static Future<void> recordError(
    Object error,
    StackTrace stack, {
    String? reason,
    bool fatal = false,
  }) => FirebaseCrashlytics.instance.recordError(
    error,
    stack,
    reason: reason,
    fatal: fatal,
  );

  static Future<void> setUserId(String id) =>
      FirebaseCrashlytics.instance.setUserIdentifier(id);
}
