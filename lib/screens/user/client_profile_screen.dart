import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientProfileScreen extends StatefulWidget {
  final String uid;
  const ClientProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  String name = "Bilgi Bulunamadı";
  int age = 0;
  double height = 0;
  double weight = 0;
  String profilePhoto = "";
  String unliked_food = "";
  List<Map<String, dynamic>> dietOptions = [];
  Map<String, dynamic> selectedDiet = {};

  @override
  void initState() {
    super.initState();
    fetchData(widget.uid);
    fetchDietPlans();
  }

  Future<void> fetchData(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          name = userDoc['displayName'] ?? 'Bilgi Bulunamadı';
          age = userDoc['age'] ?? 0;
          height = (userDoc['height'] ?? 0).toDouble(); // Boy
          weight = (userDoc['weight'] ?? 0).toDouble();
          profilePhoto = userDoc['profilePhoto'] ?? '';
          unliked_food = userDoc['unliked_food'] ?? "";
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> fetchDietPlans() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('diet_list').get();
      setState(() {
        dietOptions = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error fetching diet plans: $e');
    }
  }

  Future<void> addToDietProgram() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('dietProgram')
          .doc('weeklyProgram')
          .set(selectedDiet);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Diyet programı başarıyla kaydedildi."),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Error adding diet program: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Diyet programı kaydedilirken hata oluştu."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> removeClient() async {
    try {
      String dieticianId =
          'dietician_id_placeholder'; // Replace with actual dietician ID
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Remove client UID from dietician-danisanlar collection
      await firestore
          .collection('dietician-danisanlar')
          .doc(dieticianId)
          .collection('clients')
          .doc(widget.uid)
          .delete();

      // Remove dietician UID from dietician-person collection
      await firestore.collection('dietician-person').doc(widget.uid).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kullanıcı başarıyla çıkarıldı."),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pop(); // Navigate back to the previous screen
    } catch (e) {
      print("Error removing client: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kullanıcı çıkarılırken hata oluştu."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Diyet Programı Onayı"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Seçilen Diyet Listesi:"),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: selectedDiet.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key}:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (entry.key == 'meals')
                              ...entry.value.entries.map((mealEntry) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${mealEntry.key}:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Diet: ${mealEntry.value['diet']}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'Calories: ${mealEntry.value['calories']} kcal'),
                                            Text(
                                                'Protein: ${mealEntry.value['protein']}%'),
                                            Text(
                                                'Carbs: ${mealEntry.value['carbs']}%'),
                                            Text(
                                                'Fat: ${mealEntry.value['fat']}%'),
                                            Text(
                                                'Water: ${mealEntry.value['water']} ml'),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                );
                              }).toList()
                            else
                              Text('${entry.value}'),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Vazgeç"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Evet, Kaydet"),
              onPressed: () {
                Navigator.of(context).pop();
                addToDietProgram();
              },
            ),
          ],
        );
      },
    );
  }

  void showRemoveClientDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Kullanıcıyı Çıkarma Onayı"),
          content: Text("Bu kullanıcıyı çıkarmak istediğinize emin misiniz?"),
          actions: <Widget>[
            TextButton(
              child: Text("Vazgeç"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Evet, Çıkar"),
              onPressed: () {
                Navigator.of(context).pop();
                removeClient();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:
            Text("Profil", style: TextStyle(fontSize: 25, color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(Icons.chat, color: Colors.blue),
            onPressed: () {
              // Chat icon pressed action
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: profilePhoto.isEmpty
                    ? AssetImage('assets/images/default_avatar.jpg')
                    : NetworkImage(profilePhoto) as ImageProvider,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Profil Bilgileri",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Adı: $name",
              style: fontStyle(16, Colors.black, FontWeight.normal),
            ),
            Text(
              "Yaş: $age",
              style: fontStyle(16, Colors.black, FontWeight.normal),
            ),
            Text(
              "Boy: ${height.toStringAsFixed(1)} cm",
              style: fontStyle(16, Colors.black, FontWeight.normal),
            ),
            Text("Kilo: ${weight.toStringAsFixed(1)} kg",
                style: fontStyle(16, Colors.black, FontWeight.normal)),
            SizedBox(height: 10),
            Text(
              "Beğenmediği Yiyecekler:",
              style: fontStyle(20, Colors.black, FontWeight.bold),
            ),
            Text(
              unliked_food == "" ? "Veri Bulunamadı" : unliked_food,
              style: fontStyle(16, Colors.black, FontWeight.normal),
            ),
            SizedBox(height: 20),
            Text(
              "Örnek Diyet Listeleri:",
              style: fontStyle(20, Colors.black, FontWeight.bold),
            ),
            Column(
              children: List.generate(dietOptions.length, (index) {
                return ListTile(
                  title: Text("Diyet Seçeneği ${index + 1}"),
                  onTap: () {
                    setState(() {
                      selectedDiet = dietOptions[index];
                    });
                    showConfirmationDialog();
                  },
                );
              }),
            ),
            SizedBox(height: 20),
            MyButton(
              onPressed: () => print("hello"),
              // showRemoveClientDialog,
              text: "Kullanıcıyı Çıkar",
              buttonColor: mainColor, buttonTextSize: 16,
              buttonTextColor: Colors.white, buttonTextWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }
}
