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
  late Stream<List<Message>> messagesStream;
  late StreamController<List<Message>> _streamController;
  bool disableInput = false;

  @override
  void initState() {
    super.initState();
    _messagingService.initialize();
    messagesStream = _messagingService.getMessages(
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

      // Eğer sadece bir mesaj varsa ve bu mesaj kullanıcının kendi mesajıysa
      if (messages.length == 1 &&
          messages[0].senderId == _messagingService.auth.currentUser!.uid) {
        setState(() {
          disableInput = true; // TextField ve IconButton devre dışı bırakılır
        });
      } else {
        setState(() {
          disableInput = false; // TextField ve IconButton aktif edilir
        });
      }
    });
  }

  void _handleSendMessage() async {
    if (_messageController.text.isNotEmpty) {
      try {
        await _messagingService.sendMessage(
          _messageController.text,
          widget.receiverId,
        );
        _messageController.clear();
        _loadMessages(); // Mesaj gönderildikten sonra ekranı güncelle
      } catch (e) {
        print('Message sending error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messaging'),
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
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(messages[index].content),
                        subtitle: Text(messages[index].senderId),
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
                    enabled: !disableInput, // TextField aktif ise true
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: disableInput
                      ? null // disableInput true ise IconButton devre dışı
                      : () async {
                          if (_messageController.text.isNotEmpty) {
                            _handleSendMessage();
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
    _loadMessages(); // Yenileme işlemi burada gerçekleştirilebilir
  }

  @override
  void dispose() {
    _messageController.dispose();
    _streamController.close();
    super.dispose();
  }
}
