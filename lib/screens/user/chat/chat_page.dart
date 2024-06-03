import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/widget/my_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller = TextEditingController();
  bool questionAnswer = false;
  int dotCount = 1;
  Timer? _timer;
  late String profilePhoto = "";

  @override
  void initState() {
    super.initState();
    _startDotAnimation();
    fetchProfilePhotos();
  }

  void _startDotAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        dotCount = (dotCount % 3) + 1; // Döngüsel olarak 1, 2, 3 arası değişir
      });
    });
  }

  Future<void> fetchProfilePhotos() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String? uid = user?.uid;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot =
          await firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          profilePhoto = data['profilePhoto'] ?? "";
        });
      }
    } catch (e) {
      print("Error fetching diet program: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
              child: Icon(
            Icons.arrow_back_ios,
            color: mainColor,
          )),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: profilePhoto == ""
                  ? const AssetImage("assets/images/avatar.jpg")
                  : NetworkImage(profilePhoto) as ImageProvider,
            ),
            const SizedBox(width: 10),
            Text(
              "Yasin Kaan",
              style: fontStyle(20, Colors.black, FontWeight.bold),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    waitingAnswerDot(),
                    waitingAnswerDot(),
                    waitingAnswerDot(),
                    chatMessageBox(context),
                    chatMessageBox(context),
                    chatMessageBox(context),
                    chatMessageBox(context),
                    chatMessageBox(context),
                    chatMessageBox(context),
                    chatMessageBox(context),
                    chatMessageBox(context),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    controller: controller,
                    hintText: "Type your message",
                    obscureText: false,
                    keyboardType: TextInputType.multiline,
                    enabled: true,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Mesaj gönderme işlemi burada gerçekleşecek
                    print('Send button pressed: ${controller.text}');
                    // Mesaj gönderildikten sonra TextField'i temizleme
                    controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Column waitingAnswerDot() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft, // Solda hizalar
          child: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage("assets/images/avatar.jpg"),
              ),
              const SizedBox(
                width: 5,
              ),
              Container(
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: Text(
                  '.' * dotCount,
                  style: fontStyle(20, Colors.black, FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Column chatMessageBox(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            textDirection:
                questionAnswer ? TextDirection.rtl : TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage("assets/images/avatar.jpg"),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    "chat screenchat screenchat screenchat screenchat screenchat screen",
                    softWrap: true,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
