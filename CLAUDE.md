# dsp_base

Flutter plugin package providing common utilities, UI components, ads, Firebase integration, GDPR compliance, and localization (87 languages) shared across Amobi mobile apps. Consumed as a local path dependency by `live_translator`.

## Project Structure

```
lib/
  comm_app.dart           # Main app wrapper (CommApp, commRunApp())
  comm_figs.dart          # Build flags & device classification
  app_localize.dart       # Localization manager (XML-based, 87 langs)
  app_material.dart       # Barrel export for all UI components
  convenience_imports.dart # Barrel export for all utilities
  rateme.dart / rateme5stars.dart # In-app rating dialogs
  advertisements/         # AdMob ads (banner, interstitial, rewarded, native, open)
  gdpr/                   # GDPR consent via MethodChannel
  ui/                     # Custom widgets (AppColumn, AppRow, AppBox, AppText, etc.)
  ui_extensions/          # Modifier system (AppModifier DSL-like styling)
  utils/                  # Firebase, prefs, device, permissions, logging, screen utils
  values/                 # Permission enums & mappers
  type_utils/             # Generic data structures (Pair<K,V>)
  xml_strings/            # 87 language directories with strings.xml
  assets/                 # SVG icons
android/                  # Kotlin native (MethodChannels for Firebase, GDPR, device)
ios/                      # Swift native plugin
```

## Code Style & Conventions

- **Linter**: `pedantic_mono` with strict rules
- **Formatter line width**: 120 characters
- **Quotes**: Double quotes (`prefer_double_quotes: true`)
- **Imports**: Always use package imports (`always_use_package_imports: true`)
- **File naming**: snake_case, no spaces
- **Const constructors**: Required (enforced as error)
- **Required named params**: Always first
- **Annotate overrides**: Yes
- **No `print()`**: Use logger utilities instead
- **Prefer final locals**: Yes
- **Sort constructors first**: Yes

## Key Patterns

- **Modifier pattern**: DSL-like widget styling via `AppModifier` â€” compose with `.then()`, apply with `.apply(widget)`. Avoids deep widget nesting.
- **Singleton config**: `AdvertsConfig.instance`, `CommFigs` static flags, `CommLocalize` static localization.
- **MethodChannel wrappers**: Native code accessed via channels (`GDPRAssist`, `DeviceUtils`, Firebase utils). Namespace: `amobi.module.flutter.common/`.
- **Barrel files**: Import `app_material.dart` for UI, `convenience_imports.dart` for utils.
- **App bootstrap**: Use `commRunApp()` instead of Flutter's `runApp()` â€” handles Firebase, Crashlytics, SharedPrefs, RemoteConfig, localization init.
- **Responsive design**: `flutter_screenutil` with design size 360x800. Text scale clamped 0.85xâ€“1.3x.
- **Localization**: XML-based strings (Android convention), parsed at runtime, locale switching via GetX.
- **Custom widgets**: Prefixed with `App*` (AppColumn, AppRow, AppBox, AppText, etc.).

## Build Flavors

- **Alpha**: Debug screens + test options enabled
- **Dev**: Test options enabled
- **Product**: Release mode

## Device Classification (by RAM)

- SUPER_WEAK: < 2GB
- WEAK: 2â€“3.6GB
- LOWER_6GB: 3.6â€“5.6GB
- NORMAL: > 5.6GB

## Key Dependencies

- **State/routing**: GetX
- **Firebase**: core, analytics, crashlytics, messaging, remote_config, app_check
- **Ads**: google_mobile_ads (AdMob)
- **UI**: flutter_screenutil, flutter_svg, flutter_animate
- **Storage**: shared_preferences
- **Localization**: xml (parser), flutter_localizations

## Commands

```bash
# Analyze (run from dsp_base/)
flutter analyze

# Run tests (run from dsp_base/)
flutter test
```

**Note:** Build scripts (`build.py`) live in the root `live_translator/` project, not here. They delegate to `dsp_base/build_helper.py` internally.

## Important Notes

- This is a **plugin package**, not a standalone app â€” it's consumed as a dependency by other Flutter projects (e.g., live_translator).
- Android namespace: `amobi.module.flutter.common`
- Android: compileSdk 36, Kotlin 2.1.0, Java 11
- iOS: minimum 13.0, Swift 5.0
- Generated files (`*.g.dart`, `*.freezed.dart`) are excluded from analysis.
