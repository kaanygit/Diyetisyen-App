import 'dart:math';

import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/screens/user/home.dart';
import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:diyetisyenapp/widget/flash_message.dart';
import 'package:diyetisyenapp/widget/my_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_transition/page_transition.dart';

class FinallyDietScreen extends StatefulWidget {
  @override
  _FinallyDietScreenState createState() => _FinallyDietScreenState();
}

class _FinallyDietScreenState extends State<FinallyDietScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedDietType = 'diyetisyen';
  final TextEditingController _controller = TextEditingController();

  Map<String, dynamic> profileData = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> _fetchProfile() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data();
        setState(() {
          profileData = data!;
        });
      } else {
        showErrorSnackBar(context, "Profil Bilgisi getirilirken hata oluştu");
      }
    } catch (e) {
      showErrorSnackBar(
          context, "Profil Bilgisi getirilirken hata oluştu : $e");
    }
  }

  Future<void> _submitFeedback() async {
    try {
      print(_selectedDietType);
      print(_controller.text);
      final random = Random();

      await FirebaseFirestore.instance.collection('diet_comment').add({
        'comment': _controller.text,
        'wants_new_diet': _selectedDietType,
        'user_uid': _auth.currentUser!.uid
      }).then((value) {
        print('Kullanıcı yorumu ve diyet isteği Firestore\'a eklendi!');
      }).catchError((error) {
        print('Hata oluştu: $error');
      });

      if (_selectedDietType == "diyetisyen") {
        CollectionReference dietProgramCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('dietProgram');
        QuerySnapshot dietProgramSnapshot = await dietProgramCollection.get();
        for (DocumentSnapshot dietProgramDoc in dietProgramSnapshot.docs) {
          await dietProgramDoc.reference.delete();
        }

        Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.fade, child: new HomeScreen()),
        );
      } else {
        print("secenek otomatik geldi");
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection('diet_list').get();

        List<Map<String, dynamic>> dietOptions = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        // Bu kısımda diyet listesindeki verileri ekrana yazdıracağız
        var weeks = ['week1', 'week2', 'week3', 'week4'];
        var days = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ];
        var mealTypes = ['breakfast', 'lunch', 'dinner'];

        // İstenmeyen yiyecek bulunmayan diyet seçeneklerini depolamak için bir liste oluşturalım
        List<Map<String, dynamic>> undesiredFoodsFreeOptions = [];

        for (var dietOption in dietOptions) {
          bool foundUndesiredFood = false;
          for (var week in weeks) {
            if (dietOption.containsKey(week)) {
              for (var day in days) {
                if (dietOption[week].containsKey(day)) {
                  for (var mealType in mealTypes) {
                    if (dietOption[week][day].containsKey(mealType)) {
                      var meals = dietOption[week][day][mealType]['diet'];
                      var processedMeals =
                          meals.trim().toLowerCase().split(' ');

                      var allergyFoods = profileData['alergy_food']
                          .trim()
                          .toLowerCase()
                          .split(
                              ','); // Virgülle ayrılmış değerleri listeye dönüştür
                      var unlikedFoods = profileData['unliked_food']
                          .trim()
                          .toLowerCase()
                          .split(
                              ','); // Virgülle ayrılmış değerleri listeye dönüştür

                      // processedMeals içindeki her bir öğeyi döngüye alıp alerji ve hoşlanılmayan yiyeceklerle karşılaştıralım
                      for (var meal in processedMeals) {
                        if (allergyFoods.contains(meal) ||
                            unlikedFoods.contains(meal)) {
                          foundUndesiredFood = true;
                          break;
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          if (!foundUndesiredFood) {
            undesiredFoodsFreeOptions.add(dietOption);
          }
        }

        // İstenmeyen yiyecek bulunmayan diyet seçenekleri arasından rastgele birini seçelim
        if (undesiredFoodsFreeOptions.isNotEmpty) {
          var selectedOptionIndex =
              random.nextInt(undesiredFoodsFreeOptions.length);
          var selectedOption = undesiredFoodsFreeOptions[selectedOptionIndex];

          // Seçilen diyet seçeneğine başlangıç tarihini ekleyelim
          var startDate = DateTime.now(); // Şu anki tarih ve saat
          selectedOption['startDate'] = startDate;

          // Seçilen diyet seçeneğini Firebase'e kaydedelim
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .collection('dietProgram')
              .doc('weeklyProgram')
              .set(selectedOption);
          Navigator.pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType.fade, child: new HomeScreen()),
          );
        }
      }
    } catch (e) {
      showErrorSnackBar(context, "Veriler kaydedilirken hata oluştu : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diyetiniz Tamamlandı 🥳'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Diyet hakkında yorumunuzu alabilir miyim?',
                style: fontStyle(18, mainColor, FontWeight.bold),
              ),
              SizedBox(height: 20),
              // TextField(
              //   decoration: InputDecoration(
              //     hintText: 'Yorumunuzu buraya girin',
              //     border: OutlineInputBorder(),
              //   ),
              //   onSubmitted: (value) {
              //     _submitFeedback(value, _selectedDietType == 'Evet');
              //   },
              // ),
              MyTextField(
                controller: _controller,
                hintText: "Yorumunuzu buraya giriniz",
                obscureText: false,
                keyboardType: TextInputType.multiline,
                enabled: true,
                maxLines: 5,
              ),
              SizedBox(height: 20),
              Text(
                'Yeni diyetizini nasıl istiyorsunuz?',
                style: fontStyle(18, mainColor, FontWeight.bold),
              ),
              SizedBox(height: 10),
              ListTile(
                title: Text('Diyetisyen'),
                leading: Radio(
                  value: 'diyetisyen',
                  groupValue: _selectedDietType,
                  onChanged: (value) {
                    setState(() {
                      _selectedDietType = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('Otomatik'),
                leading: Radio(
                  value: 'otomatik',
                  groupValue: _selectedDietType,
                  onChanged: (value) {
                    setState(() {
                      _selectedDietType = value!;
                    });
                  },
                ),
              ),
              SizedBox(height: 20),
              MyButton(
                  text: "Gönder",
                  buttonColor: mainColor,
                  buttonTextColor: Colors.white,
                  buttonTextSize: 20,
                  buttonTextWeight: FontWeight.normal,
                  onPressed: _submitFeedback),
            ],
          ),
        ),
      ),
    );
  }
}
