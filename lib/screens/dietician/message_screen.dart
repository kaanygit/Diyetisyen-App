import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:diyetisyenapp/database/messaging.dart';
import 'package:diyetisyenapp/model/message.model.dart';

class MessagingScreen extends StatefulWidget {
  final String receiverId;

  MessagingScreen({required this.receiverId});

  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final FirebaseMessagingService _messagingService = FirebaseMessagingService();
  final TextEditingController _messageController = TextEditingController();
  late Stream<List<Message>> _messagesStream;
  late StreamController<List<Message>> _streamController;

  @override
  void initState() {
    super.initState();
    _messagingService.initialize();
    _messagesStream = _messagingService.getMessages(
        _messagingService.auth.currentUser!.uid, widget.receiverId);

    _streamController = StreamController<List<Message>>.broadcast();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received: ${message.notification?.body}');
      _handleMessage(message);
    });

    // Mesajlar yüklenirken bir defa ekranı güncellemek için
    _loadMessages();
  }

  void _handleMessage(RemoteMessage message) {
    _loadMessages(); // Yeni mesaj alındığında mesajları yeniden yükle
  }

  void _loadMessages() {
    _messagingService
        .getMessages(_messagingService.auth.currentUser!.uid, widget.receiverId)
        .listen((messages) {
      _streamController.add(messages);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messaging'),
        actions: [
          // Burada kullanıcının fotoğrafını ve diğer bilgilerini gösterebilirsiniz
          CircleAvatar(
            backgroundImage: AssetImage('assets/images/avatar.jpg'),
            radius: 20,
          ),
          SizedBox(width: 16),
          Text('Kullanıcı Adı'),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No messages'));
                }

                List<Message> messages = snapshot.data ?? [];

                return RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: ListView.builder(
                    itemCount: messages.length,
                    reverse: true, // Yeni mesajlar en üste çıksın
                    itemBuilder: (context, index) {
                      Message message = messages[index];
                      bool isMyMessage = message.senderId ==
                          _messagingService.auth.currentUser!.uid;
                      return Align(
                        alignment: isMyMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMyMessage ? Colors.blue : Colors.grey,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message.content,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(labelText: 'Send a message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    if (_messageController.text.isNotEmpty) {
                      await _messagingService.sendMessage(
                          _messageController.text, widget.receiverId);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Yenileme işlemi burada gerçekleştirilebilir
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _streamController.close();
    super.dispose();
  }
}
