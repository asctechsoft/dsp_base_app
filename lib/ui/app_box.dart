@Deprecated("Use 'package:dsp_base/app_material.dart' instead")
library;

import "package:dsp_base/comm_figs.dart";
import "package:dsp_base/ui_extensions/app_modifier.dart";
import "package:dsp_base/ui_extensions/app_modifier_compose.dart";
import "package:flutter/material.dart";

class AppBox extends StatelessWidget {
  const AppBox({
    super.key,
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.fit = StackFit.loose,
    this.clipBehavior = Clip.hardEdge,
    this.children = const <Widget>[],
    this.modifier = Modifier,
  });
  final List<Widget> children;
  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final StackFit fit;
  final Clip clipBehavior;
  final AppModifier modifier;

  @override
  Widget build(BuildContext context) {
    final stack = Stack(
      key: key,
      alignment: alignment,
      textDirection: textDirection,
      fit: fit,
      clipBehavior: clipBehavior,
      children: children,
    );
    return stack.apply(
      modifier.conditional(
        CommFigs.SIZE_DEBUG,
        onTrue: (modifier) {
          return modifier.borderColorDebug();
        },
      ),
    );
  }
}

class AppBoxCentered extends StatelessWidget {
  const AppBoxCentered({
    super.key,
    this.textDirection,
    this.fit = StackFit.loose,
    this.clipBehavior = Clip.hardEdge,
    this.children = const <Widget>[],
    this.modifier = Modifier,
  });
  final List<Widget> children;
  final AlignmentGeometry alignment = Alignment.center;
  final TextDirection? textDirection;
  final StackFit fit;
  final Clip clipBehavior;
  final AppModifier modifier;

  @override
  Widget build(BuildContext context) {
    final stack = Stack(
      key: key,
      alignment: alignment,
      textDirection: textDirection,
      fit: fit,
      clipBehavior: clipBehavior,
      children: children,
    );
    return stack.apply(
      modifier.conditional(
        CommFigs.SIZE_DEBUG,
        onTrue: (modifier) {
          return modifier.borderColorDebug();
        },
      ),
    );
  }
}
