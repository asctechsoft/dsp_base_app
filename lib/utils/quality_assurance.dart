@Deprecated("Use 'package:dsp_base/convenience_imports.dart' instead")
library;

import "dart:io";

import "package:dsp_base/app_material.dart";
import "package:dsp_base/convenience_imports.dart";
import "package:firebase_crashlytics/firebase_crashlytics.dart";
import "package:flutter/foundation.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:get/get.dart";
import "package:share_plus/share_plus.dart";

/// Track if we're already trying to show an overlay to prevent infinite recursion
bool _isShowingOverlay = false;
int _retryCount = 0;
const int _maxRetries = 10;

/// Shows a full-screen error overlay
void _showErrorOverlay({
  required String title,
  required Object error,
  required StackTrace? stackTrace,
  FlutterErrorDetails? flutterErrorDetails,
}) {
  // Prevent infinite recursion
  if (_isShowingOverlay && _retryCount >= _maxRetries) {
    debugLog("ðŸ’¥ ERROR: Max retries reached for showing overlay: $title: $error");
    return;
  }

  // Try to get navigator context from multiple sources
  BuildContext? navigatorContext;

  try {
    // Try GetX context first (most reliable for GetMaterialApp)
    navigatorContext = Get.context;
  } catch (e) {
    // GetX not available yet, try other methods
  }

  // If GetX context not available, try to get from root navigator
  if (navigatorContext == null) {
    try {
      // Try to get from GetX navigator key
      final navigatorKey = Get.key;
      if (navigatorKey.currentContext != null) {
        navigatorContext = navigatorKey.currentContext;
      }
    } catch (e) {
      // Navigator key not available
    }
  }

  // Last resort: try to get root element context
  if (navigatorContext == null) {
    try {
      final rootElement = WidgetsBinding.instance.rootElement;
      if (rootElement != null) {
        navigatorContext = rootElement;
      }
    } catch (e) {
      // Root element not available
    }
  }

  if (navigatorContext == null) {
    // Navigator not ready yet, log and retry
    _retryCount++;
    debugLog("ðŸ’¥ ERROR (Navigator not ready, retry $_retryCount/$_maxRetries): $title: $error");
    // Schedule to show later when navigator is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isShowingOverlay = false; // Reset flag for retry
      _showErrorOverlay(
        title: title,
        error: error,
        stackTrace: stackTrace,
        flutterErrorDetails: flutterErrorDetails,
      );
    });
    return;
  }

  // Reset retry count on success
  _retryCount = 0;
  _isShowingOverlay = true;

  // Show error overlay as a full-screen dialog
  try {
    // Use root navigator to ensure it's shown on top
    showDialog(
      context: navigatorContext,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) {
        _isShowingOverlay = false; // Reset when dialog is shown
        return _ErrorOverlayWidget(
          title: title,
          error: error,
          stackTrace: stackTrace,
          flutterErrorDetails: flutterErrorDetails,
        );
      },
    );
  } catch (e) {
    _isShowingOverlay = false;
    debugLog("ðŸ’¥ ERROR: Failed to show error overlay: $e");
    // If dialog fails, at least log the error
    debugLog("ðŸ’¥ $title: $error\n$stackTrace");
  }
}

/// Full-screen error overlay widget
class _ErrorOverlayWidget extends StatelessWidget {
  const _ErrorOverlayWidget({
    required this.title,
    required this.error,
    this.stackTrace,
    this.flutterErrorDetails,
  });
  final String title;
  final Object error;
  final StackTrace? stackTrace;
  final FlutterErrorDetails? flutterErrorDetails;

