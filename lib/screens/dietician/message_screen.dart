import 'package:diyetisyenapp/database/messaging.dart';
import 'package:diyetisyenapp/model/message.model.dart';
import 'package:flutter/material.dart';

class MessagingScreen extends StatefulWidget {
  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseMessagingService _messagingService = FirebaseMessagingService();
  String _receiverId =
      "GfeCmwuWcvbiPdcKB7Dx4XR0RSx1"; // Replace with actual receiver's user ID

  @override
  void initState() {
    super.initState();
    _initializeMessaging();
  }

  void _initializeMessaging() async {
    await _messagingService.initialize();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _messagingService.sendMessage(_messageController.text, _receiverId);
      _messageController.clear();
    }
  }

  Stream<List<Message>> _getMessages() {
    return _messagingService.getMessages(_receiverId);
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
              stream: _getMessages(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var messages = snapshot.data!;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    return ListTile(
                      title: Text(message.content),
                    );
                  },
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
                    decoration: InputDecoration(labelText: 'Message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
