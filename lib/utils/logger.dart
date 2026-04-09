@Deprecated("Use 'package:dsp_base/convenience_imports.dart' instead")
library;

import "package:dsp_base/comm_figs.dart";
import "package:logger/logger.dart";

void log123 = dlog(123);

void dlog(dynamic message) {
  if (!CommFigs.IS_SHOW_TEST_OPTION) return;
  CommLogger.saveToSessionLog("D", message.toString());
  CommLogger.loggerInstance.d(message.toString());
}

void debugLog(dynamic message) {
  if (!CommFigs.IS_SHOW_TEST_OPTION) return;
  CommLogger.saveToSessionLog("D", message.toString());
  CommLogger.loggerInstance.d(message.toString());
}

class CommLogger {
  // Session log buffer â€” only populated on claude/alpha/dev flavors
  static const bool _isSessionLogEnabled =
      CommFigs.IS_CLAUDE || CommFigs.IS_ALPHA || CommFigs.IS_DEV;

  static final List<String> _sessionLogs = [];
  static final DateTime _sessionStartTime = DateTime.now();

  static final Logger loggerInstance = Logger(
    printer: PrettyPrinter(methodCount: 6),
  );

  /// Save a log entry to the in-memory session buffer.
  static void saveToSessionLog(String level, String message) {
    if (!_isSessionLogEnabled) return;
    final now = DateTime.now();
    final timestamp =
        "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}:"
        "${now.second.toString().padLeft(2, '0')}."
        "${now.millisecond.toString().padLeft(3, '0')}";
    _sessionLogs.add("[$timestamp][$level] $message");
  }

  /// Get the full session log as a single string.
  static String getSessionLogText() {
    if (_sessionLogs.isEmpty) return "No logs recorded in this session.";
    final header =
        "=== Session Log ===\n"
        "Started: $_sessionStartTime\n"
        "Entries: ${_sessionLogs.length}\n"
        "===\n\n";
    return header + _sessionLogs.join("\n");
  }

  /// Clear all session logs.
  static void clearSessionLogs() {
    _sessionLogs.clear();
  }

  /// Get the number of session log entries.
  static int get sessionLogCount => _sessionLogs.length;

  static void d(String message) {
    if (!CommFigs.IS_SHOW_TEST_OPTION) return;
    saveToSessionLog("D", message);
    loggerInstance.d(message);
  }

  static void e(String message) {
    if (!CommFigs.IS_SHOW_TEST_OPTION) return;
    saveToSessionLog("E", message);
    loggerInstance.e(message);
  }

  static void i(String message) {
    if (!CommFigs.IS_SHOW_TEST_OPTION) return;
    saveToSessionLog("I", message);
    loggerInstance.i(message);
  }

  static void w(String message) {
    if (!CommFigs.IS_SHOW_TEST_OPTION) return;
    saveToSessionLog("W", message);
    loggerInstance.w(message);
  }

  static void f(String message) {
    if (!CommFigs.IS_SHOW_TEST_OPTION) return;
    saveToSessionLog("F", message);
    loggerInstance.f(message);
  }

  static void log(String message) {
    if (!CommFigs.IS_SHOW_TEST_OPTION) return;
    saveToSessionLog("D", message);
    loggerInstance.log(Level.debug, message);
  }

  static void logError(String message) {
    if (!CommFigs.IS_SHOW_TEST_OPTION) return;
    saveToSessionLog("E", message);
    loggerInstance.log(Level.error, message);
  }

  static void logInfo(String message) {
    if (!CommFigs.IS_SHOW_TEST_OPTION) return;
    saveToSessionLog("I", message);
    loggerInstance.log(Level.info, message);
  }

  static void logWarning(String message) {
    if (!CommFigs.IS_SHOW_TEST_OPTION) return;
    saveToSessionLog("W", message);
    loggerInstance.log(Level.warning, message);
  }

  static void logDebug(String message) {
    if (!CommFigs.IS_SHOW_TEST_OPTION) return;
    saveToSessionLog("D", message);
    loggerInstance.log(Level.debug, message);
  }
}
