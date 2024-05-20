import 'package:diyetisyenapp/database/firebase.dart';
import 'package:flutter/material.dart';
import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/screens/auth/auth_screen.dart';

class MyButton extends StatelessWidget {
  final String text;
  final Color buttonColor;
  final Color buttonTextColor;
  final double buttonTextSize;
  final FontWeight buttonTextWeight;

  const MyButton({
    Key? key,
    required this.text,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.buttonTextSize,
    required this.buttonTextWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          FirebaseOperations().signOut();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AuthScreen()),
          );
        },
        child: Text(
          text,
          style: fontStyle(buttonTextSize, buttonTextColor, buttonTextWeight),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: EdgeInsets.symmetric(vertical: 16.0),
        ),
      ),
    );
  }
}
