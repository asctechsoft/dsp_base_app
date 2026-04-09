@Deprecated("Use 'package:dsp_base/app_material.dart' instead")
library;

import "package:dsp_base/app_material.dart";
import "package:dsp_base/comm_figs.dart";

/// Wrapper that builds the Column as its direct child.
/// This preserves the Flex parent relationship for Flexible/Expanded children
/// when modifiers are applied.
class _FlexModifierWrapper extends StatelessWidget {
  const _FlexModifierWrapper({
    required this.columnBuilder,
  });

  final Widget Function() columnBuilder;

  @override
  Widget build(BuildContext context) {
    return columnBuilder();
  }
}

class AppColumn extends StatelessWidget {
  const AppColumn({
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

    final column = Column(
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

    // If no modifier, return Column directly
    if (finalModifier.isEmpty) {
      return column;
    }

    // Apply modifiers to a wrapper widget instead of the Column itself
    // This preserves the Flex parent relationship for Flexible/Expanded children
    return finalModifier.apply(
      _FlexModifierWrapper(
        columnBuilder: () => column,
      ),
    );
  }
}

class AppColumnCentered extends StatelessWidget {
  const AppColumnCentered({
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

    final column = Column(
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

    // If no modifier, return Column directly
    if (finalModifier.isEmpty) {
      return column;
    }

    // Apply modifiers to a wrapper widget instead of the Column itself
    // This preserves the Flex parent relationship for Flexible/Expanded children
    return finalModifier.apply(
      _FlexModifierWrapper(
        columnBuilder: () => column,
      ),
    );
  }
}
