import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/database/firebase.dart';
import 'package:diyetisyenapp/screens/dietician/message_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DietitiansRequestScreen extends StatefulWidget {
  const DietitiansRequestScreen({Key? key}) : super(key: key);

  @override
  State<DietitiansRequestScreen> createState() =>
      _DietitiansRequestScreenState();
}

class _DietitiansRequestScreenState extends State<DietitiansRequestScreen> {
  final FirebaseOperations _firebase = FirebaseOperations();
  late List<Map<String, dynamic>> diyetisyenVeri = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getDieticians();
  }

  Future<void> getDieticians() async {
    try {
      List<Map<String, dynamic>> data = await _firebase.getDieticianData();
      setState(() {
        diyetisyenVeri = data;
        isLoading = false; // Veri geldiğinde loading durumu sonlandırılıyor
      });
    } catch (e) {
      print("Error fetching dieticians: $e");
      setState(() {
        isLoading = false; // Hata durumunda da loading durumu sonlandırılıyor
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
              child: Text(
                "Diyetisyen Seçme",
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
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Loading durumu
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: diyetisyenVeri.map((diyetisyen) {
                    return dietitianContainer(diyetisyen);
                  }).toList(),
                ),
              ),
            ),
    );
  }

  Column dietitianContainer(Map<String, dynamic> diyetisyen) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            print("Diyetisyene yaz");
            print("Diyetisyen UİD: ${diyetisyen['id']}");
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MessagingScreen(
                        receiverId: diyetisyen['id'],
                      )),
            );
          },
          child: Container(
            decoration: BoxDecoration(
                color: mainColor2, borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Row(
                    children: [
                      const CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              AssetImage("assets/images/avatar.jpg")),
                      const SizedBox(
                        width: 8,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            diyetisyen['displayName'] ?? "Diyetisyen Adı",
                            style: fontStyle(15, Colors.black, FontWeight.bold),
                          ),
                          Text(
                            diyetisyen['uid'] ?? "Biyografi yok",
                            style:
                                fontStyle(12, Colors.grey, FontWeight.normal),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  child: IconButton(
                    onPressed: () {
                      print("İÇİNE GİR");
                    },
                    iconSize: 20,
                    color: Colors.black,
                    icon: const Icon(Icons.arrow_forward_ios),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}
