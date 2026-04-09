@Deprecated("Use 'package:dsp_base/app_material.dart' instead")
library;

import "package:dsp_base/app_material.dart";
import "package:dsp_base/comm_figs.dart";
import "package:flutter_svg/svg.dart";

class AppIcon extends StatelessWidget {
  const AppIcon(
    this.iconPath, {
    super.key,
    this.size = 24,
    this.clickZone = 48,
    this.tint,
    this.onClick,
    this.autoMirror = false,
    this.clickZonePadding,
    this.modifier = Modifier,
  }) : iconData = null;

  const AppIcon.iconData(
    this.iconData, {
    super.key,
    this.size = 24,
    this.clickZone = 48,
    this.tint,
    this.onClick,
    this.autoMirror = false,
    this.clickZonePadding,
    this.modifier = Modifier,
  }) : iconPath = "";
  final String iconPath;
  final IconData? iconData;
  final double size;
  final double clickZone;
  final Color? tint;
  final Function()? onClick;
  final bool autoMirror;
  final EdgeInsetsGeometry? clickZonePadding;
  final AppModifier modifier;

  @override
  Widget build(BuildContext context) {
    if (CommFigs.IS_DEBUG && iconPath.isEmpty && iconData == null) {
      throw Exception("Icon path or icon data must be provided");
    }

    var icon = iconData != null
        ? Icon(iconData, size: size, color: tint)
        : iconPath.endsWith(".svg")
        ? SvgPicture.asset(
            iconPath,
            width: size,
            height: size,
            colorFilter: tint != null ? ColorFilter.mode(tint!, BlendMode.srcIn) : null,
          )
        : Image.asset(
            iconPath,
            width: size,
            height: size,
            color: tint,
            colorBlendMode: tint != null ? BlendMode.srcIn : null,
          );

    if (autoMirror && Directionality.of(context) == TextDirection.rtl) {
      icon = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..scale(-1.0, 1, 1),
        child: icon,
      );
    }

    if (onClick != null) {
      return AppBoxCentered(
        modifier:
            Modifier //
            .size(clickZone),
        children: [
          IconButton(onPressed: onClick, icon: icon, padding: clickZonePadding),
        ],
      ).apply(
        modifier.conditional(
          CommFigs.SIZE_DEBUG,
          onTrue: (modifier) {
            return modifier.backgroundColorDebug();
          },
        ),
      );
    }

    return icon.apply(
      modifier.conditional(
        CommFigs.SIZE_DEBUG,
        onTrue: (modifier) {
          return modifier.backgroundColorDebug();
        },
      ),
    );
  }
}
