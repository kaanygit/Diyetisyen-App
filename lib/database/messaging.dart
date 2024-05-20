import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diyetisyenapp/model/message.model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
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
      await _firestore.collection('users').doc(_auth.currentUser?.uid).set({'fcmToken': token});
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
    }
  }

  Stream<List<Message>> getMessages(String userId) {
    return _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Message.fromDocument(doc)).toList());
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    // Handle background messages
  }
}


