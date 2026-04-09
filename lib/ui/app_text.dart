@Deprecated("Use 'package:dsp_base/app_material.dart' instead")
library;

import "package:dsp_base/app_material.dart";
import "package:dsp_base/comm_figs.dart";

class AppText extends Text {
  const AppText(
    super.data, {
    super.key,
    super.textAlign = TextAlign.start,
    super.softWrap = true,
    super.overflow = TextOverflow.clip,
    super.maxLines,
    super.semanticsLabel,
    super.style,
    super.strutStyle,
    super.textWidthBasis = TextWidthBasis.parent,
    super.textHeightBehavior,
    this.modifier = Modifier,
  });
  final AppModifier modifier;

  @override
  Widget build(BuildContext context) {
    return super
        .build(context)
        .apply(
          modifier.conditional(
            CommFigs.SIZE_DEBUG,
            onTrue: (modifier) {
              return modifier.backgroundColorDebug();
            },
          ),
        );
  }
}
