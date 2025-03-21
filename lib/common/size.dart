import 'package:flutter/material.dart';

class AppSize {
  AppSize._();
  static final AppSize instance = AppSize._();

  double width = 0;
  double height = 0;
  double keyboardHeight = 0;

  /// iOS: notch above iPhone X
  /// Android: status bar
  double safeTop = 0;

  /// iOS: home bar space above iPhone X
  /// Android: home bar space
  double safeBottom = 0;

  void init(BuildContext context) {
    final media = MediaQuery.of(context);
    width = media.size.width;
    height = media.size.height;
    safeTop = media.viewPadding.top;
    safeBottom = media.viewPadding.bottom;
    keyboardHeight = media.viewInsets.bottom;
  }

  double get bottomBarHeight => 100;

  double get homeSafeBottom => bottomBarHeight + 50;

  double get bodyHeight => height - safeTop - safeBottom;

  bool get isMobile => width < 500;
  bool get isLargeMobile => 500 <= width && width <= 900;
  bool get isTablet => !(isMobile && isLargeMobile);

  double get bottomSheetHeight => height * 0.5;
}
