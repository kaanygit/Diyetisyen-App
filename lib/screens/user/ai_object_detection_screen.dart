import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/database/firebase.dart';
import 'package:diyetisyenapp/database/gemini.dart';
import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:flutter/material.dart';

class AiObjectDetectionScreen extends StatefulWidget {
  final String imagePath;

  const AiObjectDetectionScreen({required this.imagePath});

  @override
  _AiObjectDetectionScreenState createState() =>
      _AiObjectDetectionScreenState();
}

class _AiObjectDetectionScreenState extends State<AiObjectDetectionScreen> {
  String? detectedFood;
  Map<String, dynamic>? foodData;

  @override
  void initState() {
    super.initState();
    _fetchImageLabel();
  }

  Future<void> _fetchImageLabel() async {
    final label = await Gemini().geminImageLabelingPrompt(widget.imagePath);
    setState(() {
      detectedFood = label ?? "Bir hata oluştu veya yiyecek algılanamadı.";
    });
    if (label != null) {
      await _fetchFoodData(label);
    }
  }

  Future<void> _fetchFoodData(String label) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('foods')
        .where('name', isEqualTo: label.trim().toLowerCase())
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        foodData = querySnapshot.docs.first.data() as Map<String, dynamic>?;
      });
    } else {
      setState(() {
        foodData = null;
      });
    }
  }

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
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Algılanan Yiyecek: ${detectedFood ?? "Bulunamadı"}',
                            style: fontStyle(24, Colors.black, FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 8),
                        Divider(color: Colors.grey[400]),
                        SizedBox(height: 8),
                        if (foodData != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Besin Değerleri:',
                                style: fontStyle(
                                    20, Colors.black, FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              _buildNutrientRow(
                                  'Kalori', '${foodData!['kalori'] ?? 0} kcal'),
                              _buildNutrientRow(
                                  'Yağ', '${foodData!['yağ'] ?? 0} Gram'),
                              _buildNutrientRow('Karbonhidrat',
                                  '${foodData!['karbonhidrat'] ?? 0} Gram'),
                              _buildNutrientRow('Protein',
                                  '${foodData!['protein'] ?? 0} Gram'),
                              SizedBox(height: 25),
                              MyButton(
                                  text: "Yemeği Ekle",
                                  buttonColor: mainColor,
                                  buttonTextColor: Colors.white,
                                  buttonTextSize: 20,
                                  buttonTextWeight: FontWeight.normal,
                                  onPressed: () async {
                                    await FirebaseOperations()
                                        .addMealsFirebase(context, foodData!);
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
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildNutrientRow(String nutrient, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          nutrient + ':',
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
