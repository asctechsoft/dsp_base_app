import "dart:io";
import "dart:math";
import "package:dsp_base/app_material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_emoji/flutter_emoji.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:get/get.dart";
import "package:in_app_review/in_app_review.dart";

final InAppReview inAppReview = InAppReview.instance;

class RateMeDialogCustomizer {
  RateMeDialogCustomizer({
    this.title,
    this.message,
    this.submitButtonText,
    this.submitButton,
    this.rateBarStarIconActive,
    this.rateBarStarIconInactive,
    this.backgroundWidget,
    this.dialogBackgroundColor = Colors.white,
    this.iconEmoji,
    this.titleTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    this.messageTextStyle = const TextStyle(fontSize: 14),
    this.dialogBorderRadius = const BorderRadius.all(Radius.circular(20)),
  });
  String Function(int rating)? title;
  String Function(int rating)? message;

  TextStyle? titleTextStyle;
  TextStyle? messageTextStyle;

  String Function(int rating)? submitButtonText;
  Widget Function(int rating, String text, Function() onTap)? submitButton;

  Widget Function()? rateBarStarIconActive;
  Widget Function()? rateBarStarIconInactive;

  Color? dialogBackgroundColor;
  Widget Function()? backgroundWidget;

  Widget Function(int rating)? iconEmoji;

  BorderRadius? dialogBorderRadius;
}

class RateMeDialog extends StatefulWidget {
  const RateMeDialog({super.key, this.customizer, this.onRateMeSubmit});
  final Function(int ratingPicked)? onRateMeSubmit;

  final RateMeDialogCustomizer? customizer;

  @override
  State<StatefulWidget> createState() => RateMeDialogViewState();

  static Future<void> show({
    required BuildContext context,
    Function(int ratingPicked)? onRateMeSubmit,
    Function()? onDismiss,
    RateMeDialogCustomizer? customizer,
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
      builder: (BuildContext context) => RateMeDialog(
        customizer: customizer ?? RateMeDialogCustomizer(),
        onRateMeSubmit: onRateMeSubmit,
      ),
    );

    onDismiss?.call();
  }
}

class RateMeDialogViewState extends State<RateMeDialog> {
  int rating = 0;
  final emojiParser = EmojiParser();

  bool isRatingBarAnimatingOnDialogShow = true;

  Widget renderEmoji() {
    // ðŸ˜Š: blush
    // ðŸ¥²: smiling_face_with_tear
    // ðŸ¤©: grinning_face_with_star_eyes
    if (widget.customizer?.iconEmoji != null) {
      return widget.customizer!.iconEmoji!.call(rating);
    }

    return AppText(
      emojiParser
          .get(
            rating == 0
                ? "blush"
                : rating <= 3
                ? "smiling_face_with_tear"
                : "grinning_face_with_star_eyes",
          )
          .code,
      style: const TextStyle(fontSize: 72),
    );
  }

  Widget renderTitle() {
    final titleFromCustomizer = widget.customizer?.title?.call(rating);

    if (rating > 0) {
      return AppText(
        titleFromCustomizer ??
            (rating <= 3
                ? "rate_me_oh_no".tr
                : rating == 4
                ? "rate_me_thats_great".tr
                : "rate_me_we_love_it".tr),
        modifier: Modifier.paddingHorizontal(16).padding(top: 8),
        style: widget.customizer?.titleTextStyle,
        textAlign: TextAlign.center,
      );
    }

    return AppEmpty;
  }

  List<Widget> renderMessageNotice() {
    final messageFromCustomizer = widget.customizer?.message?.call(rating);

    return [
      AppText(
        messageFromCustomizer ??
            (rating == 0
                ? "new_txtid_rate_app_content_new_1".tr
                : rating <= 3
                ? "${'rate_me_we_are_sorry_to_know_your_experience'.tr}\n${'rate_me_please_leave_us_some_feedback'.tr}"
                : "rate_me_thank_you_for_your_feedback".tr),
        modifier: Modifier.paddingHorizontal(16).padding(top: 8),
        style: widget.customizer?.messageTextStyle,
        textAlign: TextAlign.center,
      ),
      // if (rating != 0 && rating <= 3) ...[
      //   Padding(
      //     padding: EdgeInsets.only(
      //       left: 16,
      //       right: 16,
      //       top: 4,
      //     ),
      //     child: AppText(
      //       'rate_me_please_leave_us_some_feedback'.tr,
      //       style: TextStyle(fontSize: 14),
      //       textAlign: TextAlign.center,
      //     ),
      //   ),
      // ]
    ];
  }

