import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/screens/dietician/personal_dietcian_create_screen.dart';
import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:diyetisyenapp/widget/flash_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_transition/page_transition.dart';

class ClientProfileScreen extends StatefulWidget {
  final String uid;
  const ClientProfileScreen({super.key, required this.uid});

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
  String alergy_food = "";
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
          alergy_food = userDoc["alergy_food"] ?? "";
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
      // Diyet programının başladığı günü ekleyin
      selectedDiet['startDate'] = DateTime.now();

      // Meals koleksiyonunu referans edin
      var mealsCollectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('dietProgram')
          .doc('weeklyProgram')
          .collection('meals');

      // Meals koleksiyonunu kontrol edin
      var mealsSnapshot = await mealsCollectionRef.get();

      // Eğer meals koleksiyonunda öge varsa, koleksiyonu silin
      if (mealsSnapshot.docs.isNotEmpty) {
        WriteBatch batch = FirebaseFirestore.instance.batch();
        for (var doc in mealsSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // Diyet programını kaydedin
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('dietProgram')
          .doc('weeklyProgram')
          .set(selectedDiet);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Diyet programı başarıyla kaydedildi."),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Error adding diet program: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Diyet programı kaydedilirken hata oluştu."),
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
          title: const Text("Diyet Programı Onayı"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Seçilen Diyet Listesi:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: selectedDiet.entries.map((entry) {
                    List<Widget> entryWidgets =
                        []; // Widget list for each entry
                    entryWidgets.add(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.key}:',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    );

                    // Check if the value is a map
                    if (entry.value is Map<String, dynamic>) {
                      // Iterate over inner map entries
                      (entry.value as Map<String, dynamic>)
                          .forEach((key, value) {
                        entryWidgets.add(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Text(
                                '$key:',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: (value as Map<String, dynamic>)
                                    .entries
                                    .map((mealEntry) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 5),
                                      Text(
                                        '${mealEntry.key}: ${mealEntry.value['diet']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                          'Calories: ${mealEntry.value['calories']} kcal'),
                                      Text(
                                          'Protein: ${mealEntry.value['protein']}%'),
                                      Text(
                                          'Carbs: ${mealEntry.value['carbs']}%'),
                                      Text('Fat: ${mealEntry.value['fat']}%'),
                                      Text(
                                          'Water: ${mealEntry.value['water']} ml'),
                                      const SizedBox(height: 10),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      });
                    } else {
                      // If the value is not a map, directly add it
                      entryWidgets.add(
                        Text(
                          '${entry.value}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }

                    // Add entry widgets to the main list
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: entryWidgets,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Vazgeç"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text("Evet, Kaydet"),
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
          title: const Text("Kullanıcıyı Çıkarma Onayı"),
          content:
              const Text("Bu kullanıcıyı çıkarmak istediğinize emin misiniz?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Vazgeç"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text("Evet, Çıkar"),
              onPressed: () {
                Navigator.of(context).pop();
                removeUserDietcian();
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
        title: const Text("Profil",
            style: TextStyle(fontSize: 25, color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.blue),
            onPressed: () {
              // Chat icon pressed action
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: profilePhoto == ""
                    ? const AssetImage('assets/images/avatar.jpg')
                    : NetworkImage(profilePhoto) as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Profil Bilgileri",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            Text(
              "Beğenmediği Yiyecekler:",
              style: fontStyle(20, Colors.black, FontWeight.bold),
            ),
            Text(
              unliked_food == "" ? "Veri Bulunamadı" : unliked_food,
              style: fontStyle(16, Colors.black, FontWeight.normal),
            ),
            const SizedBox(height: 10),
            Text(
              "Alerjisi Olduğu Yiyecekler:",
              style: fontStyle(20, Colors.black, FontWeight.bold),
            ),
            Text(
              alergy_food == "" ? "Veri Bulunamadı" : alergy_food,
              style: fontStyle(16, Colors.black, FontWeight.normal),
            ),
            const SizedBox(height: 20),
            Text(
              "Diyet Listeleri:",
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
            const SizedBox(height: 20),
            MyButton(
              onPressed: () {
                Navigator.push(
                    context,
                    PageTransition(
                        child: PersonalDietcianCreateScreen(
                          userUid: widget.uid,
                        ),
                        type: PageTransitionType.fade));
              },
              // showRemoveClientDialog,
              text: "Kişiye özel diyet programı tanımla",
              buttonColor: Colors.amber, buttonTextSize: 16,
              buttonTextColor: Colors.black, buttonTextWeight: FontWeight.bold,
            ),
            const SizedBox(height: 20),
            MyButton(
              onPressed: showRemoveClientDialog,
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

  Future<void> removeUserDietcian() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final String dietcianUid = user!.uid;
      final String userUid = widget.uid;

      // user'ın uid'sinin altındaki dietician-person-uid yerine [] atanacak
      await firestore.collection('users').doc(userUid).update({
        'dietician-person-uid': [],
      });

      // diyetisyenin uid'sinin altındaki dietician-danisanlar-uid ve danisanlar-istek listelerinden user'ın uid'si silinecek
      await firestore.collection('users').doc(dietcianUid).update({
        'danisanlar-istek': FieldValue.arrayRemove([userUid]),
      });
      await firestore.collection('users').doc(dietcianUid).update({
        'dietician-danisanlar-uid': FieldValue.arrayRemove([userUid]),
      });

      // messages koleksiyon altından mesajlara bakılıp receiverId ve senderId birbirlerine olan mesajları sileceksin
      QuerySnapshot messages = await firestore
          .collection('messages')
          .where('receiverId', isEqualTo: dietcianUid)
          .where('senderId', isEqualTo: userUid)
          .get();
      for (DocumentSnapshot message in messages.docs) {
        await message.reference.delete();
      }
      messages = await firestore
          .collection('messages')
          .where('receiverId', isEqualTo: userUid)
          .where('senderId', isEqualTo: dietcianUid)
          .get();
      for (DocumentSnapshot message in messages.docs) {
        await message.reference.delete();
      }

      showSuccessSnackBar(context, "Kullanıcı başarıyla kaldırıldı.");

      Navigator.pop(context); // Önceki ekrana geri dön
      Navigator.pop(context); // Önceki ekrana geri dön
    } catch (e) {
      print("Kullanıcı verisi silinirken hata oluştu: $e");
      showErrorSnackBar(context, "Kullanıcı verisi silinirken hata oluştu: $e");
    }
  }
}
