import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientProfileScreen extends StatefulWidget {
  final dynamic uid;
  const ClientProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  String name = "Bilgi Bulunamadı";
  int age = 0;
  double height = 0.0;
  double weight = 0.0;
  List<String> likedFoods = [];
  List<String> dislikedFoods = [];
  List<Map<String, dynamic>> dietOptions = [];
  Map<String, dynamic> selectedDiet = {};

  @override
  void initState() {
    super.initState();
    // Fetch user data using widget.uid and update state variables
    fetchData(widget.uid);
    // Fetch diet plans from Firestore
    fetchDietPlans();
  }

  void fetchData(dynamic uid) {
    // Simulated fetch data function (replace with actual fetching logic)
    // For now, setting example values
    setState(() {
      name = "John Doe";
      age = 35;
      height = 180.0;
      weight = 75.0;
      likedFoods = ["Salmon", "Avocado"];
      dislikedFoods = ["Ice cream", "Burger"];
    });
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
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference users = firestore.collection('users');

      await users
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
                "Profil", // Assuming this is the client's name or a chat identifier
                style: TextStyle(fontSize: 25, color: Colors.black),
              ),
            ),
            IconButton(
              icon: Icon(Icons.chat,
                  color:
                      Colors.blue), // Assuming mainColor is defined somewhere
              onPressed: () {
                // Chat icon pressed action
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Profil Bilgileri",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Adı: $name", style: TextStyle(fontSize: 16)),
            Text("Yaş: $age", style: TextStyle(fontSize: 16)),
            Text("Boy: ${height.toStringAsFixed(1)} cm",
                style: TextStyle(fontSize: 16)),
            Text("Kilo: ${weight.toStringAsFixed(1)} kg",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text(
              "Beğendiği Yiyecekler:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: likedFoods.isEmpty
                  ? [Text("Veri Bulunamadı")]
                  : likedFoods
                      .map((food) => Text(food, style: TextStyle(fontSize: 16)))
                      .toList(),
            ),
            SizedBox(height: 10),
            Text(
              "Beğenmediği Yiyecekler:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: dislikedFoods.isEmpty
                  ? [Text("Veri Bulunamadı")]
                  : dislikedFoods
                      .map((food) => Text(food, style: TextStyle(fontSize: 16)))
                      .toList(),
            ),
            SizedBox(height: 20),
            Text(
              "Örnek Diyet Listeleri:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          ],
        ),
      ),
    );
  }
}
