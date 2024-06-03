import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DieticianProfileScreen extends StatefulWidget {
  final String uid;
  const DieticianProfileScreen({super.key, required this.uid});

  @override
  State<DieticianProfileScreen> createState() => _DieticianProfileScreenState();
}

class _DieticianProfileScreenState extends State<DieticianProfileScreen> {
  String name = "Bilgi Bulunamadı";
  String profilePhoto = "";
  int experience = 0;
  String expertise = "Bilgi Bulunamadı";
  int age = 0;
  String educationLevel = "Bilgi Bulunamadı";
  String title = "Bilgi Bulunamadı";
  String welcomeMessage = "Bilgi Bulunamadı";

  @override
  void initState() {
    super.initState();
    fetchData(widget.uid);
  }

  Future<void> fetchData(String uid) async {
    try {
      DocumentSnapshot dieticianDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (dieticianDoc.exists) {
        setState(() {
          name = dieticianDoc['displayName'] ?? 'Bilgi Bulunamadı';
          profilePhoto = dieticianDoc['profilePhoto'] ?? '';
          experience = dieticianDoc['experience'] ?? 0;
          expertise = dieticianDoc['expertise'] ?? 'Bilgi Bulunamadı';
          age = dieticianDoc['age'] ?? 0;
          educationLevel = dieticianDoc['educationLevel'] ?? 'Bilgi Bulunamadı';
          title = dieticianDoc['title'] ?? 'Bilgi Bulunamadı';
          welcomeMessage =
              dieticianDoc['welcome_message'] ?? 'Bilgi Bulunamadı';
        });
      }
    } catch (e) {
      print('Error fetching dietician data: $e');
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
            CircleAvatar(
              radius: 20,
              backgroundImage: profilePhoto.isEmpty
                  ? const AssetImage("assets/images/avatar.jpg")
                  : NetworkImage(profilePhoto) as ImageProvider,
            ),
            const Text(
              "Sohbet",
              style: TextStyle(fontSize: 25, color: Colors.black),
            ),
            const Icon(
              Icons.chat,
              color: Colors.blue, // Assuming mainColor is defined somewhere
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Diyetisyen Profili",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text("Adı: $name"),
              ),
              ListTile(
                leading: const Icon(Icons.badge),
                title: Text("Uzmanlık Alanı: $expertise"),
              ),
              ListTile(
                leading: const Icon(Icons.school),
                title: Text("Eğitim Seviyesi: $educationLevel"),
              ),
              ListTile(
                leading: const Icon(Icons.work),
                title: Text("Deneyim: ${experience.toString()}"),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text("Yaş: $age"),
              ),
              ListTile(
                leading: const Icon(Icons.title),
                title: Text("Ünvan: $title"),
              ),
              const SizedBox(height: 20),
              const Text(
                "Hoş Geldiniz Mesajı:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                welcomeMessage,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
