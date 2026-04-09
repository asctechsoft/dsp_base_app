import "dart:async";

import "package:dsp_base/advertisements.dart";
import "package:dsp_base/convenience_imports.dart";
import "package:dsp_base/gdpr/gdpr_assist.dart";
import "package:firebase_analytics/firebase_analytics.dart";
import "package:google_mobile_ads/google_mobile_ads.dart";

/// GDPR Consent management class using Google UMP SDK
/// Handles user consent collection and AdMob initialization
class GDPRConsent {
  GDPRConsent({this.onConsentFinished}) {
    _initializeConsent();
  }
  static bool isGDPRNotFinished = true;

  final Function(bool)? onConsentFinished;

  bool _isGDPRInitSuccess = false;
  bool _isMobileAdsInitializeCalled = false;

  /// Initialize GDPR consent flow
  Future<void> _initializeConsent() async {
    if (AdvertsConfig.instance.isHideAd) {
      isGDPRNotFinished = false;

      updateAnalyticsConsentStatus();
      onConsentFinished?.call(false);
      return;
    }

    final consentInformation = ConsentInformation.instance;

    // Set tag for under age of consent. false means users are not under age
    final params = ConsentRequestParameters(
      consentDebugSettings: CommFigs.IS_ADD_TEST_DEVICE
          ? ConsentDebugSettings(
              debugGeography: DebugGeography.debugGeographyEea,
              testIdentifiers: [
                await AdvertsConfig.instance.getAdMobDeviceAndroidId(),
              ],
            )
          : null,
      tagForUnderAgeOfConsent: false,
    );

    final gdprIsEnabled = await GDPRAssist.isGDPR();
    final gdprCanShowAds = await GDPRAssist.canShowAds();

    if (gdprIsEnabled && !gdprCanShowAds) {
      debugLog("GDPRConsent: reset $gdprIsEnabled $gdprCanShowAds");
      consentInformation.reset();
    } else {
      debugLog("GDPRConsent: not reset $gdprIsEnabled $gdprCanShowAds");
    }

    // Set up timeout for GDPR initialization
    Timer(const Duration(milliseconds: 15 * CommFigs.MILLIS_SECOND), () {
      if (!_isGDPRInitSuccess) {
        _initializeMobileAdsSdk(true);
      }
    });

    // Request consent information update
    consentInformation.requestConsentInfoUpdate(
      params,
      () {
        _isGDPRInitSuccess = true;

        ConsentForm.loadAndShowConsentFormIfRequired((loadAndShowError) {
          if (loadAndShowError != null) {
            // Consent gathering failed.
            debugLog(
              "${loadAndShowError.errorCode}: ${loadAndShowError.message}",
            );
          }

          // Consent has been gathered.
          _initializeMobileAdsSdk(false);
        });
      },
      (FormError requestConsentError) {
        // Consent gathering failed.
        debugLog(
          "${requestConsentError.errorCode}: ${requestConsentError.message}",
        );
        _initializeMobileAdsSdk(false);
      },
    );

    // Check if you can initialize the Google Mobile Ads SDK in parallel
    // while checking for new consent information. Consent obtained in
    // the previous session can be used to request ads.
    if (await consentInformation.canRequestAds()) {
      _initializeMobileAdsSdk(false);
    }
  }

  /// Initialize Mobile Ads SDK
  void _initializeMobileAdsSdk(bool isTimeOutGDPR) {
    if (_isMobileAdsInitializeCalled) {
      return;
    }
    _isMobileAdsInitializeCalled = true;
    isGDPRNotFinished = false;

    updateAnalyticsConsentStatus();
    onConsentFinished?.call(isTimeOutGDPR);
  }

  /// Check if privacy options entry point is required
  static Future<bool> isPrivacyOptionsRequired() async {
    return await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
  }

  /// Present the privacy options form
  static void showPrivacyOptionsForm() {
    ConsentForm.showPrivacyOptionsForm((formError) {
      if (formError != null) {
        debugLog("${formError.errorCode}: ${formError.message}");
      }
    });
  }

  /// Check if ads can be requested
  static Future<bool> canRequestAds() {
    return ConsentInformation.instance.canRequestAds();
  }

  /// Reset consent state (for testing purposes only)
  static void resetConsentState() {
    ConsentInformation.instance.reset();
  }

  /// Wait for GDPR consent to complete and return whether it timed out
  static Future<bool> waitForConsent() {
    final completer = Completer<bool>();

    GDPRConsent(
      onConsentFinished: (isTimeout) {
        if (!completer.isCompleted) {
          completer.complete(isTimeout);
        }
      },
    );

    return completer.future;
  }

  static Future<void> updateAnalyticsConsentStatus() async {
    final gdprIsEnabled = await GDPRAssist.isGDPR();
    final gdprCanShowAds = !gdprIsEnabled || await GDPRAssist.canShowAds();
    final gdprCanShowPersonalizedAds = !gdprIsEnabled || await GDPRAssist.canShowPersonalizedAds();

    await FirebaseAnalytics.instance.setConsent(
      analyticsStorageConsentGranted: true,
      functionalityStorageConsentGranted: gdprCanShowAds,
      adStorageConsentGranted: gdprCanShowAds,
      adUserDataConsentGranted: gdprCanShowAds,
      adPersonalizationSignalsConsentGranted: gdprCanShowPersonalizedAds,
      personalizationStorageConsentGranted: gdprCanShowPersonalizedAds,
    );
  }
}
