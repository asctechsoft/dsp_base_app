import "dart:io";
import "package:dsp_base/app_material.dart";
import "package:flutter_emoji/flutter_emoji.dart";
import "package:get/get.dart";
import "package:in_app_review/in_app_review.dart";

final InAppReview inAppReview = InAppReview.instance;

class RateMe5StarsDialogCustomizer {
  RateMe5StarsDialogCustomizer({
    this.message,
    this.submitButtonText,
    this.submitButton,
    this.cancelButtonText,
    this.cancelButton,
    this.backgroundWidget,
    this.dialogBackgroundColor = Colors.white,
    this.dialogHeader,
    this.messageTextStyle = const TextStyle(fontSize: 14),
    this.dialogBorderRadius = const BorderRadius.all(Radius.circular(20)),
    this.padding,
  });
  String? message;

  TextStyle? messageTextStyle;

  String? submitButtonText;
  Widget Function(String text, Function() onTap)? submitButton;

  String? cancelButtonText;
  Widget Function(String text, Function() onTap)? cancelButton;

  Color? dialogBackgroundColor;
  Widget Function()? backgroundWidget;

  Widget Function()? dialogHeader;

  BorderRadius? dialogBorderRadius;

  EdgeInsetsDirectional? padding;
}

class RateMe5StarsDialog extends StatefulWidget {
  const RateMe5StarsDialog({super.key, this.customizer, this.onSubmit, this.onCancel});

  final Function()? onSubmit;
  final Function()? onCancel;

  final RateMe5StarsDialogCustomizer? customizer;

  @override
  State<StatefulWidget> createState() => RateMe5StarsDialogViewState();

  static Future<void> show({
    required BuildContext context,
    Function()? onSubmit,
    Function()? onCancel,
    Function()? onDismiss,
    RateMe5StarsDialogCustomizer? customizer,
  }) async {
    if (Platform.isIOS) {
      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
      } else {
        inAppReview.openStoreListing();
      }
      return;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) => RateMe5StarsDialog(
        customizer: customizer ?? RateMe5StarsDialogCustomizer(),
        onCancel: onCancel,
        onSubmit: onSubmit,
      ),
    );

    onDismiss?.call();
  }
}

class RateMe5StarsDialogViewState extends State<RateMe5StarsDialog> {
  int rating = 0;
  final emojiParser = EmojiParser();

  bool isRatingBarAnimatingOnDialogShow = true;

  Widget _renderHeader() {
    if (widget.customizer?.dialogHeader != null) {
      return widget.customizer!.dialogHeader!.call();
    }

    return AppText(
      emojiParser.get("grinning_face_with_star_eyes").code,
      style: const TextStyle(fontSize: 72),
    );
  }

  Widget _renderMessageNotice() {
    return AppText(
      widget.customizer?.message ?? "rate_me_5_stars_message".tr,
      modifier: Modifier.padding(top: 8),
      style: widget.customizer?.messageTextStyle,
      textAlign: TextAlign.center,
    );
  }

  Widget _renderButtons() {
    final cancelBtnText = widget.customizer?.cancelButtonText ?? "rate_me_5_stars_later_btn".tr;
    final submitBtnText = widget.customizer?.submitButtonText ?? "rate_me_5_stars_rate_btn".tr;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: widget.customizer?.cancelButton != null
                ? widget.customizer!.cancelButton!.call(cancelBtnText, _onClickCancel)
                : ElevatedButton(
                    onPressed: _onClickCancel,
                    child: AppText(
                      cancelBtnText,
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
          AppSpacerW8,
          Expanded(
            child: widget.customizer?.submitButton != null
                ? widget.customizer!.submitButton!.call(submitBtnText, _onClickSubmit)
                : ElevatedButton(
                    onPressed: _onClickSubmit,
                    child: AppText(
                      submitBtnText,
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: widget.customizer?.dialogBorderRadius ?? BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: widget.customizer?.dialogBackgroundColor ?? Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppBox(
        alignment: Alignment.topCenter,
        children: [
          widget.customizer?.backgroundWidget?.call() ?? const SizedBox.shrink(),
          Container(
            padding: widget.customizer?.padding ?? const EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: AppColumnCentered(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSpacerH16,
                _renderHeader(),
                _renderMessageNotice(),
                AppSpacerH16,
                AppSpacerH16,
                _renderButtons(),
                AppSpacerH16,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onClickSubmit() async {
    Get.back();

    widget.onSubmit?.call();

    inAppReview.openStoreListing();
  }

  Future<void> _onClickCancel() async {
    Get.back();

    widget.onCancel?.call();
  }
}
