import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/screens/user/home.dart';
import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:diyetisyenapp/widget/flash_message.dart';
import 'package:diyetisyenapp/widget/my_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:page_transition/page_transition.dart';
import 'dart:async';

class UserInformationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserInformationForm(),
    );
  }
}

class UserInformationForm extends StatefulWidget {
  @override
  _UserInformationFormState createState() => _UserInformationFormState();
}

class _UserInformationFormState extends State<UserInformationForm> {
  final PageController _pageController = PageController();
  final Map<String, dynamic> _userData = {
    'profilePhoto': null,
    'age': null,
    'weight': null,
    'height': null,
    'targetWeight': null,
    'alergy_food': null,
    'unliked_food': null,
    'diet_program_choise': null,
    'gender': null,
  };

  File? _image;
  int _currentPage = 0;
  final ImagePicker _picker = ImagePicker();
  final StreamController<bool> _isButtonEnabledStreamController =
      StreamController<bool>();

  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController targetWeightController = TextEditingController();
  final TextEditingController alergyFoodController = TextEditingController();
  final TextEditingController unlikedFoodController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkButtonStatus();
  }

  @override
  void dispose() {
    _isButtonEnabledStreamController.close();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 9) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _userData['profilePhoto'] = pickedFile.path;
        _checkButtonStatus();
      });
    }
  }

  void _checkButtonStatus() {
    bool isCurrentPageValid;

    switch (_currentPage) {
      case 1:
        isCurrentPageValid = _userData['gender'] != null;
        break;
      case 2:
        isCurrentPageValid = _userData['profilePhoto'] != null;
        break;
      case 3:
        isCurrentPageValid = _userData['age'] != null;
        break;
      case 4:
        isCurrentPageValid = _userData['weight'] != null;
        break;
      case 5:
        isCurrentPageValid = _userData['height'] != null;
        break;
      case 6:
        isCurrentPageValid = _userData['targetWeight'] != null;
        break;
      case 7:
        isCurrentPageValid = _userData['alergy_food'] != null;
        break;
      case 8:
        isCurrentPageValid = _userData['unliked_food'] != null;
        break;
      case 9:
        isCurrentPageValid = _userData['diet_program_choise'] != null;
        break;
      default:
        isCurrentPageValid = true;
    }

    _isButtonEnabledStreamController.add(isCurrentPageValid);
  }

  void _saveUserData() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .update(_userData);
    Navigator.pushReplacement(
      context,
      PageTransition(type: PageTransitionType.fade, child: HomeScreen()),
    );
    showSuccessSnackBar(context,
        "Verileriniz başarılı bir şekilde kaydedildi. Aramıza hoşgeldiniz :)");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
          _checkButtonStatus();
        },
        itemCount: 10, // Total number of pages is 10
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return _buildWelcomePage();
            case 1:
              return _buildGenderPage();
            case 2:
              return _buildImageUploadPage();
            case 3:
              return _buildAgePage();
            case 4:
              return _buildWeightPage();
            case 5:
              return _buildHeightPage();
            case 6:
              return _buildTargetWeightPage();
            case 7:
              return _buildAlergyFoodsPage();
            case 8:
              return _buildDislikedFoodsPage();
            case 9:
              return _buildDietPlanPreferencePage();
            default:
              return Container();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: StreamBuilder<bool>(
          stream: _isButtonEnabledStreamController.stream,
          builder: (context, snapshot) {
            bool isButtonEnabled = snapshot.data ?? false;
            return _currentPage == 9
                ? MyButton(
                    onPressed: isButtonEnabled ? _saveUserData : () {},
                    buttonTextColor: Colors.white,
                    text: "Kaydet",
                    buttonColor: isButtonEnabled ? mainColor : Colors.grey,
                    buttonTextSize: 18,
                    buttonTextWeight: FontWeight.normal,
                  )
                : MyButton(
                    text: _currentPage != 0 ? "Sonraki" : "Hadi Başlayalım",
                    buttonColor: isButtonEnabled ? mainColor : Colors.grey,
                    buttonTextColor:
                        isButtonEnabled ? Colors.white : Colors.white,
                    buttonTextSize: 18,
                    buttonTextWeight: FontWeight.normal,
                    onPressed: isButtonEnabled ? _nextPage : () {});
          },
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/food_background.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Diyetisyen AI App uygulamamıza Hoşgeldiniz 🥳",
              style: fontStyle(
                MediaQuery.of(context).size.width / 10,
                Colors.white,
                FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderPage() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Cinsiyetinizi Seçin",
              style: fontStyle(24, mainColor, FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/woman.png", // Kadın ikonunun yolu
                    width: 40,
                    height: 40,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: RadioListTile(
                      title: Text("Kadın"),
                      value: "kadın",
                      groupValue: _userData['gender'],
                      onChanged: (value) {
                        setState(() {
                          _userData['gender'] = value;
                          _checkButtonStatus();
                        });
                      },
                      controlAffinity: ListTileControlAffinity.trailing,
                      activeColor: Colors.purple, // Seçili olduğunda kutu rengi
                      tileColor: Colors.transparent, // Kutu arka plan rengi
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/men.png", // Erkek ikonunun yolu
                    width: 40,
                    height: 40,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: RadioListTile(
                      title: Text("Erkek"),
                      value: "erkek",
                      groupValue: _userData['gender'],
                      onChanged: (value) {
                        setState(() {
                          _userData['gender'] = value;
                          _checkButtonStatus();
                        });
                      },
                      controlAffinity: ListTileControlAffinity.trailing,
                      activeColor: Colors.purple, // Seçili olduğunda kutu rengi
                      tileColor: Colors.transparent, // Kutu arka plan rengi
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Profil Resminizi Yükleyiniz",
            style: fontStyle(20, mainColor, FontWeight.bold),
          ),
          SizedBox(height: 20),
          _image == null
              ? Text(
                  "Resim seçilmedi.",
                  style: fontStyle(15, Colors.grey.shade500, FontWeight.normal),
                )
              : Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(16)),
                  child: Image.file(
                    _image!,
                    height: 200,
                    width: 200,
                  ),
                ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text(
              "Resim Yükle",
              style: fontStyle(20, Colors.grey.shade500, FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgePage() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Yaşınız kaç?",
              style: fontStyle(20, mainColor, FontWeight.bold),
            ),
            SizedBox(
              height: 16,
            ),
            MyTextField(
              controller: ageController,
              hintText: "Yaşınızı Giriniz",
              obscureText: false,
              keyboardType: TextInputType.number,
              enabled: true,
              onChanged: (value) {
                setState(() {
                  _userData['age'] = int.parse(value);
                  print("Yaş $value");
                  _checkButtonStatus();
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWeightPage() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Kaç Kilosunuz?",
              style: fontStyle(20, mainColor, FontWeight.bold),
            ),
            SizedBox(
              height: 16,
            ),
            MyTextField(
              controller: weightController,
              hintText: "Kilonuzu Giriniz",
              obscureText: false,
              keyboardType: TextInputType.number,
              enabled: true,
              onChanged: (value) {
                setState(() {
                  _userData['weight'] = int.parse(value);
                  print("Kilo $value");
                  _checkButtonStatus();
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeightPage() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Boyunuz Kaç cm?",
              style: fontStyle(20, mainColor, FontWeight.bold),
            ),
            SizedBox(
              height: 16,
            ),
            MyTextField(
              controller: heightController,
              hintText: "Boyunuzu Giriniz",
              obscureText: false,
              keyboardType: TextInputType.number,
              enabled: true,
              onChanged: (value) {
                setState(() {
                  _userData['height'] = int.parse(value);
                  print("Kilo $value");
                  _checkButtonStatus();
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTargetWeightPage() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hedef Kilonuz Kaç kg?",
              style: fontStyle(20, mainColor, FontWeight.bold),
            ),
            SizedBox(
              height: 16,
            ),
            MyTextField(
              controller: targetWeightController,
              hintText: "Hedef Kilonuzu Giriniz",
              obscureText: false,
              keyboardType: TextInputType.number,
              enabled: true,
              onChanged: (value) {
                setState(() {
                  _userData['targetWeight'] = int.parse(value);
                  print("Kilo $value");
                  _checkButtonStatus();
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAlergyFoodsPage() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Herhangi bir yiyeceğe alerjiniz varmı?",
              style: fontStyle(20, mainColor, FontWeight.bold),
            ),
            SizedBox(
              height: 16,
            ),
            MyTextField(
              controller: alergyFoodController,
              hintText: "Alerjiniz Olan Yiyecekleri  Giriniz",
              obscureText: false,
              keyboardType: TextInputType.multiline,
              enabled: true,
              onChanged: (value) {
                setState(() {
                  _userData['alergy_food'] = value;
                  print("Kilo $value");
                  _checkButtonStatus();
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDislikedFoodsPage() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hangi yemekleri sevmiyorsunuz?",
              style: fontStyle(20, mainColor, FontWeight.bold),
            ),
            SizedBox(
              height: 16,
            ),
            MyTextField(
              controller: unlikedFoodController,
              hintText: "Beğenmediğiniz yiyecekleri giriniz",
              obscureText: false,
              keyboardType: TextInputType.multiline,
              enabled: true,
              onChanged: (value) {
                setState(() {
                  _userData['unliked_food'] = value;
                  print("Kilo $value");
                  _checkButtonStatus();
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDietPlanPreferencePage() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Diyet planınızı nasıl ayarlamak istersiniz?",
              style: fontStyle(20, mainColor, FontWeight.bold),
            ),
            RadioListTile(
              title: Text("Otomatik önerilen"),
              value: "otomatik",
              groupValue: _userData['diet_program_choise'],
              onChanged: (value) {
                setState(() {
                  _userData['diet_program_choise'] = value;
                  _checkButtonStatus();
                });
              },
            ),
            RadioListTile(
              title: Text("Diyetisyenin önerisi"),
              value: "diyetisyen",
              groupValue: _userData['diet_program_choise'],
              onChanged: (value) {
                setState(() {
                  _userData['diet_program_choise'] = value;
                  _checkButtonStatus();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
