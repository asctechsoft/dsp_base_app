@Deprecated("Use 'package:dsp_base/convenience_imports.dart' instead")
library;

import "package:dsp_base/comm_figs.dart";
import "package:dsp_base/utils/pref_assist.dart";
import "package:firebase_remote_config/firebase_remote_config.dart";

class RconfAssist {
  static const String _testTag = "RconfAssist_";

  static bool getBoolean(String key) {
    if (CommFigs.IS_SHOW_TEST_OPTION) {
      return PrefAssist.getBoolean(
        _testTag + key,
        defaultValue: FirebaseRemoteConfig.instance.getBool(key),
      );
    } else {
      return FirebaseRemoteConfig.instance.getBool(key);
    }
  }

  static void setTestBoolean(String key, bool value) {
    if (!CommFigs.IS_SHOW_TEST_OPTION) return;
    PrefAssist.setBoolean(_testTag + key, value);
  }

  static int getInt(String key) {
    if (CommFigs.IS_SHOW_TEST_OPTION) {
      return PrefAssist.getInt(
        _testTag + key,
        defaultValue: FirebaseRemoteConfig.instance.getInt(key),
      );
    } else {
      return FirebaseRemoteConfig.instance.getInt(key);
    }
  }

  static void setTestInt(String key, int value) {
    if (!CommFigs.IS_SHOW_TEST_OPTION) return;
    PrefAssist.setInt(_testTag + key, value);
  }

  static String getString(String key) {
    if (CommFigs.IS_SHOW_TEST_OPTION) {
      return PrefAssist.getString(
        _testTag + key,
        defaultValue: FirebaseRemoteConfig.instance.getString(key),
      );
    } else {
      return FirebaseRemoteConfig.instance.getString(key);
    }
  }

  static void setTestString(String key, String value) {
    if (!CommFigs.IS_SHOW_TEST_OPTION) return;
    PrefAssist.setString(_testTag + key, value);
  }

  static void removeTestKey(String key) {
    if (!CommFigs.IS_SHOW_TEST_OPTION) return;
    PrefAssist.removeKey(_testTag + key);
  }
}