  Widget renderRateBar() {
    return AppRowCentered(
      key: const ValueKey("rate_me_star_row"),
      children: [1, 2, 3, 4, 5].map((number) {
        final rateBarStarIconActive =
            widget.customizer?.rateBarStarIconActive?.call() ??
            const AppIcon(
              "packages/dsp_base/lib/assets/ic_star_rate_full.svg",
              size: 52,
            );
        final rateBarStarIconInactive =
            widget.customizer?.rateBarStarIconInactive?.call() ??
            const AppIcon(
              "packages/dsp_base/lib/assets/ic_star_rate_empty.svg",
              size: 52,
            );

        return AppRow(
          children: [
            GestureDetector(
              onTap: () => {
                if (!isRatingBarAnimatingOnDialogShow)
                  setState(() {
                    rating = number;
                  }),
              },
              child:
                  Container(
                        child: isRatingBarAnimatingOnDialogShow
                            ? rateBarStarIconActive
                            : rating >= number
                            ? rateBarStarIconActive
                            : rateBarStarIconInactive,
                      )
                      .animate(
                        onComplete: (controller) {
                          if (number == 5) {
                            setState(() {
                              isRatingBarAnimatingOnDialogShow = false;
                            });
                          }
                        },
                      )
                      .scaleXY(
                        delay: Duration(
                          milliseconds: number == 1 ? 0 : 100 * number,
                        ),
                        duration: const Duration(milliseconds: 250),
                        begin: 1.2,
                        end: 0.7,
                        curve: Curves.bounceInOut,
                      )
                      .scaleXY(
                        delay: Duration(
                          milliseconds: (number == 1 ? 0 : 100 * number) + 150,
                        ),
                        duration: const Duration(milliseconds: 250),
                        begin: 0.7,
                        end: 1.2,
                        curve: Curves.bounceInOut,
                      )
                      .shake(
                        delay: Duration(
                          milliseconds: (number == 1 ? 0 : 100 * number) + 300,
                        ),
                        duration: Duration(milliseconds: number == 5 ? 800 : 0),
                        curve: Curves.easeInOut,
                        hz: 5,
                        rotation: pi / 16,
                      ),
            ),
            AppSpacerW2,
          ],
        );
      }).toList(),
    );
  }

  List<Widget> renderSubmitRatingButton() {
    final submitButtonTextFromCustomizer = widget.customizer?.submitButtonText?.call(rating);
    final submitButtonText =
        submitButtonTextFromCustomizer ??
        (rating <= 3
            ? "rate_me_share_feedback".tr
            : rating == 4
            ? "rate_me_rate_us".tr
            : "rate_me_rate_us_on_google_play".tr);

    if (widget.customizer?.submitButton != null) {
      return [
        widget.customizer!.submitButton!.call(
          rating,
          submitButtonText,
          onClickSubmitRating,
        ),
        AppSpacerH16,
      ];
    }

    return [
      if (rating > 0) ...[
        ElevatedButton(
          onPressed: onClickSubmitRating,
          child: AppText(submitButtonText),
        ),
        AppSpacerH16,
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: widget.customizer?.dialogBorderRadius ?? BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: widget.customizer?.dialogBackgroundColor ?? Colors.white,
      child: AppBox(
        alignment: Alignment.topCenter,
        children: [
          widget.customizer?.backgroundWidget?.call() ?? const SizedBox.shrink(),
          AppColumnCentered(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSpacerH16,
              renderEmoji(),
              renderTitle(),
              ...renderMessageNotice(),
              AppSpacerH16,
              renderRateBar(),
              AppSpacerH16,
              ...renderSubmitRatingButton(),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> onClickSubmitRating() async {
    Get.back();

    widget.onRateMeSubmit?.call(rating);

    if (rating < 4) return;

    if (rating == 4) {
      Fluttertoast.showToast(
        msg: "rate_me_thank_you_for_your_rating".tr,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    inAppReview.openStoreListing();
  }
}
