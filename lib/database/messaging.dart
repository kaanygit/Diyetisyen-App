import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diyetisyenapp/model/message.model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FirebaseMessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseAuth get auth => _auth;

  Future<void> initialize() async {
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground messages
      print('Message received: ${message.notification?.body}');
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
          'Authorization': 'key=AIzaSyCNp7oWWV1P5v2mJi1BUutAUpirkoHzxwM',
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

    var mainQuery = sentMessagesQuery
        .snapshots()
        .asyncMap((sentSnapshot) async {
      var receivedSnapshot = await receivedMessagesQuery.get();

      var combinedList = [
        ...sentSnapshot.docs,
        ...receivedSnapshot.docs,
      ];

      combinedList.sort((a, b) =>
          (a['timestamp'] as Timestamp).compareTo(b['timestamp'] as Timestamp));

      return combinedList;
    }).map((snapshot) =>
            snapshot.map((doc) => Message.fromDocument(doc)).toList());

    return mainQuery;
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    // Handle background messages
  }
}
