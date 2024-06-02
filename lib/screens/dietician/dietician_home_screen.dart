import 'dart:io';

import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/database/firebase.dart';
import 'package:diyetisyenapp/screens/auth/auth_screen.dart';
import 'package:diyetisyenapp/screens/user/user_edit_profile_screen.dart';
import 'package:diyetisyenapp/widget/flash_message.dart';
import 'package:diyetisyenapp/widget/my_text_field.dart';
import 'package:diyetisyenapp/widget/privacy.dart';
import 'package:diyetisyenapp/widget/term_condition.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diyetisyenapp/screens/dietician/message_screen.dart';
import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;

class DieticianHomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DieticianHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String uid = _auth.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text("Diyetisyen App - Diyetisyen",
            style: fontStyle(20, mainColor, FontWeight.bold)),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>?;

          if (userData != null && userData['dietcian_confirm'] == true) {
            return DieticianMainContent(currentUserUid: uid);
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Admin tarafından onay bekleniyor.Beklediğiniz için teşekkür ederiz.:)",
                    style: fontStyle(25, mainColor, FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  MyButton(
                      text: "Sign Out",
                      buttonColor: mainColor,
                      buttonTextColor: Colors.white,
                      buttonTextSize: 25,
                      buttonTextWeight: FontWeight.normal,
                      onPressed: () async {
                        await Future.delayed(Duration(seconds: 2));
                        FirebaseOperations().signOut(context);
                      })
                ],
              )),
            );
          }
        },
      ),
    );
  }
}

class DieticianMainContent extends StatefulWidget {
  final String currentUserUid;

  DieticianMainContent({required this.currentUserUid});

  @override
  _DieticianMainContentState createState() => _DieticianMainContentState();
}

class _DieticianMainContentState extends State<DieticianMainContent> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ClientChats(currentUserUid: widget.currentUserUid),
      RequestedUsers(currentUserUid: widget.currentUserUid),
      ProfileScreen(currentUserUid: widget.currentUserUid),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          SalomonBottomBarItem(
              icon: Icon(Icons.chat),
              title: Text("Sohbet Kutuları"),
              selectedColor: mainColor,
              unselectedColor: Colors.grey),
          SalomonBottomBarItem(
              icon: Icon(Icons.person_add),
              title: Text("İstekler"),
              selectedColor: mainColor,
              unselectedColor: Colors.grey),
          SalomonBottomBarItem(
              icon: Icon(Icons.account_circle),
              title: Text("Profil"),
              selectedColor: mainColor,
              unselectedColor: Colors.grey),
        ],
      ),
    );
  }
}

