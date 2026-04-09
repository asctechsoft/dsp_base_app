@Deprecated("Use 'package:dsp_base/convenience_imports.dart' instead")
library;

import "dart:math";

import "package:dsp_base/app_material.dart";
import "package:get/get.dart";

class ScreenUtils {
  static double distance(Point p1, Point p2) {
    return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2));
  }

  // HÃ m tÃ­nh gÃ³c giá»¯a hai Ä‘oáº¡n tháº³ng
  static double calculateRotateAngle(
    Point<int> p1,
    Point<int> p2,
    Point<int> p3,
    Point<int> p4,
    bool isRad,
  ) {
    // TÃ­nh cÃ¡c thÃ nh pháº§n cá»§a vector
    final ux = p2.x - p1.x;
    final uy = p2.y - p1.y;
    final vx = p4.x - p3.x;
    final vy = p4.y - p3.y;

    // TÃ­ch vÃ´ hÆ°á»›ng cá»§a hai vector
    final dotProduct = ux * vx + uy * vy;

    // Äá»™ dÃ i cá»§a hai vector
    final magnitudeU = sqrt(ux * ux + uy * uy);
    final magnitudeV = sqrt(vx * vx + vy * vy);

    // TÃ­nh cos(theta)
    var cosTheta = dotProduct / (magnitudeU * magnitudeV);

    // TrÃ¡nh lá»—i do sai sá»‘ sá»‘ há»c
    cosTheta = cosTheta.clamp(-1.0, 1.0);

    // TÃ­nh gÃ³c báº±ng radian vÃ  chuyá»ƒn sang Ä‘á»™
    final angleRad = acos(cosTheta);
    final angleDeg = angleRad * 180 / pi;

    return isRad ? angleRad : angleDeg;
  }

  // Chuyá»ƒn tá»« px sang dp
  static double pxToDp(double px) {
    return px / Get.pixelRatio;
  }

  static Size getScreenSize() {
    try {
      return Size(Get.width, Get.height);
    } catch (e) {
      final physicalHeight = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height;
      final physicalWidth = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width;
      final devicePixelRatio = WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
      final height = physicalHeight / devicePixelRatio;
      final width = physicalWidth / devicePixelRatio;
      return Size(width, height);
    }
  }

  static double getScreenWidth() {
    return getScreenSize().width;
  }

  static double getScreenHeight() {
    return getScreenSize().height;
  }
}
