@Deprecated("Use 'package:dsp_base/app_material.dart' instead")
library;

import "package:flutter/widgets.dart";

typedef _Wrap = Widget Function(Widget child);

@immutable
class AppModifier {
  const AppModifier() : _ops = const [];
  const AppModifier._(this._ops);
  final List<_Wrap> _ops;

  AppModifier then(_Wrap op) => AppModifier._([..._ops, op]);
  AppModifier operator +(AppModifier other) => AppModifier._([..._ops, ...other._ops]);

  Widget apply(Widget child) => _ops.reversed.fold<Widget>(child, (w, op) => op(w));

  /// Returns true if this modifier has no operations (is empty)
  bool get isEmpty => _ops.isEmpty;
}

// Top-level constant for convenience - you can import this as 'Modifier' if needed
// ignore: constant_identifier_names
const AppModifier Modifier = AppModifier();

extension ModifierApply on Widget {
  Widget apply(AppModifier modifier) => modifier.apply(this);
}
