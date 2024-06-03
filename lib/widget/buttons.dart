import 'package:flutter/material.dart';
import 'package:diyetisyenapp/constants/fonts.dart';

class MyButton extends StatelessWidget {
  final String text;
  final Color buttonColor;
  final Color buttonTextColor;
  final double buttonTextSize;
  final FontWeight buttonTextWeight;
  final VoidCallback onPressed; // onPressed parametresini ekledik

  const MyButton({
    super.key,
    required this.text,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.buttonTextSize,
    required this.buttonTextWeight,
    required this.onPressed, // onPressed'i constructor'a ekledik
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed, // onPressed'i burada kullanıyoruz
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: Text(
          text,
          style: fontStyle(buttonTextSize, buttonTextColor, buttonTextWeight),
        ),
      ),
    );
  }
}
