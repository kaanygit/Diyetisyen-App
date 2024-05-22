import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/screens/dietician/message_screen.dart';
import 'package:diyetisyenapp/screens/user/chat/chat_page.dart';
import 'package:diyetisyenapp/screens/user/chat/dietitians_request_screen.dart';
import 'package:diyetisyenapp/screens/user/chat/gemini_chat_page.dart';
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
                chatBoxGemini(),
                dietRequest(context),
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
                    // decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(16)),
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
