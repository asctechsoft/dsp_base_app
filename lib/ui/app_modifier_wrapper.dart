@Deprecated("Use 'package:dsp_base/app_material.dart' instead")
library;

import "package:dsp_base/app_material.dart";

class AppModifierWrapper extends StatelessWidget {
  const AppModifierWrapper({
    required this.child,
    required this.modifier,
    super.key,
  });
  final AppModifier modifier;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child.apply(modifier);
  }
}
