@Deprecated("Use 'package:dsp_base/convenience_imports.dart' instead")
library;

import "package:dsp_base/values/permission.dart";
import "package:permission_handler/permission_handler.dart";

class PermissionUtils {
  static Future<void>? _activeRequest;

  static Future<PermissionResult> requestPermission(
    PermissionTypes permission,
  ) async {
    // Wait for any in-flight request to finish before starting a new one.
    if (_activeRequest != null) {
      await _activeRequest;
    }
    final completer = _doRequestPermission(permission);
    _activeRequest = completer;
    try {
      return await completer;
    } finally {
      _activeRequest = null;
    }
  }

  static Future<PermissionResult> _doRequestPermission(
    PermissionTypes permission,
  ) async {
    final status = await getCorrectPermission(permission).request();
    return getCorrectPermissionResult(status);
  }

  static Future<Map<PermissionTypes, PermissionResult>> requestPermissions(
    List<PermissionTypes> permissions,
  ) async {
    // Wait for any in-flight request to finish before starting a new one.
    if (_activeRequest != null) {
      await _activeRequest;
    }
    final statuses = <PermissionTypes, PermissionResult>{};
    for (final permission in permissions) {
      final status = await getCorrectPermission(permission).request();
      statuses[permission] = getCorrectPermissionResult(status);
    }
    return statuses;
  }

  static Future<PermissionResult> checkPermissionStatus(
    PermissionTypes permission,
  ) async {
    final status = await getCorrectPermission(permission).status;
    return getCorrectPermissionResult(status);
  }

  static Future<Map<PermissionTypes, PermissionResult>> checkPermissionStatuses(
    List<PermissionTypes> permissions,
  ) async {
    final statuses = <PermissionTypes, PermissionResult>{};
    for (final permission in permissions) {
      final status = await getCorrectPermission(permission).status;
      statuses[permission] = getCorrectPermissionResult(status);
    }
    return statuses;
  }

  static Future<bool> shouldShowRequestRationale(
    PermissionTypes permission,
  ) async {
    final shouldShow = await getCorrectPermission(
      permission,
    ).shouldShowRequestRationale;
    return shouldShow;
  }
}