class ClientChats extends StatelessWidget {
  final String currentUserUid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ClientChats({required this.currentUserUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(currentUserUid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        var dieticianData = snapshot.data!.data() as Map<String, dynamic>?;

        if (dieticianData == null ||
            !dieticianData.containsKey('dietician-danisanlar-uid')) {
          return Center(child: Text('No clients available'));
        }

        List<String> clientUids =
            List<String>.from(dieticianData['dietician-danisanlar-uid']);

        if (clientUids.isEmpty) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage("assets/images/dietbot.png"),
                radius: 50,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Danışanınız Bulunmamaktadır:(',
                style: fontStyle(20, mainColor, FontWeight.bold),
              ),
            ],
          ));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: clientUids.length,
          itemBuilder: (context, index) {
            String clientId = clientUids[index];

            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(clientId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: 72.0,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (userSnapshot.hasError) {
                  return ListTile(title: Text('Error fetching data'));
                }

                var userData =
                    userSnapshot.data!.data() as Map<String, dynamic>?;

                if (userData == null) {
                  return ListTile(
                    title: Center(
                      child: Text('İsteğiniz yok'),
                    ),
                  );
                }

                String clientName = userData['displayName'] ?? 'Unknown User';
                String userPhoto = userData['profilePhoto'] ?? "null";

                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MessagingScreen(receiverId: clientId),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: mainColor2,
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: userPhoto == "null"
                                      ? AssetImage("assets/images/avatar.jpg")
                                      : NetworkImage(userPhoto)
                                          as ImageProvider,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("$clientName",
                                        style: fontStyle(
                                            15, Colors.black, FontWeight.bold)),
                                    Text(
                                      "$clientId",
                                      style: fontStyle(
                                          15, Colors.grey, FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class RequestedUsers extends StatelessWidget {
  final String currentUserUid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RequestedUsers({required this.currentUserUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(currentUserUid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        var dieticianData = snapshot.data!.data() as Map<String, dynamic>?;

        if (dieticianData == null ||
            !dieticianData.containsKey('danisanlar-istek')) {
          return Center(child: Text('İsteğiniz yok'));
        }

        List<String> requestUids =
            List<String>.from(dieticianData['danisanlar-istek']);

        if (requestUids.isEmpty) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage("assets/images/dietbot.png"),
                radius: 50,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Yeni istek bulunmamaktadır:(',
                style: fontStyle(20, mainColor, FontWeight.bold),
              ),
            ],
          ));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: requestUids.length,
          itemBuilder: (context, index) {
            String requestId = requestUids[index];

            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(requestId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: 72.0,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (userSnapshot.hasError) {
                  return ListTile(title: Text('Error fetching data'));
                }

                var userData =
                    userSnapshot.data!.data() as Map<String, dynamic>?;

                if (userData == null) {
                  return ListTile(
                    title: Center(
                      child: Text('İsteğiniz yok'),
                    ),
                  );
                }

                String userName = userData['displayName'] ?? 'Unknown User';
                String userPhoto = userData['profilePhoto'] ?? "null";

                // Check if the user is already a client of the dietitian
                if (dieticianData.containsKey('dietician-danisanlar-uid')) {
                  List<String> clientUids = List<String>.from(
                      dieticianData['dietician-danisanlar-uid']);
                  if (clientUids.contains(requestId)) {
                    // If the user is already a client, don't show in requests
                    return SizedBox.shrink();
                  }
                }

                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MessagingScreen(receiverId: requestId),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: mainColor2,
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: userPhoto == "" ||
                                          userPhoto == "null"
                                      ? AssetImage("assets/images/avatar.jpg")
                                      : NetworkImage(userPhoto)
                                          as ImageProvider,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("$userName",
                                        style: fontStyle(
                                            15, Colors.black, FontWeight.bold)),
                                    Text(
                                      "$requestId",
                                      style: fontStyle(
                                          15, Colors.grey, FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final String currentUserUid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProfileScreen({required this.currentUserUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(currentUserUid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>?;

          if (userData == null) {
            return Center(child: Text('Kullanıcı bilgileri bulunamadı.'));
          }

          String userName = userData['displayName'] ?? 'Kullanıcı Adı Yok';
          String userEmail = userData['email'] ?? 'E-posta Yok';
          int userAge = userData['age'] ?? 0;
          String userPhoto = userData['profilePhoto'] ?? "ProfilFoto";

          return _buildProfileContent(
              userName, userEmail, userAge, userPhoto, context, currentUserUid);
        },
      ),
    );
  }

  Widget _buildProfileContent(
    String userName,
    String userEmail,
    int userAge,
    String userPhoto,
    BuildContext context,
    String userUid,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: userPhoto == "" || userPhoto == "ProfilFoto"
                  ? AssetImage("assets/images/avatar.jpg")
                  : NetworkImage(userPhoto) as ImageProvider,
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: mainColor2,
                borderRadius: BorderRadius.circular(15),
              ),
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileInfoRow(context, "Email", userEmail),
                  _buildProfileInfoRow(context, "Adınız", userName),
                  _buildProfileInfoRow(context, "Yaş", userAge),
                ],
              ),
            ),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: mainColor2,
                borderRadius: BorderRadius.circular(15),
              ),
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileButton(context, "Arkadaşlarınla Paylaş"),
                  _buildProfileButton(context, "Gizlilik Politikası"),
                  _buildProfileButton(context, "Kullanım Koşulları"),
                ],
              ),
            ),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  SizedBox(height: 5),
                  MyButton(
                      text: "Profili Düzenle",
                      buttonColor: Colors.amber,
                      buttonTextColor: Colors.white,
                      buttonTextSize: 15,
                      buttonTextWeight: FontWeight.bold,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileEditScreen(
                                currentUserUid: currentUserUid),
                          ),
                        );
                      }),
                  SizedBox(height: 5),
                  MyButton(
                    onPressed: () async {
                      await Future.delayed(Duration(seconds: 2));
                      FirebaseOperations().signOut(context);
                    },
                    text: "Çıkış Yap",
                    buttonColor: mainColor,
                    buttonTextColor: Colors.white,
                    buttonTextSize: 15,
                    buttonTextWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(
    BuildContext context,
    String title,
    dynamic value,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title + ":",
              style: fontStyle(15, Colors.black, FontWeight.bold)),
          Text(
            value.toString(),
            style: fontStyle(15, Colors.black, FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context, String text) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 1.0)),
      ),
      child: InkWell(
        onTap: () async {
          if (text == 'Çıkış Yap') {
            await Future.delayed(Duration(seconds: 2));
            FirebaseOperations().signOut(context);
          } else if (text == 'Profil Düzenle') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProfileEditScreen(currentUserUid: currentUserUid),
              ),
            );
          } else {
            if (text == "Arkadaşlarınla Paylaş") {
              print("Arkadaşlarınla Paylaş");
              _launchURL('https://diyetisyenapp.com/');
            } else if (text == "Gizlilik Politikası") {
              print("Gizlilik Koşulları");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivacyPage(),
                ),
              );
            } else {
              print("Kullanım Koşulları");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TermsOfUsePage(),
                ),
              );
            }
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: fontStyle(15, Colors.black, FontWeight.bold),
            ),
            Icon(Icons.arrow_right),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Bağlantı açılamadı: $url';
    }
  }
}

