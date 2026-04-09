@Deprecated("Use 'package:dsp_base/app_material.dart' instead")
library;

import "package:dsp_base/ui_extensions/app_modifier.dart";
import "package:flutter/material.dart";

extension FlutterLike on AppModifier {
  AppModifier paddingEdgeInsets(EdgeInsets insets) => then((c) => Padding(padding: insets, child: c));

  AppModifier boxDecoration({
    Color? color,
    BorderRadius? borderRadius,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
  }) {
    return then(
      (c) => DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
          border: border,
          boxShadow: boxShadow,
          gradient: gradient,
        ),
        child: c,
      ),
    );
  }

  AppModifier expanded({int flex = 1}) {
    return then((c) => Expanded(flex: flex, child: c));
  }

  AppModifier centered() {
    return then((c) => Center(child: c));
  }

  AppModifier container({
    AlignmentGeometry? alignment,
    EdgeInsets? padding,
    Color? color,
    BoxDecoration? decoration,
    BoxDecoration? foregroundDecoration,
    double? width,
    double? height,
    BoxConstraints? constraints,
    EdgeInsets? margin,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    Clip clipBehavior = Clip.none,
  }) {
    return then(
      (c) => Container(
        alignment: alignment,
        padding: padding,
        color: color,
        decoration: decoration,
        foregroundDecoration: foregroundDecoration,
        width: width,
        height: height,
        constraints: constraints,
        margin: margin,
        transform: transform,
        transformAlignment: transformAlignment,
        clipBehavior: clipBehavior,
      ),
    );
  }

  AppModifier intrinsicWidth() => then((c) => IntrinsicWidth(child: c));

  AppModifier intrinsicHeight() => then((c) => IntrinsicHeight(child: c));
}
