import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:flutter/material.dart';

class DieticianHomeScreen extends StatelessWidget {
  const DieticianHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Diyetisyen sayfası"),
              MyButton(
                text: "Sign Out",
                buttonColor: Colors.black,
                buttonTextColor: Colors.blue,
                buttonTextSize: 15,
                buttonTextWeight: FontWeight.bold,
              )
            ],
          ),
        ),
      ),
    );
  }
}
