import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/screens/user/chat_page.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage("assets/images/avatar.jpg")),
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
                chatBox(),
                chatBox(),
                chatBox(),
              ],
            )),
      ),
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
              MaterialPageRoute(builder: (context) => const ChatPage()),
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
                    // decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(16)),
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
