import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diyetisyenapp/screens/dietician/message_screen.dart';
import 'package:diyetisyenapp/widget/buttons.dart';

// class DieticianHomeScreen extends StatelessWidget {
class DieticianHomeScreen extends StatelessWidget {
  const DieticianHomeScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text("Diyetisyen Sayfası"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sohbetler",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Sohbet Kutuları",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ClientChats(currentUserUid: _auth.currentUser!.uid),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "İstek Atan Kullanıcılar",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child:
                        RequestedUsers(currentUserUid: _auth.currentUser!.uid),
                  ),
                ],
              ),
            ),
            MyButton(
              text: "Sign Out",
              buttonColor: Colors.black,
              buttonTextColor: Colors.blue,
              buttonTextSize: 15,
              buttonTextWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }
}

class ClientChats extends StatelessWidget {
  final String currentUserUid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ClientChats({required this.currentUserUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(currentUserUid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        var dieticianData = snapshot.data!.data() as Map<String, dynamic>?;

        if (dieticianData == null ||
            !dieticianData.containsKey('dietician-danisanlar-uid')) {
          return Center(child: Text('No clients available'));
        }

        List<String> clientUids =
            List<String>.from(dieticianData['dietician-danisanlar-uid']);

        return ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: clientUids.length,
          itemBuilder: (context, index) {
            String clientId = clientUids[index];

            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(clientId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: 72.0,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (userSnapshot.hasError) {
                  return ListTile(title: Text('Error fetching data'));
                }

                var userData =
                    userSnapshot.data!.data() as Map<String, dynamic>?;

                if (userData == null) {
                  return ListTile(title: Text('No user data'));
                }

                String clientName = userData['name'] ?? 'Unknown User';

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    title: Text(
                      clientName,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      clientId,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        clientName[0].toUpperCase(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MessagingScreen(receiverId: clientId),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class RequestedUsers extends StatelessWidget {
  final String currentUserUid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RequestedUsers({required this.currentUserUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(currentUserUid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        var dieticianData = snapshot.data!.data() as Map<String, dynamic>?;

        if (dieticianData == null ||
            !dieticianData.containsKey('danisanlar-istek')) {
          return Center(child: Text('No requested users available'));
        }

        List<String> requestUids =
            List<String>.from(dieticianData['danisanlar-istek']);

        return ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: requestUids.length,
          itemBuilder: (context, index) {
            String requestId = requestUids[index];

            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(requestId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: 72.0,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (userSnapshot.hasError) {
                  return ListTile(title: Text('Error fetching data'));
                }

                var userData =
                    userSnapshot.data!.data() as Map<String, dynamic>?;

                if (userData == null) {
                  return ListTile(title: Text('No user data'));
                }

                String userName = userData['name'] ?? 'Unknown User';

                // Check if the user is already a client of the dietitian
                if (dieticianData.containsKey('dietician-danisanlar-uid')) {
                  List<String> clientUids = List<String>.from(
                      dieticianData['dietician-danisanlar-uid']);
                  if (clientUids.contains(requestId)) {
                    // If the user is already a client, don't show in requests
                    return SizedBox.shrink();
                  }
                }

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    elevation: 3,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      title: Text(
                        userName,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        requestId,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Text(
                          userName[0].toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MessagingScreen(receiverId: requestId),
                          ),
                        );
                        // Implement your action here (e.g., accept or reject the request)
                        // For now, it navigates to the messaging screen with the requestId
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
