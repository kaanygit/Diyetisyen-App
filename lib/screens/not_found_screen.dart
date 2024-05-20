import 'package:diyetisyenapp/database/firebase.dart';
import 'package:flutter/material.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const NotFound(),
    );
  }
}

class NotFound extends StatefulWidget {
  const NotFound({super.key});

  @override
  State<NotFound> createState() => _NotFoundState();
}

class _NotFoundState extends State<NotFound> {
  @override
  void initState() {
    // TODO: implement initState
    FirebaseOperations().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Tanımsız kullanıcı tipi:"),
      ),
    );
  }
}
