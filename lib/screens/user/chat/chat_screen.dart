import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/screens/dietician/message_screen.dart';
import 'package:diyetisyenapp/screens/user/chat/chat_page.dart';
import 'package:diyetisyenapp/screens/user/chat/dietitians_request_screen.dart';
import 'package:diyetisyenapp/screens/user/chat/gemini_chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool hasDietician = false;
  String dieticianId = '';
  late String profilePhoto = "";
  @override
  void initState() {
    super.initState();
    _checkDieticianStatus();
    fetchProfilePhotos();
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

  Future<void> _checkDieticianStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      List<dynamic> dieticianList = userDoc['dietician-person-uid'] ?? [];
      if (dieticianList.isNotEmpty) {
        setState(() {
          hasDietician = true;
          dieticianId = dieticianList[0]; // İlk diyetisyen kimliği
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
                radius: 20,
                backgroundImage: profilePhoto == "" || profilePhoto == null
                    ? AssetImage("assets/images/avatar.jpg")
                    : NetworkImage(profilePhoto) as ImageProvider),
            Container(
              child: Text("Sohbet",
                  style: fontStyle(25, Colors.black, FontWeight.normal)),
            ),
            Icon(
              Icons.chat,
              color: mainColor,
            )
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                chatBoxGemini(),
                hasDietician ? dieticianBox(context) : dietRequest(context),
              ],
            )),
      ),
    );
  }

  InkWell dietRequest(BuildContext context) {
    return InkWell(
      onTap: () {
        print("Sayfaya gir");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DietitiansRequestScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
            color: mainColor2, borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                child: Column(
              children: [
                const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage("assets/images/avatar.jpg")),
                const SizedBox(
                  width: 5,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Diyetisyen Ekle",
                        style: fontStyle(15, Colors.black, FontWeight.bold)),
                    Text(
                      "Yeni Diyetisyen ile Mücadeleye Devam !",
                      style: fontStyle(15, Colors.grey, FontWeight.normal),
                    ),
                  ],
                ),
              ],
            )),
            Container(
                child: IconButton(
                    onPressed: () {
                      print("İÇİNE GİR");
                    },
                    iconSize: 20,
                    color: Colors.black,
                    icon: const Icon(Icons.arrow_forward_ios))),
          ],
        ),
      ),
    );
  }

  InkWell dieticianBox(BuildContext context) {
    return InkWell(
      onTap: () {
        print("Diyetisyenle sohbet ekranına git");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessagingScreen(receiverId: dieticianId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
            color: mainColor2, borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                child: Column(
              children: [
                const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage("assets/images/avatar.jpg")),
                const SizedBox(
                  width: 5,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Diyetisyenim",
                        style: fontStyle(15, Colors.black, FontWeight.bold)),
                    Text(
                      "Diyetisyeninizle sohbet edin",
                      style: fontStyle(15, Colors.grey, FontWeight.normal),
                    ),
                  ],
                ),
              ],
            )),
            Container(
                child: IconButton(
                    onPressed: () {
                      print("Diyetisyenle sohbet ekranına git");
                    },
                    iconSize: 20,
                    color: Colors.black,
                    icon: const Icon(Icons.arrow_forward_ios))),
          ],
        ),
      ),
    );
  }

  Column chatBoxGemini() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            print("Gemini gir gir");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GeminiChatPage()),
            );
          },
          child: Container(
            decoration: BoxDecoration(
                color: mainColor2, borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    child: Row(
                  children: [
                    const CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            AssetImage("assets/images/gemini.jpg")),
                    const SizedBox(
                      width: 5,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Gemini AI",
                            style:
                                fontStyle(15, Colors.black, FontWeight.bold)),
                        Text(
                          "Yapay zeka ile sohbet et !",
                          style: fontStyle(15, Colors.grey, FontWeight.normal),
                        ),
                      ],
                    ),
                  ],
                )),
                Container(
                    child: IconButton(
                        onPressed: () {
                          print("İÇİNE GİR");
                        },
                        iconSize: 20,
                        color: Colors.black,
                        icon: const Icon(Icons.push_pin))),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }

  Column chatBox() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            print("Sayfaya gir");
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MessagingScreen(
                        receiverId: "ERbueLCOvFR9cVpyiqZavXoM7Pr2",
                      )),
            );
          },
          child: Container(
            decoration: BoxDecoration(
                color: mainColor2, borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    child: Row(
                  children: [
                    const CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            AssetImage("assets/images/avatar.jpg")),
                    const SizedBox(
                      width: 5,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Yasin Kaan",
                            style:
                                fontStyle(15, Colors.black, FontWeight.bold)),
                        Text(
                          "Deneme yazısı",
                          style: fontStyle(15, Colors.grey, FontWeight.normal),
                        ),
                      ],
                    ),
                  ],
                )),
                Container(
                    child: IconButton(
                        onPressed: () {
                          print("İÇİNE GİR");
                        },
                        iconSize: 20,
                        color: Colors.black,
                        icon: const Icon(Icons.arrow_forward_ios))),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}
