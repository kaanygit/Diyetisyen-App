import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore kütüphanesi

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
  List<List<String>> dietOptions = [];
  List<String> selectedDiet = [];

  @override
  void initState() {
    super.initState();
    // Fetch user data using widget.uid and update state variables
    fetchData(widget.uid);

    // Initialize example diet options
    dietOptions = [
      [
        "Kahvaltı: Yulaf ezmesi ve meyve",
        "Öğle yemeği: Tavuklu salata",
        "Akşam yemeği: Somon ve brokoli"
      ],
      [
        "Kahvaltı: Yoğurt ve granola",
        "Öğle yemeği: Izgara balık ve sebzeler",
        "Akşam yemeği: Tavuk sote"
      ],
      [
        "Kahvaltı: Yumurta ve tam buğday ekmeği",
        "Öğle yemeği: Mercimek çorbası ve salata",
        "Akşam yemeği: Sebze sote"
      ],
    ];
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

  Future<void> addToDietProgram() async {
    try {
      // Access Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Replace 'users' with your Firestore collection name
      CollectionReference users = firestore.collection('users');

      // Replace 'userID' with the actual user ID (widget.uid)
      await users
          .doc(widget.uid)
          .collection('dietProgram')
          .doc('weeklyProgram')
          .set({
        'week1': {
          'Monday': {
            'diet': selectedDiet,
            'calories':
                calculateCalories(selectedDiet), // Calculate calories function
            'fat': calculateFat(selectedDiet), // Calculate fat function
            'protein':
                calculateProtein(selectedDiet), // Calculate protein function
            'carbs': calculateCarbs(selectedDiet), // Calculate carbs function
          },
          'Tuesday': {
            'diet': selectedDiet,
            'calories': calculateCalories(selectedDiet),
            'fat': calculateFat(selectedDiet),
            'protein': calculateProtein(selectedDiet),
            'carbs': calculateCarbs(selectedDiet),
          },
          // Add other days for week 1
        },
        'week2': {
          // Add days for week 2
        },
        // Add other weeks as needed
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Diyet programı başarıyla kaydedildi."),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Handle errors
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Seçilen Diyet Listesi:"),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: selectedDiet.map((item) => Text(item)).toList(),
              ),
            ],
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

  double calculateCalories(List<String> diet) {
    double totalCalories = 0.0;

    // Example calorie values per food item (replace with actual data)
    Map<String, double> calorieValues = {
      "Yulaf ezmesi ve meyve": 300.0,
      "Tavuklu salata": 400.0,
      "Somon ve brokoli": 350.0,
      "Yoğurt ve granola": 250.0,
      "Izgara balık ve sebzeler": 380.0,
      "Tavuk sote": 370.0,
      "Yumurta ve tam buğday ekmeği": 320.0,
      "Mercimek çorbası ve salata": 280.0,
      "Sebze sote": 300.0,
    };

    // Calculate total calories based on selected diet
    for (String food in diet) {
      if (calorieValues.containsKey(food)) {
        totalCalories += calorieValues[food]!;
      }
    }

    return totalCalories;
  }

  double calculateFat(List<String> diet) {
    // Calculate total fat content based on selected diet
    // Replace with actual calculation logic
    return 0.0; // Placeholder
  }

  double calculateProtein(List<String> diet) {
    // Calculate total protein content based on selected diet
    // Replace with actual calculation logic
    return 0.0; // Placeholder
  }

  double calculateCarbs(List<String> diet) {
    // Calculate total carbs content based on selected diet
    // Replace with actual calculation logic
    return 0.0; // Placeholder
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
