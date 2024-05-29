import 'dart:io';
import 'package:diyetisyenapp/constants/fonts.dart';
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
                            'Algılanan Yiyecek: ${detectedFood.toString().trim() != "Hayır" ? "Bulunamadı" : ""}',
                            style: fontStyle(24, Colors.black, FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 8),
                        Divider(color: Colors.grey[400]),
                        SizedBox(height: 8),
                        Text(
                          'Besin Değerleri:',
                          style: fontStyle(20, Colors.black, FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        _buildNutrientRow('Kalori', '100 kcal'),
                        _buildNutrientRow('Yağ', '0.5 g'),
                        _buildNutrientRow('Karbonhidrat', '25 g'),
                        _buildNutrientRow('Protein', '0.5 g'),
                        SizedBox(height: 25),
                        // MyButton widget'ı kullanmak yerine FloatingActionButton örneği:
                        MyButton(
                            text: "Yemeği Ekle",
                            buttonColor: mainColor,
                            buttonTextColor: Colors.white,
                            buttonTextSize: 20,
                            buttonTextWeight: FontWeight.normal,
                            onPressed: () {})
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
