// ignore_for_file: constant_identifier_names, non_constant_identifier_names

@Deprecated("Use 'package:dsp_base/convenience_imports.dart' instead")
library;

import "package:dsp_base/convenience_imports.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:system_info_plus/system_info_plus.dart";

export "package:dsp_base/utils/quality_assurance.dart";

class CommFigs {
  // Build Config Flags
  static const bool IS_DEBUG = !kReleaseMode;
  static const bool IS_ALPHA = appFlavor == "Alpha" || appFlavor == "alpha";
  static const bool IS_DEV = appFlavor == "Dev" || appFlavor == "dev";
  static const bool IS_PRODUCT = appFlavor == "Product" || appFlavor == "product";
  static const bool IS_CLAUDE = appFlavor == "Claude" || appFlavor == "claude";
  static const bool IS_PROD_RELEASE = IS_PRODUCT && !IS_DEBUG;

  static const bool SIZE_DEBUG = false;

  static const bool IS_SHOW_TEST_OPTION = IS_CLAUDE || IS_ALPHA || IS_DEV;
  static const bool IS_ADD_TEST_DEVICE = IS_SHOW_TEST_OPTION;

  // Device Memory Flags
  static bool IS_LOWER_6GB_DEVICE = false;
  static bool IS_WEAK_DEVICE = false;
  static bool IS_SUPER_WEAK_DEVICE = false;

  // Time constants
  static const int MILLIS_SECOND = 1000;
  static const int MILLIS_MINUTE = 60 * MILLIS_SECOND;
  static const int MILLIS_HOUR = 60 * MILLIS_MINUTE;
  static const int MILLIS_DAY = 24 * MILLIS_HOUR;

  static const int SECONDS_MINUTE = 60;
  static const int SECONDS_HOUR = 60 * SECONDS_MINUTE;
  static const int SECONDS_DAY = 24 * SECONDS_HOUR;

  static const int MINUTES_DAY = 24 * 60;

  /// Classify device based on RAM memory
  /// Equivalent to the Kotlin classifyDevice() function
  static Future<void> classifyDevice() async {
    try {
      // Get physical memory in MB using system_info_plus
      final physicalMemoryMB = await SystemInfoPlus.physicalMemory;
      if (physicalMemoryMB == null) {
        // If memory detection fails, assume it's a weak device for safety
        setDeviceMemoryFlags(
          isLower6GB: false,
          isWeak: false,
          isSuperWeak: false,
        );
        return;
      }
      final totalMemGigabyte = physicalMemoryMB / 1024.0;

      // Set device capability flags based on memory
      if (totalMemGigabyte < 2) {
        setDeviceMemoryFlags(isLower6GB: true, isWeak: true, isSuperWeak: true);
      } else if (totalMemGigabyte < 3.6) {
        setDeviceMemoryFlags(
          isLower6GB: true,
          isWeak: true,
          isSuperWeak: false,
        );
      } else if (totalMemGigabyte < 5.6) {
        setDeviceMemoryFlags(
          isLower6GB: true,
          isWeak: false,
          isSuperWeak: false,
        );
      } else {
        setDeviceMemoryFlags(
          isLower6GB: false,
          isWeak: false,
          isSuperWeak: false,
        );
      }
    } catch (e, stack) {
      // If detection fails, assume it's a weak device for safety
      setDeviceMemoryFlags(isLower6GB: true, isWeak: true, isSuperWeak: true);
      commCrashOnTry(e, stack, hint: "classifyDevice");
    }
  }

  /// Set device memory flags
  /// Equivalent to the Kotlin setDeviceMemoryFlags() function
  static void setDeviceMemoryFlags({
    required bool isLower6GB,
    required bool isWeak,
    required bool isSuperWeak,
  }) {
    IS_LOWER_6GB_DEVICE = isLower6GB;
    IS_WEAK_DEVICE = isWeak;
    IS_SUPER_WEAK_DEVICE = isSuperWeak;
  }
}
