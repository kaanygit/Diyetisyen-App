import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/screens/dietician/dietcian_profile_screen.dart';
import 'package:diyetisyenapp/screens/dietician/dietician_home_screen.dart';
import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:diyetisyenapp/widget/flash_message.dart';
import 'package:diyetisyenapp/widget/my_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';

class DietcianInformationScreen extends StatelessWidget {
  const DietcianInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DietcianInformationForm(),
    );
  }
}

class DietcianInformationForm extends StatefulWidget {
  const DietcianInformationForm({super.key});

  @override
  State<DietcianInformationForm> createState() =>
      _DietcianInformationFormState();
}

class _DietcianInformationFormState extends State<DietcianInformationForm> {
  final PageController _pageController = PageController();
  final Map<String, dynamic> _dietcianData = {
    'gender': null,
    'profilePhoto': null,
    'age': null,
    'title': null,
    'expertise': null,
    'experience': null,
    'welcome_message': null,
    'why_dietcian': null,
    'new_dietcian': false,
    'dietcian_confirm': false
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

  // Future<void> _pickImage() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   final FirebaseAuth _auth = FirebaseAuth.instance;

  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //     });

  //     try {
  //       // Resmi Firestore'a yükle ve download URL'sini al
  //       // Reference ref = FirebaseStorage.instance
  //       //     .ref()
  //       //     .child("profile_photos")
  //       //     .child(_auth.currentUser!.uid);

  //       // UploadTask uploadTask = ref.putFile(File(pickedFile.path));
  //       // TaskSnapshot snapshot = await uploadTask;
  //       // print(snapshot);
  //       // if (snapshot.state == TaskState.success) {
  //       //   final url = await snapshot.ref.getDownloadURL();
  //       //   setState(() {
  //       //     _dietcianData['profilePhoto'] = url;
  //       //     print("Resim yüklendi: $url");
  //       //     _checkButtonStatus();
  //       //   });
  //       // } else {
  //       //   print("Resim yükleme başarısız oldu");
  //       // }

  //       String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  //       Reference storageReference =
  //           FirebaseStorage.instance.ref().child('images/$fileName');
  //       UploadTask uploadTask = storageReference.putFile(File(pickedFile.path));
  //       TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
  //       String imageUrl = await taskSnapshot.ref.getDownloadURL();

  //       print('Image uploaded successfully!');
  //       setState(() {
  //         _dietcianData['profilePhoto'] = imageUrl;
  //         print("Resim yüklendi: $imageUrl");
  //         _checkButtonStatus();
  //       });
  //     } catch (e) {
  //       print("Resim yükleme hatası: $e");
  //     }
  //   }
  // }
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    final FirebaseAuth _auth = FirebaseAuth.instance;

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        // Resmi Firestore'a yükle ve download URL'sini al
        Reference ref = FirebaseStorage.instance
            .ref()
            .child("profile_photos")
            .child(_auth.currentUser!.uid);
        UploadTask uploadTask = ref.putFile(File(pickedFile.path));
        uploadTask.then((res) {
          res.ref.getDownloadURL().then((url) {
            setState(() {
              _dietcianData['profilePhoto'] =
                  url; // Resmin download URL'sini kullan
              _checkButtonStatus();
            });
          });
        });
      });
    }
  }

  void _checkButtonStatus() {
    bool isCurrentPageValid;

    switch (_currentPage) {
      case 1:
        isCurrentPageValid = _dietcianData['gender'] != null;
        break;
      case 2:
        isCurrentPageValid = _dietcianData['profilePhoto'] != null;
        break;
      case 3:
        isCurrentPageValid = _dietcianData['age'] != null;
        break;
      case 4:
        isCurrentPageValid = _dietcianData['title'] != null;
        break;
      case 5:
        isCurrentPageValid = _dietcianData['expertise'] != null;
        break;
      case 6:
        isCurrentPageValid = _dietcianData['experience'] != null;
        break;
      case 7:
        isCurrentPageValid = _dietcianData['welcome_message'] != null;
        break;
      case 8:
        isCurrentPageValid = _dietcianData['why_dietcian'] != null;
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
        .update(_dietcianData);
    Navigator.pushReplacement(
      context,
      PageTransition(
          type: PageTransitionType.fade, child: DieticianHomeScreen()),
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
        itemCount: 9, // Total number of pages is 10
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
              return _buildTitlePage();
            case 5:
              return _buildExpertisePage();
            case 6:
              return _buildExperiencePage();
            case 7:
              return _buildWelcomeMessagePage();
            case 8:
              return _buildWhyDietcianPage();

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
            return _currentPage == 8
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
              "Diyetisyen App uygulamamıza Hoşgeldiniz 🥳",
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
                      groupValue: _dietcianData['gender'],
                      onChanged: (value) {
                        setState(() {
                          _dietcianData['gender'] = value;
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
                      groupValue: _dietcianData['gender'],
                      onChanged: (value) {
                        setState(() {
                          _dietcianData['gender'] = value;
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
                  _dietcianData['age'] = int.parse(value);
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

  Widget _buildTitlePage() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Lütfen Ünvanınızı Giriniz?",
              style: fontStyle(20, mainColor, FontWeight.bold),
            ),
            SizedBox(
              height: 16,
            ),
            MyTextField(
              controller: weightController,
              hintText: "Ünvanınız ile Birlikte Tam Adınızı Giriniz",
              obscureText: false,
              keyboardType: TextInputType.multiline,
              enabled: true,
              onChanged: (value) {
                setState(() {
                  _dietcianData['title'] = value;
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

  Widget _buildExpertisePage() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Uzmanlık Alanınız?",
              style: fontStyle(20, mainColor, FontWeight.bold),
            ),
            SizedBox(
              height: 16,
            ),
            MyTextField(
              controller: heightController,
              hintText: "Uzmanlık Alanınızı Giriniz",
              obscureText: false,
              keyboardType: TextInputType.multiline,
              enabled: true,
              onChanged: (value) {
                setState(() {
                  _dietcianData['expertise'] = value;
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

  Widget _buildExperiencePage() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Kaç yıllık deneyiminiz vardır?",
              style: fontStyle(20, mainColor, FontWeight.bold),
            ),
            SizedBox(
              height: 16,
            ),
            MyTextField(
              controller: targetWeightController,
              hintText: "Deneyiminizi Giriniz",
              obscureText: false,
              keyboardType: TextInputType.number,
              enabled: true,
              onChanged: (value) {
                setState(() {
                  _dietcianData['experience'] = int.parse(value);
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

  Widget _buildWelcomeMessagePage() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Kendinizi Tanıtınız",
              style: fontStyle(20, mainColor, FontWeight.bold),
            ),
            SizedBox(
              height: 16,
            ),
            MyTextField(
              controller: alergyFoodController,
              hintText: "Kendinizi Tanıtınız",
              obscureText: false,
              keyboardType: TextInputType.multiline,
              enabled: true,
              maxLines: 10,
              onChanged: (value) {
                setState(() {
                  _dietcianData['welcome_message'] = value;
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

  Widget _buildWhyDietcianPage() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Neden Bizimle Birlikte Çalışmak İstiyorsunuz?",
              style: fontStyle(20, mainColor, FontWeight.bold),
            ),
            SizedBox(
              height: 16,
            ),
            MyTextField(
              controller: unlikedFoodController,
              hintText: "Sebebinizi Giriniz",
              obscureText: false,
              keyboardType: TextInputType.multiline,
              enabled: true,
              maxLines: 10,
              onChanged: (value) {
                setState(() {
                  _dietcianData['why_dietcian'] = value;
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
}
