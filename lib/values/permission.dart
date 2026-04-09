import "package:permission_handler/permission_handler.dart";

enum PermissionTypes {
  calendar,
  camera,
  contacts,
  location,
  locationAlways,
  locationWhenInUse,
  mediaLibrary,
  microphone,
  phone,
  photos,
  photosAddOnly,
  reminders,
  sensors,
  sms,
  speech,
  storage,
  ignoreBatteryOptimizations,
  notification,
  accessMediaLocation,
  activityRecognition,
  unknown,
  bluetooth,
  manageExternalStorage,
  systemAlertWindow,
  requestInstallPackages,
  appTrackingTransparency,
  criticalAlerts,
  accessNotificationPolicy,
  bluetoothScan,
  bluetoothAdvertise,
  bluetoothConnect,
  nearbyWifiDevices,
  videos,
  audio,
  scheduleExactAlarm,
  sensorsAlways,
  calendarWriteOnly,
  calendarFullAccess,
  assistant,
  backgroundRefresh,
}

enum PermissionResult {
  denied,
  granted,
  restricted,
  limited,
  permanentlyDenied,
  provisional,
  unknown,
}

Permission getCorrectPermission(PermissionTypes permission) {
  switch (permission) {
    case PermissionTypes.calendar:
      return Permission.calendar;
    case PermissionTypes.camera:
      return Permission.camera;
    case PermissionTypes.contacts:
      return Permission.contacts;
    case PermissionTypes.location:
      return Permission.location;
    case PermissionTypes.locationAlways:
      return Permission.locationAlways;
    case PermissionTypes.locationWhenInUse:
      return Permission.locationWhenInUse;
    case PermissionTypes.mediaLibrary:
      return Permission.mediaLibrary;
    case PermissionTypes.microphone:
      return Permission.microphone;
    case PermissionTypes.phone:
      return Permission.phone;
    case PermissionTypes.photos:
      return Permission.photos;
    case PermissionTypes.photosAddOnly:
      return Permission.photosAddOnly;
    case PermissionTypes.reminders:
      return Permission.reminders;
    case PermissionTypes.sensors:
      return Permission.sensors;
    case PermissionTypes.sms:
      return Permission.sms;
    case PermissionTypes.speech:
      return Permission.speech;
    case PermissionTypes.storage:
      return Permission.storage;
    case PermissionTypes.ignoreBatteryOptimizations:
      return Permission.ignoreBatteryOptimizations;
    case PermissionTypes.notification:
      return Permission.notification;
    case PermissionTypes.accessMediaLocation:
      return Permission.accessMediaLocation;
    case PermissionTypes.activityRecognition:
      return Permission.activityRecognition;
    case PermissionTypes.unknown:
      return Permission.unknown;
    case PermissionTypes.bluetooth:
      return Permission.bluetooth;
    case PermissionTypes.manageExternalStorage:
      return Permission.manageExternalStorage;
    case PermissionTypes.systemAlertWindow:
      return Permission.systemAlertWindow;
    case PermissionTypes.requestInstallPackages:
      return Permission.requestInstallPackages;
    case PermissionTypes.appTrackingTransparency:
      return Permission.appTrackingTransparency;
    case PermissionTypes.criticalAlerts:
      return Permission.criticalAlerts;
    case PermissionTypes.accessNotificationPolicy:
      return Permission.accessNotificationPolicy;
    case PermissionTypes.bluetoothScan:
      return Permission.bluetoothScan;
    case PermissionTypes.bluetoothAdvertise:
      return Permission.bluetoothAdvertise;
    case PermissionTypes.bluetoothConnect:
      return Permission.bluetoothConnect;
    case PermissionTypes.nearbyWifiDevices:
      return Permission.nearbyWifiDevices;
    case PermissionTypes.videos:
      return Permission.videos;
    case PermissionTypes.audio:
      return Permission.audio;
    case PermissionTypes.scheduleExactAlarm:
      return Permission.scheduleExactAlarm;
    case PermissionTypes.sensorsAlways:
      return Permission.sensorsAlways;
    case PermissionTypes.calendarWriteOnly:
      return Permission.calendarWriteOnly;
    case PermissionTypes.calendarFullAccess:
      return Permission.calendarFullAccess;
    case PermissionTypes.assistant:
      return Permission.assistant;
    case PermissionTypes.backgroundRefresh:
      return Permission.backgroundRefresh;
  }
}

PermissionResult getCorrectPermissionResult(PermissionStatus permissionStatus) {
  switch (permissionStatus) {
    case PermissionStatus.denied:
      return PermissionResult.denied;
    case PermissionStatus.granted:
      return PermissionResult.granted;
    case PermissionStatus.restricted:
      return PermissionResult.restricted;
    case PermissionStatus.limited:
      return PermissionResult.limited;
    case PermissionStatus.permanentlyDenied:
      return PermissionResult.permanentlyDenied;
    case PermissionStatus.provisional:
      return PermissionResult.provisional;
  }
}
