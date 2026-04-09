@Deprecated("Use 'package:dsp_base/app_material.dart' instead")
library;

import "package:dsp_base/app_material.dart";
import "package:dsp_base/comm_figs.dart";

/// Wrapper that builds the Row as its direct child.
/// This preserves the Flex parent relationship for Flexible/Expanded children
/// when modifiers are applied.
class _FlexModifierWrapper extends StatelessWidget {
  const _FlexModifierWrapper({
    required this.rowBuilder,
  });

  final Widget Function() rowBuilder;

  @override
  Widget build(BuildContext context) {
    return rowBuilder();
  }
}

class AppRow extends StatelessWidget {
  const AppRow({
    super.key,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.spacing = 0.0,
    this.modifier = Modifier,
    this.children = const <Widget>[],
  });
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final double spacing;
  final AppModifier modifier;

  @override
  Widget build(BuildContext context) {
    final finalModifier = modifier.conditional(
      CommFigs.SIZE_DEBUG,
      onTrue: (modifier) {
        return modifier.borderColorDebug();
      },
    );

    final row = Row(
      key: key,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      spacing: spacing,
      children: children,
    );

    // If no modifier, return Row directly
    if (finalModifier.isEmpty) {
      return row;
    }

    // Apply modifiers to a wrapper widget instead of the Row itself
    // This preserves the Flex parent relationship for Flexible/Expanded children
    return finalModifier.apply(
      _FlexModifierWrapper(
        rowBuilder: () => row,
      ),
    );
  }
}

class AppRowCentered extends StatelessWidget {
  const AppRowCentered({
    super.key,
    this.mainAxisSize = MainAxisSize.max,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.spacing = 0.0,
    this.modifier = Modifier,
    this.children = const <Widget>[],
  });
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final double spacing;
  final AppModifier modifier;

  @override
  Widget build(BuildContext context) {
    final finalModifier = modifier.conditional(
      CommFigs.SIZE_DEBUG,
      onTrue: (modifier) {
        return modifier.borderColorDebug();
      },
    );

    final row = Row(
      key: key,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      spacing: spacing,
      children: children,
    );

    // If no modifier, return Row directly
    if (finalModifier.isEmpty) {
      return row;
    }

    // Apply modifiers to a wrapper widget instead of the Row itself
    // This preserves the Flex parent relationship for Flexible/Expanded children
    return finalModifier.apply(
      _FlexModifierWrapper(
        rowBuilder: () => row,
      ),
    );
  }
}
