import 'dart:async';
import 'package:diyetisyenapp/screens/dietician/dietcian_profile_screen.dart';
import 'package:diyetisyenapp/screens/user/client_profile_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:diyetisyenapp/database/messaging.dart';
import 'package:diyetisyenapp/model/message.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagingScreen extends StatefulWidget {
  final String receiverId;

  MessagingScreen({required this.receiverId});

  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  final FirebaseMessagingService _messagingService = FirebaseMessagingService();
  final TextEditingController _messageController = TextEditingController();
  late Stream<List<Message>> messagesStream;
  late StreamController<List<Message>> _streamController;
  bool disableInput = false;
  bool initialMessageSent = false;

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

    // Load messages when the screen initializes
    _loadMessages();
  }

  void _handleMessage(RemoteMessage message) {
    _loadMessages(); // Reload messages when a new message arrives
  }

  void _loadMessages() {
    _messagingService
        .getMessages(_messagingService.auth.currentUser!.uid, widget.receiverId)
        .listen((messages) async {
      _streamController.add(messages);

      if (!initialMessageSent &&
          messages.isNotEmpty &&
          messages[0].senderId == _messagingService.auth.currentUser!.uid) {
        // User sent the first message
        initialMessageSent = true;

        // Add user's UID to the dietician's request list
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.receiverId)
            .update({
          'danisanlar-istek':
              FieldValue.arrayUnion([_messagingService.auth.currentUser!.uid])
        });
      }

      if (messages.length == 1 &&
          messages[0].senderId != _messagingService.auth.currentUser!.uid) {
        // Check if user has already been accepted
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(messages[0].senderId)
            .get();

        List<dynamic> dieticianList = userDoc['dietician-person-uid'] ?? [];

        if (!dieticianList.contains(_messagingService.auth.currentUser!.uid)) {
          _showAcceptanceDialog();
        }
      }

      if (messages.length == 1 &&
          messages[0].senderId == _messagingService.auth.currentUser!.uid) {
        setState(() {
          disableInput = true; // Disable TextField and IconButton
        });
      } else {
        setState(() {
          disableInput = false; // Enable TextField and IconButton
        });
      }
    });
  }

  Future<void> _addClientToDietician(
      String dieticianId, String clientId) async {
    DocumentReference dieticianDoc =
        FirebaseFirestore.instance.collection('users').doc(dieticianId);
    await dieticianDoc.update({
      'dietician-danisanlar-uid': FieldValue.arrayUnion([clientId])
    });
  }

  Future<void> _removeClientFromDietician(
      String dieticianId, String clientId) async {
    DocumentReference dieticianDoc =
        FirebaseFirestore.instance.collection('users').doc(dieticianId);
    await dieticianDoc.update({
      'dietician-danisanlar-uid': FieldValue.arrayRemove([clientId])
    });
  }

  void _showAcceptanceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Accept User'),
          content: Text('Do you want to accept this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                String dieticianId = _messagingService.auth.currentUser!.uid;
                String clientId = widget.receiverId;
                await _messagingService.acceptUser(clientId, dieticianId);
                await _addClientToDietician(dieticianId, clientId);

                // Remove client UID from dietician's 'danisanlar-istek' list
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(dieticianId)
                    .update({
                  'danisanlar-istek': FieldValue.arrayRemove([clientId])
                });

                Navigator.of(context).pop();
                setState(() {
                  disableInput = false; // Enable TextField after acceptance
                });
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _handleSendMessage() async {
    if (_messageController.text.isNotEmpty) {
      try {
        // Send the message
        await _messagingService.sendMessage(
          _messageController.text,
          widget.receiverId,
        );

        // If user sent the first message and is not a dietician, add to request list
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.receiverId)
            .get();

        List<dynamic> requestList = userDoc['danisanlar-istek'] ?? [];

        if (!requestList.contains(_messagingService.auth.currentUser!.uid)) {
          requestList.add(_messagingService.auth.currentUser!.uid);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.receiverId)
              .update({
            'danisanlar-istek':
                FieldValue.arrayUnion([_messagingService.auth.currentUser!.uid])
          });
        }

        _messageController.clear();
        _refreshKey.currentState
            ?.show(); // Refresh the screen after sending the message
      } catch (e) {
        print('Message sending error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () async {
            // Navigate to different screens based on user type
            DocumentSnapshot userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(_messagingService.auth.currentUser!.uid)
                .get();
            String userType = userDoc['userType'];

            if (userType == "kullanici") {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DietcianProfileScreen()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ClientProfileScreen(uid: widget.receiverId)),
              );
            }
          },
          child: Text('Kullanici Profil Tıkla'),
        ),
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
                  key: _refreshKey,
                  onRefresh: _handleRefresh,
                  child: ListView.builder(
                    key: UniqueKey(),
                    reverse: false, // To display messages from bottom to top
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      Message message = messages[index];
                      bool isMyMessage = message.senderId ==
                          _messagingService.auth.currentUser!.uid;
                      return Align(
                        alignment: isMyMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          margin:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color:
                                isMyMessage ? Colors.purple : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message.content,
                            style: TextStyle(
                                color:
                                    isMyMessage ? Colors.white : Colors.black),
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
                    enabled:
                        !disableInput, // Enable TextField based on condition
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: disableInput
                      ? null // Disable IconButton based on condition
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
    _loadMessages(); // Handle refresh logic here
  }

  @override
  void dispose() {
    _messageController.dispose();
    _streamController.close();
    super.dispose();
  }
}
