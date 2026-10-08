/// dsp_base — Firebase (core, Analytics, Crashlytics, App Check, Remote
/// Config) and AdMob (consent, banner/native/interstitial/rewarded/app-open)
/// for ASC apps. GetX-based. UI primitives and other
/// shared helpers live in `asc_common`.
library;

// Firebase.
export 'src/firebase/analytics_utils.dart';
export 'src/firebase/app_check_utils.dart';
export 'src/firebase/crashlytics_utils.dart';
export 'src/firebase/dsp_firebase.dart';
export 'src/firebase/remote_config_utils.dart';

// Ads.
export 'src/ads/ad_frequency_tracker.dart';
export 'src/ads/ad_load_state.dart';
export 'src/ads/ad_preload_service.dart';
export 'src/ads/ads_config.dart';
export 'src/ads/app_open_ad_service.dart';
export 'src/ads/banner_ad_view.dart';
export 'src/ads/dsp_ads.dart';
export 'src/ads/interstitial_ad_service.dart';
export 'src/ads/native_ad_service.dart';
export 'src/ads/native_ad_view.dart';
export 'src/ads/rewarded_ad_service.dart';
export 'src/ads/test_ad_ids.dart';

// Consent (UMP / GDPR).
export 'src/consent/dsp_consent.dart';

// Composition root.
export 'src/dsp_base_core.dart';
