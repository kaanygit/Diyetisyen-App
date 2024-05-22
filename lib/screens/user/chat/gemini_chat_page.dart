import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/widget/my_text_field.dart';
import 'package:diyetisyenapp/database/gemini.dart';

class GeminiChatPage extends StatefulWidget {
  const GeminiChatPage({super.key});

  @override
  State<GeminiChatPage> createState() => _GeminiChatPageState();
}

class _GeminiChatPageState extends State<GeminiChatPage> {
  final TextEditingController controller = TextEditingController();
  final Gemini _gemini = Gemini();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<DocumentSnapshot>? _subscription;

  List<Map<String, String>> messages = [];
  bool isLoading = false;

  bool questionAnswer = false;
  int dotCount = 1;
  Timer? _timer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _startDotAnimation();
    _subscribeToChatUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    controller.dispose();
    _subscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startDotAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        dotCount = (dotCount % 3) + 1; // Döngüsel olarak 1, 2, 3 arası değişir
      });
    });
  }

  void _subscribeToChatUpdates() {
    final userId = _auth.currentUser!.uid;
    _subscription = _firestore
        .collection("users")
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        var data = snapshot.data() as Map<String, dynamic>;
        if (data["aiChats"] is List) {
          List<dynamic> existingChats = data["aiChats"];
          List<Map<String, String>> newMessages = existingChats.map((chat) {
            if (chat is Map<String, dynamic>) {
              return {
                "user": chat["user"] as String? ?? "",
                "gemini": chat["gemini"] as String? ?? ""
              };
            } else {
              return {"user": "", "gemini": ""};
            }
          }).toList();
          setState(() {
            messages = newMessages;
          });
          _scrollToBottom();
        }
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
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
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage("assets/images/gemini.jpg"),
            ),
            const SizedBox(width: 10),
            Text(
              "Gemini Chat",
              style: fontStyle(20, Colors.black, FontWeight.bold),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length && isLoading) {
                    return waitingAnswerDot();
                  }
                  final message = messages[index];
                  return Column(
                    children: [
                      chatMessageBox(message["user"]!, true),
                      chatMessageBox(message["gemini"]!, false),
                    ],
                  );
                },
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
                      enabled: !isLoading,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() {
                              isLoading = true;
                            });
                            print('Send button pressed: ${controller.text}');
                            final String text = controller.text.trim();
                            setState(() {
                              messages.add({"user": text, "gemini": ""});
                            });
                            controller.clear();
                            var response = await _gemini.geminiTextPrompt(text);
                            print(response);
                            if (response != null) {
                              await _gemini.setGeminiChatFirebase(
                                  text, response);
                              setState(() {
                                messages[messages.length - 1]["gemini"] =
                                    response;
                              });
                            }
                            setState(() {
                              isLoading = false;
                            });
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column waitingAnswerDot() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage("assets/images/gemini.jpg"),
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

  Column chatMessageBox(String message, bool isUser) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            textDirection: isUser ? TextDirection.rtl : TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(isUser
                    ? "assets/images/avatar.jpg"
                    : "assets/images/gemini.jpg"),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: isUser
                        ? const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                            topLeft: Radius.circular(10),
                          )
                        : const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    message,
                    softWrap: true,
                    style: const TextStyle(color: Colors.white),
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
