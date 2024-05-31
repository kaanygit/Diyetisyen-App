import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/database/firebase.dart';
import 'package:diyetisyenapp/screens/user/ai_object_detection_screen.dart';
import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:diyetisyenapp/widget/my_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddMeals extends StatefulWidget {
  const AddMeals({super.key});

  @override
  State<AddMeals> createState() => _AddMealsState();
}

class _AddMealsState extends State<AddMeals> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _meals = [
    {'name': 'Elma', 'image': 'assets/images/apple.jpg'},
    {'name': 'Pilav', 'image': 'assets/images/rice.jpg'},
    {'name': 'Makarna', 'image': 'assets/images/pasta.jpg'},
    {'name': 'Tavuk', 'image': 'assets/images/chicken.jpg'},
    {'name': 'Salata', 'image': 'assets/images/salad.jpg'},
    {'name': 'Kek', 'image': 'assets/images/cake.jpg'},
    {'name': 'Pizza', 'image': 'assets/images/pizza.jpg'},
    {'name': 'Balık', 'image': 'assets/images/fish.jpg'},
    {'name': 'Yoğurt', 'image': 'assets/images/yogurt.jpg'},
    {'name': 'Karpuz', 'image': 'assets/images/watermelon.jpg'},
  ];
  List<Map<String, dynamic>> _filteredMeals = [];
  bool _showAiBox = true;
  late Future<void> _imageLoaderFuture;

  @override
  void initState() {
    super.initState();
    _filteredMeals = _meals;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _imageLoaderFuture = _loadImages();
  }

  Future<void> _loadImages() async {
    await Future.wait(_meals
        .map((meal) => precacheImage(AssetImage(meal['image']), context))
        .toList());
  }

  void _filterMeals(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredMeals = _meals;
        _showAiBox = true;
      });
    } else {
      setState(() {
        _filteredMeals = _meals
            .where((meal) =>
                meal['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
        _showAiBox = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yemek Ekle'),
      ),
      body: FutureBuilder<void>(
        future: _imageLoaderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  MyTextField(
                    controller: _searchController,
                    hintText: "Arama",
                    onChanged: _filterMeals,
                    obscureText: false,
                    prefixIcon: Icon(Icons.search),
                    keyboardType: TextInputType.multiline,
                    enabled: true,
                  ),
                  if (_showAiBox) _buildAiBox(),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3 / 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _filteredMeals.length,
                      itemBuilder: (context, index) {
                        final meal = _filteredMeals[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MealDetailScreen(meal: meal),
                              ),
                            );
                          },
                          child: Card(
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      meal['image'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    meal['name'],
                                    style: fontStyle(
                                      15,
                                      Colors.black,
                                      FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildAiBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: mainColor3,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            Icon(Icons.lightbulb, size: 50, color: mainColor),
            SizedBox(width: 16),
            Expanded(
              child: Text('Yapay Zeka ile Yiyecek Tanıma'),
            ),
            ElevatedButton(
              onPressed: () {
                _navigateToAiObjectDetectionScreen();
              },
              style: ElevatedButton.styleFrom(backgroundColor: mainColor),
              child: Text(
                'Başlat',
                style: fontStyle(15, Colors.white, FontWeight.normal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAiObjectDetectionScreen() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AiObjectDetectionScreen(imagePath: pickedFile.path),
        ),
      );
    }
  }
}

Map<String, dynamic> meals = {
  'name': 'Akşam Yemeği',
  'foodName': 'Pilav',
  'calories': 450,
  'protein': 25,
  'fat': 12,
  'carbs': 55,
};

class MealDetailScreen extends StatelessWidget {
  final Map<String, dynamic> meal;

  const MealDetailScreen({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  meal['image'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                "${meal['name']}",
                style: fontStyle(25, mainColor, FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            Divider(color: Colors.grey[400]),
            SizedBox(height: 16),
            _buildNutrientRow('Kalori', '100 kcal'),
            _buildNutrientRow('Yağ', '0.5 Gram'),
            _buildNutrientRow('Karbonhidrat', '25 Gram'),
            _buildNutrientRow('Protein', '0.5 Gram'),
            SizedBox(height: 25),
            MyButton(
                text: "Yemeği Ekle",
                buttonColor: mainColor,
                buttonTextColor: Colors.white,
                buttonTextSize: 16,
                buttonTextWeight: FontWeight.bold,
                onPressed: () async {
                  await FirebaseOperations().addMealsFirebase(context, meals);
                })
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String nutrient, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$nutrient:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 5),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
        ),
      ],
    );
  }
}
