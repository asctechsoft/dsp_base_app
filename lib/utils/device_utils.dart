@Deprecated("Use 'package:dsp_base/convenience_imports.dart' instead")
library;

import "dart:io";
import "dart:math";
import "package:dsp_base/convenience_imports.dart";
import "package:device_info_plus/device_info_plus.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

class DeviceUtils {
  static Future<String> getDeviceId() async {
    String? deviceId;

    try {
      final deviceInfo = DeviceInfoPlugin();

      if (!kIsWeb) {
        if (Platform.isAndroid) {
          const channel = MethodChannel("amobi.module.flutter.common/device_utils");
          deviceId = await channel.invokeMethod("getDeviceId") as String;
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor;
        } else if (Platform.isMacOS) {
          final macInfo = await deviceInfo.macOsInfo;
          deviceId = macInfo.systemGUID;
        } else if (Platform.isWindows) {
          final windowsInfo = await deviceInfo.windowsInfo;
          deviceId = windowsInfo.deviceId;
        } else if (Platform.isLinux) {
          final linuxInfo = await deviceInfo.linuxInfo;
          deviceId = linuxInfo.machineId;
        }
      }
    } catch (e, stack) {
      commCrashOnTry(e, stack, hint: "getDeviceId");
      CommLogger.e("Error getting device id: $e");
    }

    if (deviceId != null && deviceId.isNotEmpty) {
      return deviceId;
    }

    final cachedDeviceId = PrefAssist.getString("DEVICE_ID");
    if (cachedDeviceId.isNotEmpty) {
      return cachedDeviceId;
    }

    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final buffer = StringBuffer();

    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, "0"));
    }

    final generatedId = buffer.toString();
    await PrefAssist.setString("DEVICE_ID", generatedId);
    return generatedId;
  }
}
