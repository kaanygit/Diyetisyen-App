import 'package:diyetisyenapp/database/messaging.dart';
import 'package:flutter/material.dart';
import 'package:diyetisyenapp/model/message.model.dart';

class MessagingScreen extends StatelessWidget {
  final String receiverId;
  final FirebaseMessagingService _messagingService = FirebaseMessagingService();

  MessagingScreen({required this.receiverId});

  @override
  Widget build(BuildContext context) {
    final String userId = _messagingService.auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Messaging'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messagingService.getMessages(userId, receiverId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No messages'));
                }

                List<Message> messages = snapshot.data!;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(messages[index].content),
                      subtitle: Text(messages[index].senderId),
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
                    decoration: InputDecoration(labelText: 'Send a message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    if (_messageController.text.isNotEmpty) {
                      await _messagingService.sendMessage(
                          _messageController.text, receiverId);
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

  final TextEditingController _messageController = TextEditingController();
}
