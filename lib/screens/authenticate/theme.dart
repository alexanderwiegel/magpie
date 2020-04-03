import 'dart:ui';

import 'package:flutter/cupertino.dart';

class Colors {
  const Colors();

  //static const Color loginGradientStart = const Color(0xFFfbab66);
  //static const Color loginGradientEnd = const Color(0xFFf7418c);
  static const Color loginGradientStart = const Color(0xFF009688);
  static const Color loginGradientEnd = const Color.fromRGBO(37, 68, 65, 1);
  //static const Color loginGradientEnd = const Color.fromRGBO(16, 41, 40, 1);

  static const primaryGradient = const LinearGradient(
    colors: const [loginGradientStart, loginGradientEnd],
    stops: const [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
