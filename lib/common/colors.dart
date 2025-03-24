import 'package:flutter/material.dart';

class UIColors {
  UIColors._();

  static Color hexToColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor"; // Add alpha value if missing
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  static const Color primaryColor = Color(0xFF005fff);
  static const Color secondaryColor = Color(0xFFf58b14);
  static const Color background = Color(0xFFf1fbfd);
  static const Color defaultText = Color(0xFF171A1C);
  static const Color boldText = Color(0xFF24253d);
  static Color blurBackground = const Color(0xFF171A1C).withOpacity(0.6);
  static const Color buttonColor = Color(0xFF075380);
  static const Color blueText = Color(0xFF0059AB);
  static const Color blue = Color(0xff3DA3DF);
  static const Color blueDivider = Color(0xff72DFFF);
  static const Color oldBlue = Color(0xff4377A7);
  static const Color iconBlue = Color(0xff72BBFF);

  static const Color white = Color(0xFFFFFFFF);
  static const Color smoke = Color(0xFFF9F9F9);
  static const Color whiteSmoke = Color(0xFFF4F9FE);
  static const Color lightBlue = Color(0xFFD3EAFF);
  static const Color lightCyan = Color(0xFFC5F2FD);
  static const Color light = Color(0xFFE7F0FA);

  static const Color green = Color(0xFF518D4B);
  static const Color darkBlue = Color(0xFF221db0);
  static const Color gray = Color(0xFFDEDEDE);
  static const Color grayText = Color(0xFF888888);
  static const Color blueGray = Color(0xFF848A9C);
  static const Color lightGray = Color(0xFFD9D9D9);
  static const Color gray0 = Color(0xFFECECEC);
  static const Color gray1 = Color(0xFFB7B7B7);
  static const Color gray8A = Color(0xFF8A8A8A);
  static const Color darkGray = Color(0xFF505050);
  static const Color extraGray = Color(0xFF444444);
  static const Color red = Color(0xFFCA0000);
  static const Color black = Color(0xFF171A1C);
  static const Color originBlack = Color(0xFF000000);
  static const Color colorTextField = Color(0xFFC1C1C1);
  static const Color colorBlur = Color(0x00000014);
  static const Color cyan = Color(0xFF4BE3C8);
  static const Color yellow = Color(0xFFFFB800);
  static const Color line = Color(0xFFF0F8FF);
  static const Color succeed = Color(0xFFC6EDE1);
  static const Color failed = Color(0xFFEDC6C6);

  static const Color redLight = Color(0xFFFF4B6A);
  static const Color redDark = Color(0xFFFF3557);
  static const List<Color> redGradient = [redLight, redDark];

  static const List<Color> primaryGradient = [
    Color(0xff4BE3C9),
    Color(0xff05DDFC),
    Color(0xff3DA3DF),
  ];

  static const List<Color> gradient2 = [
    Color(0xff3DA3DF),
    Color(0xff44D7EE),
    Color(0xff4BE3C8),
  ];

  static const List<Color> gradientBackground = [
    Color(0xff4BE3C8),
    Color(0xff3DA3DF),
  ];

  static List<Color> gradient4 = [
    const Color(0xff4BE3C8).withOpacity(0.1),
    const Color(0xff3DA3DF).withOpacity(0.17),
  ];

  static const List<Color> backgroundGradient = [
    Color(0xff57AEE1),
    Color(0xff57AEE1),
    Color(0xff57AEE1),
    Color(0xff44D1EC),
    Color(0xffB6D75B),
  ];

  static const List<Color> blueGradient = [
    Color(0xff57AEE1),
    Color(0xff44D1EC),
  ];

  static const List<Color> popupGradient = [
    Color(0xffDFF0FA),
    Color(0xffE5F8FD),
  ];

  static List<Color> whiteGradient = [
    const Color(0xFFFFFFFF),
    const Color(0xFFFFFFFF).withOpacity(0.29),
  ];

  static List<Color> onlyGrayGradient = [
    const Color(0xFFDEDEDE),
    const Color(0xFFDEDEDE),
  ];

  static List<Color> orangeGradient = [
    const Color(0xFFFFF501),
    const Color(0xFFFF8514),
  ];

  static const List<Color> blueComponentGradient = [
    Color(0xff24F2FF),
    Color(0xff42DEFF),
  ];

  static const List<Color> greenComponentGradient = [
    Color(0xff60DDB0),
    Color(0xff42FFF4),
  ];

  static const List<Color> verticalComponentGradient = [
    Color(0xff4FBDE6),
    Color(0xff47E5DC),
  ];

  static const List<Color> lightBlueGradient = [
    Color(0xFFDDFBFF),
    Color(0xFFCBEEFF),
  ];

  static const List<Color> extraLightBlueGradient = [
    Color(0xFFE3FFFA),
    Color(0xFFDDFBFF),
    Color(0xFFCBEEFF),
  ];

  static const List<Color> darkBlueGradient = [
    Color(0xFF00BFE3),
    Color(0xFF3D8CBA),
  ];
  static const List<Color> lightBlueDoubleGradient = [
    Color(0xFFE2F1FF),
    Color(0xFFE2F1FF),
  ];
}
