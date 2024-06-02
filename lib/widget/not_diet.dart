import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotDiet extends StatefulWidget {
  const NotDiet({Key? key}) : super(key: key);

  @override
  State<NotDiet> createState() => _NotDietState();
}

class _NotDietState extends State<NotDiet> {
  late String profilePhoto = "";

  @override
  void initState() {
    super.initState();
    fetchProfilePhotos();
  }

  Future<void> fetchProfilePhotos() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String? uid = user?.uid;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot =
          await firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          profilePhoto = data['profilePhoto'] ?? "";
        });
      }
    } catch (e) {
      print("Error fetching diet program: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              mainColor,
              Colors.white,
            ],
            stops: const [
              0.1,
              0.75,
            ],
          ),
        ),
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (profilePhoto.isEmpty)
                Container(
                  child: CircleAvatar(
                    backgroundImage: AssetImage(
                      "assets/images/avatar.jpg",
                      // width: 100,
                      // height: 100,
                    ),
                    radius: 40,
                  ),
                ),
              if (profilePhoto.isNotEmpty)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(profilePhoto),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  "Diyet listeniz bulunmamaktadır :(",
                  style: fontStyle(18, mainColor, FontWeight.normal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
