# dsp_base

Flutter package for the Firebase and AdMob plumbing shared by ASC apps. Stack: Dart + GetX
(state, DI, lifecycle). UI primitives, localization, prefs, permissions, device info, logging
and in-app review live in `asc_common`.

Add to an app and `import 'package:dsp_base/dsp_base.dart';`.

## Structure (layered, feature-first)

```
lib/dsp_base.dart             # barrel export
lib/src/dsp_base_core.dart    # DspBase — composition root: register() + start()
lib/src/firebase/             # DspFirebaseService, DspAnalytics, DspRemoteConfigRepository (+ static
                              # DspRemoteConfig reads/override), DspCrashlytics, DspAppCheck
lib/src/ads/                  # DspAdsController, DspAdsConfig (Rx switches), Dsp*AdService/View,
                              # DspAdFrequencyTracker, DspTestAdIds
lib/src/consent/              # DspConsentService + immutable DspConsentState (UMP / GDPR)
```

## Conventions

- Services extend `GetxService`, view models extend `GetxController`; all registered permanent via
  `DspBase.register()`; reach them with `X.to` / `Get.find<X>()`. Dependencies are constructor-injected
  (e.g. `DspAdsController(consent: ...)`).
- State is immutable (`DspConsentState`, sealed `AdLoadState`) and exposed as `Rx`; views read it in `Obx`.
- `start()` methods never throw; a failing step is logged and skipped.
- Apps own their keys: Remote Config defaults go to `DspBase.start`, ad unit ids to each service/view.
- Linting: `flutter_lints`. Dart SDK `^3.9.2`.

## Bootstrap

```dart
await DspBase.start(
  remoteConfigDefaults: {...},
  useTestAdIds: kDebugMode,
);
```
