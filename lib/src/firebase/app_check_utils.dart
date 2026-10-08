import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// Firebase App Check activation. Uses the debug providers whenever
/// [useDebugProvider] is set (defaults to `kDebugMode`) — the debug token
/// printed in the log must be registered in the Firebase console — and Play
/// Integrity / App Attest otherwise.
class DspAppCheck {
  DspAppCheck._();

  static Future<void> activate({bool? useDebugProvider}) async {
    final debug = useDebugProvider ?? kDebugMode;
    await FirebaseAppCheck.instance.activate(
      providerAndroid: debug
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple: debug
          ? const AppleDebugProvider()
          : const AppleAppAttestWithDeviceCheckFallbackProvider(),
    );
  }
}
