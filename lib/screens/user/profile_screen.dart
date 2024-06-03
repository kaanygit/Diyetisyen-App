import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diyetisyenapp/widget/privacy.dart';
import 'package:diyetisyenapp/widget/term_condition.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/database/firebase.dart';
import 'package:diyetisyenapp/screens/user/user_edit_profile_screen.dart';
import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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
              Icons.person,
              color: mainColor,
            )
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: userData?.get('profilePhoto') == "" ||
                                userData?.get('profilePhoto') == null
                            ? const AssetImage("assets/images/avatar.jpg")
                            : NetworkImage(userData?.get('profilePhoto'))
                                as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      // padding: const EdgeInsets.symmetric(horizontal: 5),
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
                          profileButtonsColumn("Arkadaşlarınla Paylaş"),
                          profileButtonsColumn("Gizlilik Politikası"),
                          profileButtonsColumn("Kullanım Koşulları"),
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
                              await Future.delayed(const Duration(seconds: 2));
                              FirebaseOperations().signOut(context);
                            },
                            text: "Çıkış Yap",
                            buttonColor: mainColor,
                            buttonTextColor: Colors.white,
                            buttonTextSize: 15,
                            buttonTextWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 5),
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
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      // padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label:",
            style: fontStyle(15, Colors.black, FontWeight.bold),
          ),
          Text(
            value,
            style: fontStyle(15, Colors.black, FontWeight.normal),
          ),
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
          if (text == "Arkadaşlarınla Paylaş") {
            _launchURL('https://diyetisyenapp.com/');
          } else if ("Gizlilik Politikası" == text) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyPage(),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TermsOfUsePage(),
              ),
            );
          }
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

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Bağlantı açılamadı: $url';
    }
  }
}
