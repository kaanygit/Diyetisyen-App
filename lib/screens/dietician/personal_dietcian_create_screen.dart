import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:diyetisyenapp/widget/flash_message.dart';

class PersonalDietcianCreateScreen extends StatefulWidget {
  final String userUid;
  const PersonalDietcianCreateScreen({required this.userUid, super.key});

  @override
  State<PersonalDietcianCreateScreen> createState() =>
      _PersonalDietcianCreateScreenState();
}

class _PersonalDietcianCreateScreenState
    extends State<PersonalDietcianCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final int weeks = 4;
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  final List<Map<String, dynamic>> dietData = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < weeks * days.length; i++) {
      dietData.add({
        'breakfast': {
          'calories': TextEditingController(),
          'carbs': TextEditingController(),
          'diet': TextEditingController(),
          'fat': TextEditingController(),
          'protein': TextEditingController(),
          'water': TextEditingController(),
          'dailyMeat': [],
          'drinkWater': false,
          'eat': false,
        },
        'lunch': {
          'calories': TextEditingController(),
          'carbs': TextEditingController(),
          'diet': TextEditingController(),
          'fat': TextEditingController(),
          'protein': TextEditingController(),
          'water': TextEditingController(),
          'dailyMeat': [],
          'drinkWater': false,
          'eat': false,
        },
        'dinner': {
          'calories': TextEditingController(),
          'carbs': TextEditingController(),
          'diet': TextEditingController(),
          'fat': TextEditingController(),
          'protein': TextEditingController(),
          'water': TextEditingController(),
          'dailyMeat': [],
          'drinkWater': false,
          'eat': false,
        }
      });
    }
  }

  @override
  void dispose() {
    for (var data in dietData) {
      data['breakfast'].values.forEach((controller) {
        if (controller is TextEditingController) controller.dispose();
      });
      data['lunch'].values.forEach((controller) {
        if (controller is TextEditingController) controller.dispose();
      });
      data['dinner'].values.forEach((controller) {
        if (controller is TextEditingController) controller.dispose();
      });
    }
    super.dispose();
  }

  bool _validateFields() {
    for (var data in dietData) {
      for (var meal in ['breakfast', 'lunch', 'dinner']) {
        for (var key in data[meal].keys) {
          if (data[meal][key] is TextEditingController) {
            if ((data[meal][key] as TextEditingController).text.isEmpty) {
              return false;
            }
          }
        }
      }
    }
    return true;
  }

  Future<void> _saveData() async {
    if (!_validateFields()) {
      showErrorSnackBar(context, "Lütfen tüm alanları doldurun");
      return;
    }

    Map<String, dynamic> fullProgram = {
      'startDate': DateTime.now(),
    };

    for (int week = 0; week < weeks; week++) {
      Map<String, dynamic> weeklyData = {};
      for (int day = 0; day < days.length; day++) {
        int index = week * days.length + day;
        weeklyData[days[day]] = {
          'breakfast': {
            'calories': dietData[index]['breakfast']['calories'].text,
            'carbs': dietData[index]['breakfast']['carbs'].text,
            'diet': dietData[index]['breakfast']['diet'].text,
            'fat': dietData[index]['breakfast']['fat'].text,
            'protein': dietData[index]['breakfast']['protein'].text,
            'water': dietData[index]['breakfast']['water'].text,
            'dailyMeat': dietData[index]['breakfast']['dailyMeat'],
            'drinkWater': dietData[index]['breakfast']['drinkWater'],
            'eat': dietData[index]['breakfast']['eat'],
          },
          'lunch': {
            'calories': dietData[index]['lunch']['calories'].text,
            'carbs': dietData[index]['lunch']['carbs'].text,
            'diet': dietData[index]['lunch']['diet'].text,
            'fat': dietData[index]['lunch']['fat'].text,
            'protein': dietData[index]['lunch']['protein'].text,
            'water': dietData[index]['lunch']['water'].text,
            'dailyMeat': dietData[index]['lunch']['dailyMeat'],
            'drinkWater': dietData[index]['lunch']['drinkWater'],
            'eat': dietData[index]['lunch']['eat'],
          },
          'dinner': {
            'calories': dietData[index]['dinner']['calories'].text,
            'carbs': dietData[index]['dinner']['carbs'].text,
            'diet': dietData[index]['dinner']['diet'].text,
            'fat': dietData[index]['dinner']['fat'].text,
            'protein': dietData[index]['dinner']['protein'].text,
            'water': dietData[index]['dinner']['water'].text,
            'dailyMeat': dietData[index]['dinner']['dailyMeat'],
            'drinkWater': dietData[index]['dinner']['drinkWater'],
            'eat': dietData[index]['dinner']['eat'],
          }
        };
      }
      fullProgram['week${week + 1}'] = weeklyData;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userUid)
        .collection('dietProgram')
        .doc('weeklyProgram')
        .set(fullProgram, SetOptions(merge: true));

    showSuccessSnackBar(context, "Veri başarıyla kaydedildi");
    Navigator.pop(context);
  }

  Widget _buildMealInput(Map<String, dynamic> mealData) {
    return Column(
      children: [
        TextFormField(
          controller: mealData['calories'],
          decoration: const InputDecoration(labelText: 'Kalori'),
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty ? 'Cannot be empty' : null,
        ),
        TextFormField(
          controller: mealData['carbs'],
          decoration: const InputDecoration(labelText: 'Karbonhidrat'),
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty ? 'Cannot be empty' : null,
        ),
        TextFormField(
          controller: mealData['diet'],
          decoration: const InputDecoration(labelText: 'Diyette Yenecekler'),
          validator: (value) => value!.isEmpty ? 'Cannot be empty' : null,
        ),
        TextFormField(
          controller: mealData['fat'],
          decoration: const InputDecoration(labelText: 'Yağ'),
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty ? 'Cannot be empty' : null,
        ),
        TextFormField(
          controller: mealData['protein'],
          decoration: const InputDecoration(labelText: 'Protein'),
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty ? 'Cannot be empty' : null,
        ),
        TextFormField(
          controller: mealData['water'],
          decoration: const InputDecoration(labelText: 'Kaç Bardak Su'),
          keyboardType: TextInputType.number,
          validator: (value) => value!.isEmpty ? 'Cannot be empty' : null,
        ),
      ],
    );
  }

  Widget _buildDayInput(int week, String day) {
    int index = week * days.length + days.indexOf(day);
    return ExpansionTile(
      title: Text(day),
      children: [
        Text('Kahvaltı', style: fontStyle(15, mainColor, FontWeight.normal)),
        _buildMealInput(dietData[index]['breakfast']),
        const SizedBox(height: 8),
        Text('Öğlen Yemeği',
            style: fontStyle(15, mainColor, FontWeight.normal)),
        _buildMealInput(dietData[index]['lunch']),
        const SizedBox(height: 8),
        Text('Akşam Yemeği',
            style: fontStyle(15, mainColor, FontWeight.normal)),
        _buildMealInput(dietData[index]['dinner']),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kişisel Diyetisyen Oluştur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView.builder(
            itemCount: weeks,
            itemBuilder: (context, week) {
              return ExpansionTile(
                title: Text('Hafta ${week + 1}'),
                children: days.map((day) => _buildDayInput(week, day)).toList(),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MyButton(
          onPressed: _saveData,
          text: "Kaydet",
          buttonColor: mainColor,
          buttonTextColor: Colors.white,
          buttonTextSize: 16,
          buttonTextWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
