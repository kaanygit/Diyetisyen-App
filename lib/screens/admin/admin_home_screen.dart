import 'package:diyetisyenapp/database/firebase.dart';
import 'package:diyetisyenapp/screens/auth/auth_screen.dart';
import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Admin Sayfası"),
              MyButton(
                onPressed: () {
                  FirebaseOperations().signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                  );
                },
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
