import 'package:flutter/material.dart';

Color mainColor = const Color(0xFF7e64e7);
Color mainColor2 = const Color(0xFFE4E3FF);
Color mainColor3 = const Color(0xFFF0EFFD);

TextStyle fontStyle(double fontSizes, Color fontColor, FontWeight fontWeights) {
  return TextStyle(
      fontSize: fontSizes,
      color: fontColor,
      fontWeight: fontWeights,
      fontFamily: 'OpenSans');
}
