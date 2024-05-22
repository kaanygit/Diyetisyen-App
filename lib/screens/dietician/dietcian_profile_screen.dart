import 'package:flutter/material.dart';
import 'package:diyetisyenapp/constants/fonts.dart'; // Assuming you have a fonts file for styling

class DietcianProfileScreen extends StatefulWidget {
  const DietcianProfileScreen({Key? key}) : super(key: key);

  @override
  State<DietcianProfileScreen> createState() => _DietcianProfileScreenState();
}

class _DietcianProfileScreenState extends State<DietcianProfileScreen> {
  // Example dietician data (replace with actual data)
  String name = "Dr. Ayşe Özdemir";
  String specialization = "Klinik Diyetisyen";
  String experience = "7 yıllık deneyim";
  String welcomeMessage =
      "Merhaba! Ben Dr. Ayşe Özdemir. Sağlıklı beslenme ve diyet konularında size yardımcı olmaktan mutluluk duyarım.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage("assets/images/avatar.jpg"),
            ),
            Container(
              child: Text(
                "Sohbet",
                style: fontStyle(25, Colors.black, FontWeight.normal),
              ),
            ),
            Icon(
              Icons.chat,
              color: mainColor,
            )
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Diyetisyen Profili",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Adı: $name"),
            ),
            ListTile(
              leading: Icon(Icons.badge),
              title: Text("Uzmanlık Alanı: $specialization"),
            ),
            ListTile(
              leading: Icon(Icons.work),
              title: Text("Deneyim: $experience"),
            ),
            SizedBox(height: 20),
            Text(
              "Hoş Geldiniz Mesajı:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              welcomeMessage,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
