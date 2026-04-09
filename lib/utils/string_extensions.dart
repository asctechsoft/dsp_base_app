@Deprecated("Use 'package:dsp_base/convenience_imports.dart' instead")
library;

extension StringExtension on String {
  String capitaliseEachWord() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