class ProfileEditScreen extends StatefulWidget {
  final String currentUserUid;

  const ProfileEditScreen({Key? key, required this.currentUserUid})
      : super(key: key);

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _displayNameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _welcomeMessageController = TextEditingController();
  File? _image;
  String? _profilePhotoUrl;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(widget.currentUserUid).get();
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>?;

        if (userData != null) {
          setState(() {
            _displayNameController.text = userData['displayName'] ?? '';
            _ageController.text = userData['age']?.toString() ?? '';
            _titleController.text = userData['title'] ?? '';
            _profilePhotoUrl = userData['profilePhoto'] ?? '';
            _phoneNumberController.text = userData['phoneNumber'] ?? '';
            _addressController.text = userData['address'] ?? '';
            _welcomeMessageController.text = userData['welcomeMessage'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      // Handle error
    }
  }

  Future<void> updateProfile() async {
    try {
      await _firestore.collection('users').doc(widget.currentUserUid).update({
        'displayName': _displayNameController.text,
        'age': int.tryParse(_ageController.text) ?? 0,
        'title': _titleController.text,
        'profilePhoto': _profilePhotoUrl,
        'phoneNumber': _phoneNumberController.text,
        'address': _addressController.text,
        'welcomeMessage': _welcomeMessageController.text,
      });

      showSuccessSnackBar(context, "Profil başarıyla güncellendi.");

      // Optionally navigate back to the previous screen
      Navigator.of(context).pop();
    } catch (e) {
      print('Error updating profile: $e');
      showErrorSnackBar(
          context, "Profil güncelleme sırasında bir hata oluştu.");
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await uploadImageToFirebase();
    }
  }

  Future<void> uploadImageToFirebase() async {
    try {
      String fileName = path.basename(_image!.path); // Corrected method call
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('uploads/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(_image!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String url = await taskSnapshot.ref.getDownloadURL();

      setState(() {
        _profilePhotoUrl = url;
      });
    } catch (e) {
      print('Error uploading image: $e');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Düzenle'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              // width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _profilePhotoUrl == null || _profilePhotoUrl!.isEmpty
                        ? AssetImage('assets/images/avatar.jpg')
                        : NetworkImage(_profilePhotoUrl!) as ImageProvider,
              ),
            ),
            SizedBox(height: 10),
            MyButton(
              onPressed: pickImage,
              text: 'Profil Fotoğrafı Seç',
              buttonColor: mainColor3,
              buttonTextColor: mainColor,
              buttonTextSize: 15,
              buttonTextWeight: FontWeight.normal,
            ),
            SizedBox(height: 10),
            MyTextField(
              controller: _displayNameController,
              hintText: 'Adınız',
              obscureText: false,
              keyboardType: TextInputType.text,
              enabled: true,
            ),
            SizedBox(height: 10),
            MyTextField(
              controller: _ageController,
              hintText: 'Yaşınız',
              obscureText: false,
              keyboardType: TextInputType.number,
              enabled: true,
            ),
            SizedBox(height: 10),
            MyTextField(
              controller: _titleController,
              hintText: 'Ünvanınız',
              obscureText: false,
              keyboardType: TextInputType.text,
              enabled: true,
            ),
            // SizedBox(height: 10),
            // Display the current profile photo or a placeholder
            // CircleAvatar(
            //   radius: 50,
            //   backgroundImage:
            //       _profilePhotoUrl == null || _profilePhotoUrl!.isEmpty
            //           ? AssetImage('assets/images/avatar.jpg')
            //           : NetworkImage(_profilePhotoUrl!) as ImageProvider,
            // ),
            // SizedBox(height: 10),
            // ElevatedButton(
            //   onPressed: pickImage,
            //   child: Text('Profil Fotoğrafı Seç'),
            // ),
            SizedBox(height: 10),
            MyTextField(
              controller: _phoneNumberController,
              hintText: 'Telefon Numaranız',
              obscureText: false,
              keyboardType: TextInputType.phone,
              enabled: true,
            ),
            SizedBox(height: 10),
            MyTextField(
              controller: _addressController,
              hintText: 'Adresiniz',
              obscureText: false,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              enabled: true,
            ),
            SizedBox(height: 10),
            MyTextField(
              controller: _welcomeMessageController,
              hintText: 'Hoş Geldiniz Mesajı',
              obscureText: false,
              keyboardType: TextInputType.multiline,
              maxLines: 8,
              enabled: true,
            ),
            SizedBox(height: 20),
            MyButton(
                text: "Kaydet",
                buttonColor: mainColor,
                buttonTextColor: Colors.white,
                buttonTextSize: 18,
                buttonTextWeight: FontWeight.bold,
                onPressed: updateProfile),
          ],
        ),
      ),
    );
  }
}
