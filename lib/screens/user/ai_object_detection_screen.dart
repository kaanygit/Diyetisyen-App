import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/database/firebase.dart';
import 'package:diyetisyenapp/database/gemini.dart';
import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:flutter/material.dart';

class AiObjectDetectionScreen extends StatefulWidget {
  final bool dietData;
  final String imagePath;

  const AiObjectDetectionScreen(
      {super.key, required this.imagePath, required this.dietData});

  @override
  _AiObjectDetectionScreenState createState() =>
      _AiObjectDetectionScreenState();
}

class _AiObjectDetectionScreenState extends State<AiObjectDetectionScreen> {
  String? detectedFood;
  Map<String, dynamic>? foodData = {
    "name": "",
    "kalori": 0,
    "protein": 0,
    "yağ": 0,
    "karbonhidrat": 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchImageLabel();
  }

  Future<void> _fetchImageLabel() async {
    final label = await Gemini().geminImageLabelingPrompt(widget.imagePath);
    Map<String, dynamic> detectedFoodMap;

    setState(() {
      detectedFood = label ?? "Bir hata oluştu veya yiyecek algılanamadı.";
    });

    if (label != null) {
      try {
        detectedFoodMap = json.decode(label) as Map<String, dynamic>;
        setState(() {
          foodData = {
            "name": detectedFoodMap["name"],
            "kalori": int.parse(detectedFoodMap["kalori"].toString()),
            "protein": int.parse(detectedFoodMap["protein"].toString()),
            "yağ": int.parse(detectedFoodMap["yağ"].toString()),
            "karbonhidrat":
                int.parse(detectedFoodMap["karbonhidrat"].toString()),
          };
        });
      } catch (e) {
        print("JSON parsing hatası: $e");
        setState(() {
          foodData = null;
        });
      }
    } else {
      setState(() {
        foodData = null;
      });
    }
  }

  // Future<void> _fetchFoodData(String label) async {
  // QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //     .collection('foods')
  //     .where('name', isEqualTo: label.trim())
  //     .get();

  // if (querySnapshot.docs.isNotEmpty) {
  //   setState(() {
  //     foodData = querySnapshot.docs.first.data() as Map<String, dynamic>?;
  //   });
  // } else {
  //   setState(() {
  //     foodData = null;
  //   });
  // }

  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aİ ile Yemek Tespiti'),
      ),
      body: detectedFood != null
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Image.file(
                            File(widget.imagePath),
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Algılanan Yiyecek: ${foodData!['name'] ?? "Bulunamadı"}',
                            style: fontStyle(24, Colors.black, FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Divider(color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        if (foodData != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Besin Değerleri:',
                                style: fontStyle(
                                    20, Colors.black, FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              _buildNutrientRow(
                                  'Kalori', '${foodData!['kalori'] ?? 0} kcal'),
                              _buildNutrientRow(
                                  'Yağ', '${foodData!['yağ'] ?? 0} Gram'),
                              _buildNutrientRow('Karbonhidrat',
                                  '${foodData!['karbonhidrat'] ?? 0} Gram'),
                              _buildNutrientRow('Protein',
                                  '${foodData!['protein'] ?? 0} Gram'),
                              const SizedBox(height: 25),
                              MyButton(
                                  text: "Yemeği Ekle",
                                  buttonColor:
                                      widget.dietData ? mainColor : Colors.grey,
                                  buttonTextColor: Colors.white,
                                  buttonTextSize: 20,
                                  buttonTextWeight: FontWeight.normal,
                                  onPressed: () async {
                                    widget.dietData
                                        ? await FirebaseOperations()
                                            .addMealsFirebase(
                                                context, foodData!)
                                        : null;
                                  }),
                            ],
                          )
                        else
                          Text(
                            "Besin bilgileri bulunamadı.",
                            style: fontStyle(20, Colors.red, FontWeight.bold),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildNutrientRow(String nutrient, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$nutrient:',
          style: fontStyle(18, Colors.black, FontWeight.normal),
        ),
        Text(
          value,
          style: fontStyle(18, Colors.black, FontWeight.bold),
        ),
      ],
    );
  }
}
