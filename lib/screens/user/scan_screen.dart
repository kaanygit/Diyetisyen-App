import 'package:diyetisyenapp/screens/auth/user_information_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: Column(
      children: [
        const Text("Scan Screen"),
        ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  PageTransition(
                      type: PageTransitionType.fade,
                      child: new UserInformationScreen()));
            },
            child: Text("İnformasyon"))
      ],
    )));
  }
}