  @override
  Widget build(BuildContext context) {
    final errorMessage = error.toString();
    final stackString = stackTrace?.toString() ?? flutterErrorDetails?.stack?.toString() ?? "No stack trace available";
    final library = flutterErrorDetails?.library ?? "Unknown";
    final contextString = flutterErrorDetails?.context?.toString() ?? "";

    return Material(
      color: Colors.black87,
      child: SafeArea(
        child: AppColumn(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade900,
              child: AppRow(
                children: [
                  AppIcon.iconData(
                    Icons.share,
                    tint: Colors.white,
                    onClick: () {
                      final text = "$title\n\nError: $errorMessage\n\nStack trace:\n$stackString";
                      Share.share(text);
                    },
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AppIcon.iconData(
                    Icons.close,
                    tint: Colors.white,
                    onClick: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Error content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: AppColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error message
                    _buildSection(
                      "Error",
                      errorMessage,
                      Colors.red.shade300,
                    ),
                    AppSpacerH16,
                    // Library/Context
                    if (library != "Unknown" || contextString.isNotEmpty)
                      _buildSection(
                        "Location",
                        library + (contextString.isNotEmpty ? "\n$contextString" : ""),
                        Colors.orange.shade300,
                      ),
                    if (library != "Unknown" || contextString.isNotEmpty) AppSpacerH16,
                    // Stack trace with opacity differentiation
                    _buildStackTraceSection(
                      "Stack Trace",
                      stackString,
                      Colors.yellow.shade300,
                    ),
                  ],
                ),
              ),
            ),
            // Footer buttons
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade900,
              child: AppRow(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Continue (Risky)",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  AppSpacerW8,
                  ElevatedButton(
                    onPressed: () => exit(1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                    ),
                    child: const Text("Exit App"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, Color textColor) {
    return AppColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacerH8,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade700),
          ),
          child: SelectableText(
            content,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontFamily: "monospace",
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a stack trace section with project lines highlighted and external lines dimmed
  Widget _buildStackTraceSection(String title, String stackString, Color textColor) {
    final lines = stackString.split("\n");
    final textSpans = <TextSpan>[];

    // Identify project files - these patterns indicate project code
    final projectPatterns = [
      RegExp(r"package:period_cycle/"),
      RegExp(r"package:live_translator/"),
      RegExp(r"package:ez_ai/"),
      RegExp(r"package:dsp_base/"),
      RegExp(r"lib/"),
      RegExp(r"dsp_base/lib/"),
    ];

    // External library patterns (common Flutter/Dart packages)
    final externalPatterns = [
      RegExp(r"package:flutter/"),
      RegExp(r"package:get/"),
      RegExp(r"package:firebase/"),
      RegExp(r"dart:"),
      RegExp(r"package:google_"),
      RegExp(r"package:screen_util/"),
      RegExp(r"package:shared_preferences/"),
      RegExp(r"package:path_provider/"),
    ];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isProjectLine = projectPatterns.any((pattern) => pattern.hasMatch(line));
      final isExternalLine = externalPatterns.any((pattern) => pattern.hasMatch(line));

      // Determine color and opacity based on line type
      Color lineColor;
      double opacity;
      FontWeight fontWeight;

      if (isProjectLine) {
        // Project lines: full opacity, bold
        lineColor = textColor;
        opacity = 1.0;
        fontWeight = FontWeight.w600;
      } else if (isExternalLine) {
        // External lines: 50% opacity
        lineColor = textColor;
        opacity = 0.5;
        fontWeight = FontWeight.normal;
      } else {
        // Other lines: different color (cyan/blue)
        lineColor = Colors.cyan.shade300;
        opacity = 0.8;
        fontWeight = FontWeight.normal;
      }

      textSpans.add(
        TextSpan(
          text: line,
          style: TextStyle(
            color: lineColor.withOpacity(opacity),
            fontSize: 12,
            fontFamily: "monospace",
            fontWeight: fontWeight,
          ),
        ),
      );

      // Add newline except for last line
      if (i < lines.length - 1) {
        textSpans.add(const TextSpan(text: "\n"));
      }
    }

    return AppColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacerH4,
            // Legend - compact horizontal layout
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _buildLegendItem("Project", textColor.withOpacity(1), FontWeight.w600),
                _buildLegendItem("External (50%)", textColor.withOpacity(0.5)),
                _buildLegendItem("Other", Colors.cyan.shade300.withOpacity(0.8)),
              ],
            ),
          ],
        ),
        AppSpacerH8,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade700),
          ),
          child: SelectableText.rich(
            TextSpan(children: textSpans),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, [FontWeight? fontWeight]) {
    return AppRow(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        AppSpacerW4,
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: fontWeight,
          ),
        ),
      ],
    );
  }
}

void commCrashOnAnyErrorInDev() {
  if (CommFigs.IS_PROD_RELEASE) return;

  // 1) Flutter framework errors (build/layout/paint/etc.)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);

    debugLog("ðŸ’¥ FLUTTER ERROR: ${details.exception}\n${details.stack}");

    // Show error overlay instead of crashing
    _showErrorOverlay(
      title: "Flutter Framework Error",
      error: details.exception,
      stackTrace: details.stack,
      flutterErrorDetails: details,
    );
  };

  // 2) Errors not caught by FlutterError (platform dispatcher)
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugLog("ðŸ’¥ PLATFORM UNCAUGHT: $error\n$stack");

    // Show error overlay instead of crashing
    _showErrorOverlay(
      title: "Platform Uncaught Error",
      error: error,
      stackTrace: stack,
    );

    // Return true to indicate error was handled
    return true;
  };

  // 3) Widget build errors - show custom ErrorWidget
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugLog("ðŸ’¥ ERROR WIDGET: ${details.exception}\n${details.stack}");

    // Return a custom error widget that shows the error
    return _ErrorWidgetDisplay(
      errorDetails: details,
    );
  };
}

/// Custom ErrorWidget that displays error information
class _ErrorWidgetDisplay extends StatelessWidget {
  const _ErrorWidgetDisplay({
    required this.errorDetails,
  });
  final FlutterErrorDetails errorDetails;

  @override
  Widget build(BuildContext context) {
    // Show error overlay when this widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showErrorOverlay(
        title: "Widget Build Error",
        error: errorDetails.exception,
        stackTrace: errorDetails.stack,
        flutterErrorDetails: errorDetails,
      );
    });

    // Return a minimal error widget as fallback
    return Material(
      color: Colors.red.shade900,
      child: Center(
        child: AppColumn(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppIcon.iconData(
              Icons.error_outline,
              tint: Colors.white,
              size: 64,
            ),
            AppSpacerH16,
            const Text(
              "Widget Build Error",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacerH8,
            AppText(
              modifier: Modifier.paddingHorizontal(32),
              errorDetails.exception.toString(),
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> commCrashOnTry(
  Object error,
  StackTrace stack, {
  String? hint,
  bool crashWhenCatch = false,
}) async {
  if (CommFigs.IS_PROD_RELEASE) {
    await FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: hint ?? "commCrashOnTry",
    );
    return;
  }

  // Record caught exception properly
  await FirebaseCrashlytics.instance.recordError(
    error,
    stack,
    reason: hint ?? "commCrashOnTry",
    fatal: crashWhenCatch, // if true, shows as Crash event type
  );

  Fluttertoast.showToast(
    msg: 'ðŸ’¥ CATCHED: ${hint != null ? " ($hint)" : ""}: $error\n$stack',
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.CENTER,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16,
  );
  debugLog('ðŸ’¥ CATCHED: ${hint != null ? " ($hint)" : ""}: $error\n$stack');
  if (crashWhenCatch) throw Exception(error);
}
