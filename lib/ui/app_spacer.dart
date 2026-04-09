// ignore_for_file: constant_identifier_names

@Deprecated("Use 'package:dsp_base/app_material.dart' instead")
library;

import "package:dsp_base/comm_figs.dart";
import "package:dsp_base/ui_extensions/app_modifier.dart";
import "package:dsp_base/ui_extensions/app_modifier_compose.dart";
import "package:flutter/material.dart";

class AppSpacer extends StatelessWidget {
  const AppSpacer({
    super.key,
    this.modifier = Modifier,
  });

  final AppModifier modifier;

  @override
  Widget build(BuildContext context) {
    return const SizedBox().apply(modifier);
  }
}

class AppSpacerWeight extends StatelessWidget {
  const AppSpacerWeight({
    super.key,
    this.modifier = Modifier,
    this.weight = 1,
  });

  final AppModifier modifier;
  final int weight;

  @override
  Widget build(BuildContext context) {
    return Expanded(flex: weight, child: const SizedBox()).apply(
      modifier.conditional(
        CommFigs.SIZE_DEBUG,
        onTrue: (modifier) {
          return modifier.minSize(2.1).backgroundColorDebug();
        },
      ),
    );
  }
}

const SizedBox AppEmpty = SizedBox();

const AppSpacerS AppSpacerS2 = AppSpacerS(2);
const AppSpacerS AppSpacerS4 = AppSpacerS(4);
const AppSpacerS AppSpacerS6 = AppSpacerS(6);
const AppSpacerS AppSpacerS8 = AppSpacerS(8);
const AppSpacerS AppSpacerS10 = AppSpacerS(10);
const AppSpacerS AppSpacerS12 = AppSpacerS(12);
const AppSpacerS AppSpacerS16 = AppSpacerS(16);
const AppSpacerS AppSpacerS20 = AppSpacerS(20);
const AppSpacerS AppSpacerS24 = AppSpacerS(24);
const AppSpacerS AppSpacerS28 = AppSpacerS(28);
const AppSpacerS AppSpacerS32 = AppSpacerS(32);
const AppSpacerS AppSpacerS36 = AppSpacerS(36);
const AppSpacerS AppSpacerS40 = AppSpacerS(40);
const AppSpacerS AppSpacerS44 = AppSpacerS(44);

const AppSpacerH AppSpacerH2 = AppSpacerH(2);
const AppSpacerH AppSpacerH4 = AppSpacerH(4);
const AppSpacerH AppSpacerH6 = AppSpacerH(6);
const AppSpacerH AppSpacerH8 = AppSpacerH(8);
const AppSpacerH AppSpacerH10 = AppSpacerH(10);
const AppSpacerH AppSpacerH12 = AppSpacerH(12);
const AppSpacerH AppSpacerH16 = AppSpacerH(16);
const AppSpacerH AppSpacerH20 = AppSpacerH(20);
const AppSpacerH AppSpacerH24 = AppSpacerH(24);
const AppSpacerH AppSpacerH28 = AppSpacerH(28);
const AppSpacerH AppSpacerH32 = AppSpacerH(32);
const AppSpacerH AppSpacerH36 = AppSpacerH(36);
const AppSpacerH AppSpacerH40 = AppSpacerH(40);
const AppSpacerH AppSpacerH44 = AppSpacerH(44);

const AppSpacerW AppSpacerW2 = AppSpacerW(2);
const AppSpacerW AppSpacerW4 = AppSpacerW(4);
const AppSpacerW AppSpacerW6 = AppSpacerW(6);
const AppSpacerW AppSpacerW8 = AppSpacerW(8);
const AppSpacerW AppSpacerW10 = AppSpacerW(10);
const AppSpacerW AppSpacerW12 = AppSpacerW(12);
const AppSpacerW AppSpacerW16 = AppSpacerW(16);
const AppSpacerW AppSpacerW20 = AppSpacerW(20);
const AppSpacerW AppSpacerW24 = AppSpacerW(24);
const AppSpacerW AppSpacerW28 = AppSpacerW(28);
const AppSpacerW AppSpacerW32 = AppSpacerW(32);
const AppSpacerW AppSpacerW36 = AppSpacerW(36);
const AppSpacerW AppSpacerW40 = AppSpacerW(40);
const AppSpacerW AppSpacerW44 = AppSpacerW(44);

class AppSpacerS extends StatelessWidget {
  const AppSpacerS(
    this.size, {
    super.key,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: size, width: size).apply(
      Modifier.conditional(
        CommFigs.SIZE_DEBUG,
        onTrue: (modifier) {
          return modifier.backgroundColorDebug();
        },
      ),
    );
  }
}

class AppSpacerH extends StatelessWidget {
  const AppSpacerH(this.height, {super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height).apply(
      Modifier.conditional(
        CommFigs.SIZE_DEBUG,
        onTrue: (modifier) {
          return modifier.minSize(2.1).backgroundColorDebug();
        },
      ),
    );
  }
}

class AppSpacerW extends StatelessWidget {
  const AppSpacerW(this.width, {super.key});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width).apply(
      Modifier.conditional(
        CommFigs.SIZE_DEBUG,
        onTrue: (modifier) {
          return modifier.minSize(2.1).backgroundColorDebug();
        },
      ),
    );
  }
}
