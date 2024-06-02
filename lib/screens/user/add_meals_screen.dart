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
  List<Map<String, dynamic>> _meals = [];
  List<Map<String, dynamic>> _filteredMeals = [];
  List<Map<String, dynamic>> _displayedMeals = [];
  bool _showAiBox = true;
  bool _isLoading = false;
  int _maxMealsToShow = 10;
  bool isDietData = false;
  final ScrollController _scrollController = ScrollController();
  late Future<void> _imageLoaderFuture;

  @override
  void initState() {
    super.initState();
    getProfileDietDataAvaliable();
    _getFoodsFromFirestore();
    _scrollController.addListener(_scrollListener);
    _imageLoaderFuture = _loadImages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadImages() async {
    await Future.wait(_meals
        .map((meal) =>
            precacheImage(NetworkImage(meal['photoUrl'] ?? ''), context))
        .toList());
  }

  Future<void> _getFoodsFromFirestore() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('foods').get();

    setState(() {
      _meals = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      _filteredMeals = _meals;
      _displayedMeals = _filteredMeals.take(_maxMealsToShow).toList();
    });
  }

  void _filterMeals(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredMeals = _meals;
      });
    } else {
      setState(() {
        _filteredMeals = _meals
            .where((meal) =>
                meal['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
    _updateDisplayedMeals();
  }

  void _updateDisplayedMeals() {
    setState(() {
      _displayedMeals = _filteredMeals.take(_maxMealsToShow).toList();
    });
  }

  void _loadMoreMeals() {
    setState(() {
      _maxMealsToShow += 10;
      _updateDisplayedMeals();
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreMeals();
    }
  }

  Future<void> getProfileDietDataAvaliable() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot<Map<String, dynamic>> snapshotEating = await firestore
          .collection('users')
          .doc(user!.uid)
          .collection('dietProgram')
          .get();

      if (snapshotEating.docs.isNotEmpty) {
        setState(() {
          isDietData = true;
        });
      } else {
        setState(() {
          isDietData = false;
        });
      }
    } catch (e) {
      print("Diyet Listesi getirilirken hata oluştu : $e");
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
                  isDietData
                      ? Expanded(
                          child: GridView.builder(
                            controller: _scrollController,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 3 / 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: _displayedMeals.length,
                            itemBuilder: (context, index) {
                              final meal = _displayedMeals[index];
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            meal['photoUrl'] ?? '',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          meal['name'] ?? 'Unnamed',
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
                        )
                      : Expanded(
                          child: Center(
                          child: Text(
                            "Lütfen diyet listenizi diyetisyeninizden isteyiniz !",
                            style: fontStyle(
                              25,
                              mainColor,
                              FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )),
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
          builder: (context) => AiObjectDetectionScreen(
              imagePath: pickedFile.path, dietData: isDietData),
        ),
      );
    }
  }
}

class MealDetailScreen extends StatelessWidget {
  final Map<String, dynamic> meal;

  const MealDetailScreen({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal['name'] ?? 'Unnamed'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                  child: Image.network(
                    meal['photoUrl'] ?? '',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  meal['name'] ?? 'Unnamed',
                  style: fontStyle(25, mainColor, FontWeight.bold),
                ),
              ),
              SizedBox(height: 16),
              Divider(color: Colors.grey[400]),
              SizedBox(height: 16),
              _buildNutrientRow('Kalori', '${meal['kalori'] ?? 0} kcal'),
              _buildNutrientRow('Yağ', '${meal['yağ'] ?? 0} Gram'),
              _buildNutrientRow(
                  'Karbonhidrat', '${meal['karbonhidrat'] ?? 0} Gram'),
              _buildNutrientRow('Protein', '${meal['protein'] ?? 0} Gram'),
              SizedBox(height: 25),
              MyButton(
                  text: "Yemeği Ekle",
                  buttonColor: mainColor,
                  buttonTextColor: Colors.white,
                  buttonTextSize: 16,
                  buttonTextWeight: FontWeight.bold,
                  onPressed: () async {
                    await FirebaseOperations().addMealsFirebase(context, meal);
                  })
            ],
          ),
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
