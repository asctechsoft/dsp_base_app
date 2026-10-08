import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Immutable snapshot of the user's ad-consent situation.
@immutable
class DspConsentState {
  const DspConsentState({
    this.canRequestAds = true,
    this.isPrivacyOptionsRequired = false,
    this.isResolved = false,
  });

  /// False only while a required consent form is still unresolved.
  final bool canRequestAds;

  /// Whether Settings needs a "manage ad consent" entry (EEA/UK/Switzerland).
  final bool isPrivacyOptionsRequired;

  /// Whether [DspConsentService.gather] has finished at least once.
  final bool isResolved;

  DspConsentState copyWith({
    bool? canRequestAds,
    bool? isPrivacyOptionsRequired,
    bool? isResolved,
  }) => DspConsentState(
    canRequestAds: canRequestAds ?? this.canRequestAds,
    isPrivacyOptionsRequired:
        isPrivacyOptionsRequired ?? this.isPrivacyOptionsRequired,
    isResolved: isResolved ?? this.isResolved,
  );
}

/// GetX service around Google UMP (GDPR / US privacy) consent — must resolve
/// before any ad request for users in the EEA, UK or Switzerland. Wraps
/// `google_mobile_ads`' own `ConsentInformation`/`ConsentForm`. Read [state]
/// inside `Obx` to react to changes.
class DspConsentService extends GetxService {
  static DspConsentService get to => Get.find<DspConsentService>();

  final Rx<DspConsentState> state = const DspConsentState().obs;

  /// Requests a consent info update and shows the form if UMP says one is
  /// needed; resolves once that is settled (obtained, declined or not
  /// required), then refreshes [state]. Set [debugEea] to simulate an EEA
  /// user in dev builds. Never throws.
  Future<void> gather({bool debugEea = false}) async {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(
        consentDebugSettings: debugEea
            ? ConsentDebugSettings(
                debugGeography: DebugGeography.debugGeographyEea,
              )
            : null,
      ),
      () async {
        try {
          await ConsentForm.loadAndShowConsentFormIfRequired((formError) {
            if (formError != null) {
              debugPrint('DspConsentService: form error: ${formError.message}');
            }
          });
        } catch (e) {
          debugPrint(
            'DspConsentService: loadAndShowConsentFormIfRequired failed: $e',
          );
        }
        if (!completer.isCompleted) completer.complete();
      },
      (error) {
        debugPrint(
          'DspConsentService: requestConsentInfoUpdate failed: ${error.message}',
        );
        if (!completer.isCompleted) completer.complete();
      },
    );
    await completer.future;
    await _refresh();
  }

  /// Re-opens the consent choice; returns the up-to-date `canRequestAds`.
  Future<bool> showPrivacyOptionsForm() async {
    await ConsentForm.showPrivacyOptionsForm((formError) {
      if (formError != null) {
        debugPrint(
          'DspConsentService: privacy options error: ${formError.message}',
        );
      }
    });
    await _refresh();
    return state.value.canRequestAds;
  }

  Future<void> _refresh() async {
    try {
      final canRequest = await ConsentInformation.instance.canRequestAds();
      final status = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      state.value = state.value.copyWith(
        canRequestAds: canRequest,
        isPrivacyOptionsRequired:
            status == PrivacyOptionsRequirementStatus.required,
        isResolved: true,
      );
    } catch (e) {
      debugPrint('DspConsentService: refresh failed: $e');
      state.value = state.value.copyWith(isResolved: true);
    }
  }
}
