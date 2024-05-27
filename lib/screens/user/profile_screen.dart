import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/database/firebase.dart';
import 'package:diyetisyenapp/screens/auth/auth_screen.dart';
import 'package:diyetisyenapp/screens/user/user_edit_profile_screen.dart';
import 'package:diyetisyenapp/widget/buttons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? currentUser;
  DocumentSnapshot<Map<String, dynamic>>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> data = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        currentUser = user;
        userData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: const Text("Profil"),
            ),
            Icon(
              Icons.power_off_outlined,
              color: mainColor,
            )
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      child: const CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage("assets/images/avatar.jpg"),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: mainColor3,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          buildProfileInfo(
                              "Email", userData?.get('email') ?? 'N/A'),
                          buildProfileInfo(
                              "Ad", userData?.get('displayName') ?? 'N/A'),
                          buildProfileInfo(
                              "Yaş", userData?.get('age').toString() ?? 'N/A'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: mainColor3,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          profileButtonsColumn("Share with friends"),
                          profileButtonsColumn("Contact support"),
                          profileButtonsColumn("Privacy policy"),
                          profileButtonsColumn("Terms & Conditions"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          MyButton(
                            onPressed: () async {
                              await Future.delayed(Duration(seconds: 2));
                              FirebaseOperations().signOut(context);
                            },
                            text: "Çıkış Yap",
                            buttonColor: mainColor,
                            buttonTextColor: Colors.white,
                            buttonTextSize: 15,
                            buttonTextWeight: FontWeight.bold,
                          ),
                          SizedBox(height: 5),
                          MyButton(
                            text: "Profili Düzenle",
                            buttonColor: Colors.yellow,
                            buttonTextColor: Colors.black,
                            buttonTextSize: 15,
                            buttonTextWeight: FontWeight.bold,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(
                                      currentUserUid: currentUser?.uid ?? ''),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildProfileInfo(String label, String value) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }

  Container profileButtonsColumn(String text) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 1.0)),
      ),
      child: InkWell(
        onTap: () {
          print("bastın");
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(text),
                const Icon(CupertinoIcons.arrow_right_square_fill),
              ],
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
