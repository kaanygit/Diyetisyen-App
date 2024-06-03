import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diyetisyenapp/model/message.model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FirebaseMessagingService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final StreamController<List<Message>> _messagesController =
      StreamController<List<Message>>.broadcast();

  FirebaseAuth get auth => _auth;

  FirebaseMessagingService() {
    initialize();
  }

  Future<void> initialize() async {
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground messages
      print('Message received: ${message.notification?.body}');
      _handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification tap
      print('Notification clicked!');
    });

    String? token = await _messaging.getToken();
    if (token != null) {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .update({'fcmToken': token});
    }
  }

  Future<void> sendMessage(String content, String receiverId) async {
    String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _firestore.collection('messages').add({
        'content': content,
        'senderId': userId,
        'receiverId': receiverId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Alıcının FCM tokenini alın
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(receiverId).get();

      if (userDoc.exists) {
        String? token = userDoc.get('fcmToken');

        if (token != null) {
          await _sendPushMessage(token, content);
        }
      } else {
        print('Receiver not found');
      }
    } else {
      print('User not authenticated');
    }
  }

  Future<void> _sendPushMessage(String token, String message) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAApZrZL6E:APA91bGTLRT_Ws3cKzW99lZdhEgzjfGFbPV8bYZcP35qmwdFhRNBK5dDOPK7weNs046XGdOGAs76dFxRXG0vlkWQfOoLE_277htlpvNIhcJKzYy9bzi9jj8uAN-Z-A_6B8j6ijSIkGm6', // Buraya kendi server key'inizi ekleyin
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': message,
              'title': 'New Message'
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': token,
          },
        ),
      );
    } catch (e) {
      print("Error sending push notification: $e");
    }
  }

  Stream<List<Message>> get messagesStream => _messagesController.stream;

  void _handleMessage(RemoteMessage message) {
    // Handle incoming message and trigger message retrieval
    String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      String? senderId = message.data['senderId'];
      String? receiverId = userId;
      if (senderId != null) {
        // Refresh messages for the sender and current user
        getMessages(userId, senderId);
      }
    }
  }

  Stream<List<Message>> getMessages(String userId, String otherUserId) {
    var sentMessagesQuery = _firestore
        .collection('messages')
        .where('senderId', isEqualTo: userId)
        .where('receiverId', isEqualTo: otherUserId)
        .orderBy('timestamp');

    var receivedMessagesQuery = _firestore
        .collection('messages')
        .where('senderId', isEqualTo: otherUserId)
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp');

    var mainQuery =
        sentMessagesQuery.snapshots().asyncMap((sentSnapshot) async {
      var receivedSnapshot = await receivedMessagesQuery.get();
      var combinedList = [
        ...sentSnapshot.docs,
        ...receivedSnapshot.docs,
      ];
      combinedList.sort((a, b) =>
          (a['timestamp'] as Timestamp).compareTo(b['timestamp'] as Timestamp));
      return combinedList.map((doc) => Message.fromDocument(doc)).toList();
    });

    return mainQuery;
  }

  Future<void> acceptUser(String userId, String dieticianId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'dietician-person-uid': FieldValue.arrayUnion([dieticianId])
      });
    } catch (e) {
      print('Error accepting user: $e');
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    // Handle background messages
  }
}
