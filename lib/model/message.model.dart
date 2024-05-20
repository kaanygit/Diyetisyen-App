import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String content;
  final String senderId;
  final String receiverId;
  final Timestamp timestamp;

  Message({required this.content, required this.senderId, required this.receiverId, required this.timestamp});

  factory Message.fromDocument(DocumentSnapshot doc) {
    return Message(
      content: doc['content'],
      senderId: doc['senderId'],
      receiverId: doc['receiverId'],
      timestamp: doc['timestamp'],
    );
  }
}