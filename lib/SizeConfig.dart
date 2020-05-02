import 'package:flutter/widgets.dart';

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double hori;
  static double vert;
  static bool isTablet;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    hori = screenWidth / 100;
    vert = screenHeight / 100;
    screenWidth > 600 ? isTablet = true : isTablet = false;
  }
}
