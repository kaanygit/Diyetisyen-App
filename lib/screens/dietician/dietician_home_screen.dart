import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/database/firebase.dart';
import 'package:diyetisyenapp/screens/auth/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diyetisyenapp/screens/dietician/message_screen.dart';
import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class DieticianHomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DieticianHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String uid = _auth.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text("Diyetisyen App - Diyetisyen",
            style: fontStyle(20, mainColor, FontWeight.bold)),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>?;

          if (userData != null && userData['dietcian_confirm'] == true) {
            return DieticianMainContent(currentUserUid: uid);
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Admin tarafından onay bekleniyor.Beklediğiniz için teşekkür ederiz.:)",
                    style: fontStyle(25, mainColor, FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  MyButton(
                      text: "Sign Out",
                      buttonColor: mainColor,
                      buttonTextColor: Colors.white,
                      buttonTextSize: 25,
                      buttonTextWeight: FontWeight.normal,
                      onPressed: () {
                        FirebaseOperations().signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AuthScreen()),
                        );
                      })
                ],
              )),
            );
          }
        },
      ),
    );
  }
}

class DieticianMainContent extends StatefulWidget {
  final String currentUserUid;

  DieticianMainContent({required this.currentUserUid});

  @override
  _DieticianMainContentState createState() => _DieticianMainContentState();
}

class _DieticianMainContentState extends State<DieticianMainContent> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ClientChats(currentUserUid: widget.currentUserUid),
      RequestedUsers(currentUserUid: widget.currentUserUid),
      ProfileScreen(currentUserUid: widget.currentUserUid),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          SalomonBottomBarItem(
              icon: Icon(Icons.chat),
              title: Text("Sohbet Kutuları"),
              selectedColor: mainColor,
              unselectedColor: Colors.grey),
          SalomonBottomBarItem(
              icon: Icon(Icons.person_add),
              title: Text("İstekler"),
              selectedColor: mainColor,
              unselectedColor: Colors.grey),
          SalomonBottomBarItem(
              icon: Icon(Icons.account_circle),
              title: Text("Profil"),
              selectedColor: mainColor,
              unselectedColor: Colors.grey),
        ],
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

                String clientName = userData['displayName'] ?? 'Unknown User';
                String userPhoto = userData['profilePhoto'] ?? "null";

                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MessagingScreen(receiverId: clientId),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: mainColor2,
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: userPhoto == "" ||
                                          userPhoto == "null"
                                      ? AssetImage("assets/images/gemini.jpg")
                                      : NetworkImage(userPhoto)
                                          as ImageProvider,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("$clientName",
                                        style: fontStyle(
                                            15, Colors.black, FontWeight.bold)),
                                    Text(
                                      "$clientId",
                                      style: fontStyle(
                                          15, Colors.grey, FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
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

                String userName = userData['displayName'] ?? 'Unknown User';
                String userPhoto = userData['profilePhoto'] ?? "null";

                // Check if the user is already a client of the dietitian
                if (dieticianData.containsKey('dietician-danisanlar-uid')) {
                  List<String> clientUids = List<String>.from(
                      dieticianData['dietician-danisanlar-uid']);
                  if (clientUids.contains(requestId)) {
                    // If the user is already a client, don't show in requests
                    return SizedBox.shrink();
                  }
                }

                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MessagingScreen(receiverId: requestId),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: mainColor2,
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: userPhoto == "" ||
                                          userPhoto == "null"
                                      ? AssetImage("assets/images/avatar.jpg")
                                      : NetworkImage(userPhoto)
                                          as ImageProvider,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("$userName",
                                        style: fontStyle(
                                            15, Colors.black, FontWeight.bold)),
                                    Text(
                                      "$requestId",
                                      style: fontStyle(
                                          15, Colors.grey, FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final String currentUserUid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProfileScreen({required this.currentUserUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(currentUserUid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>?;

          if (userData == null) {
            return Center(child: Text('Kullanıcı bilgileri bulunamadı.'));
          }

          String userName = userData['displayName'] ?? 'Kullanıcı Adı Yok';
          String userEmail = userData['email'] ?? 'E-posta Yok';
          String userAge = userData['age'] ?? 'Yaş Bilgisi Yok';
          String userPhoto = userData['profilePhoto'] ?? "ProfilFoto";

          return _buildProfileContent(
              userName, userEmail, userAge, userPhoto, context);
        },
      ),
    );
  }

  Widget _buildProfileContent(
    String userName,
    String userEmail,
    String userAge,
    String userPhoto,
    BuildContext context,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: userPhoto == "" || userPhoto == "ProfilFoto"
                  ? AssetImage("assets/images/avatar.jpg")
                  : NetworkImage(userPhoto) as ImageProvider,
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: mainColor2,
                borderRadius: BorderRadius.circular(15),
              ),
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileInfoRow(context, "Email", userEmail),
                  _buildProfileInfoRow(context, "Full Name", userName),
                  _buildProfileInfoRow(context, "Age", userAge),
                ],
              ),
            ),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: mainColor2,
                borderRadius: BorderRadius.circular(15),
              ),
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileButton(context, "Notification"),
                  _buildProfileButton(context, "Apply promo code"),
                  _buildProfileButton(context, "Join to the community"),
                  _buildProfileButton(context, "Share with friends"),
                  _buildProfileButton(context, "Contact support"),
                  _buildProfileButton(context, "Privacy policy"),
                  _buildProfileButton(context, "Terms & Conditions"),
                  _buildProfileButton(context, "Language"),
                ],
              ),
            ),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  MyButton(
                    onPressed: () {
                      FirebaseOperations().signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthScreen(),
                        ),
                      );
                    },
                    text: "Çıkış Yap",
                    buttonColor: mainColor,
                    buttonTextColor: Colors.white,
                    buttonTextSize: 15,
                    buttonTextWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(
    BuildContext context,
    String title,
    String value,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title + ":",
              style: fontStyle(15, Colors.black, FontWeight.bold)),
          Text(
            value,
            style: fontStyle(15, Colors.black, FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileButton(
    BuildContext context,
    String text,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 1.0)),
      ),
      child: InkWell(
        onTap: () {
          print("Tapped on $text");
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: fontStyle(15, Colors.black, FontWeight.bold),
            ),
            Icon(Icons.arrow_right),
          ],
        ),
      ),
    );
  }
}
