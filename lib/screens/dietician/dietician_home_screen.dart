import 'dart:io';

import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/database/firebase.dart';
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

  DieticianHomeScreen({super.key});

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
            return const Center(child: CircularProgressIndicator());
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
                  Image.asset(
                    "assets/images/icon2.png",
                    width: 200,
                    height: 200,
                  ),
                  Text(
                    "Admin tarafından onay bekleniyor.Beklediğiniz için teşekkür ederiz :)",
                    style: fontStyle(20, mainColor, FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MyButton(
                      text: "Çıkış Yap",
                      buttonColor: Colors.redAccent,
                      buttonTextColor: Colors.white,
                      buttonTextSize: 22,
                      buttonTextWeight: FontWeight.normal,
                      onPressed: () async {
                        await Future.delayed(const Duration(seconds: 2));
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

  const DieticianMainContent({super.key, required this.currentUserUid});

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
              icon: const Icon(Icons.chat),
              title: const Text("Sohbet Kutuları"),
              selectedColor: mainColor,
              unselectedColor: Colors.grey),
          SalomonBottomBarItem(
              icon: const Icon(Icons.person_add),
              title: const Text("İstekler"),
              selectedColor: mainColor,
              unselectedColor: Colors.grey),
          SalomonBottomBarItem(
              icon: const Icon(Icons.account_circle),
              title: const Text("Profil"),
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

  ClientChats({super.key, required this.currentUserUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(currentUserUid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        var dieticianData = snapshot.data!.data() as Map<String, dynamic>?;

        if (dieticianData == null ||
            !dieticianData.containsKey('dietician-danisanlar-uid')) {
          return const Center(child: Text('No clients available'));
        }

        List<String> clientUids =
            List<String>.from(dieticianData['dietician-danisanlar-uid']);

        if (clientUids.isEmpty) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage("assets/images/dietbot.png"),
                radius: 50,
              ),
              const SizedBox(
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
          padding: const EdgeInsets.all(16.0),
          itemCount: clientUids.length,
          itemBuilder: (context, index) {
            String clientId = clientUids[index];

            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(clientId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 72.0,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (userSnapshot.hasError) {
                  return const ListTile(title: Text('Error fetching data'));
                }

                var userData =
                    userSnapshot.data!.data() as Map<String, dynamic>?;

                if (userData == null) {
                  return const ListTile(
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
                                  backgroundImage: userPhoto == "null" &&
                                          userPhoto.isEmpty
                                      ? const AssetImage("assets/images/avatar.jpg")
                                      : NetworkImage(userPhoto)
                                          as ImageProvider,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(clientName,
                                        style: fontStyle(
                                            15, Colors.black, FontWeight.bold)),
                                    Text(
                                      clientId,
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

  RequestedUsers({super.key, required this.currentUserUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(currentUserUid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        var dieticianData = snapshot.data!.data() as Map<String, dynamic>?;

        if (dieticianData == null ||
            !dieticianData.containsKey('danisanlar-istek')) {
          return const Center(child: Text('İsteğiniz yok'));
        }

        List<String> requestUids =
            List<String>.from(dieticianData['danisanlar-istek']);

        if (requestUids.isEmpty) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage("assets/images/dietbot.png"),
                radius: 50,
              ),
              const SizedBox(
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
          padding: const EdgeInsets.all(16.0),
          itemCount: requestUids.length,
          itemBuilder: (context, index) {
            String requestId = requestUids[index];

            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(requestId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 72.0,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (userSnapshot.hasError) {
                  return const ListTile(title: Text('Error fetching data'));
                }

                var userData =
                    userSnapshot.data!.data() as Map<String, dynamic>?;

                if (userData == null) {
                  return const ListTile(
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
                    return const SizedBox.shrink();
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
                                      ? const AssetImage("assets/images/avatar.jpg")
                                      : NetworkImage(userPhoto)
                                          as ImageProvider,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(userName,
                                        style: fontStyle(
                                            15, Colors.black, FontWeight.bold)),
                                    Text(
                                      requestId,
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

  ProfileScreen({super.key, required this.currentUserUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(currentUserUid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>?;

          if (userData == null) {
            return const Center(child: Text('Kullanıcı bilgileri bulunamadı.'));
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
                  ? const AssetImage("assets/images/avatar.jpg")
                  : NetworkImage(userPhoto) as ImageProvider,
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(8),
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
            const SizedBox(height: 15),
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
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  const SizedBox(height: 5),
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
                  const SizedBox(height: 5),
                  MyButton(
                    onPressed: () async {
                      await Future.delayed(const Duration(seconds: 2));
                      FirebaseOperations().signOut(context);
                    },
                    text: "Çıkış Yap",
                    buttonColor: mainColor,
                    buttonTextColor: Colors.white,
                    buttonTextSize: 15,
                    buttonTextWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 5),
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title:",
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
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 1.0)),
      ),
      child: InkWell(
        onTap: () async {
          if (text == 'Çıkış Yap') {
            await Future.delayed(const Duration(seconds: 2));
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
                  builder: (context) => const PrivacyPage(),
                ),
              );
            } else {
              print("Kullanım Koşulları");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsOfUsePage(),
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
            const Icon(Icons.arrow_right),
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

  const ProfileEditScreen({super.key, required this.currentUserUid});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _welcomeMessageController = TextEditingController();
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
        title: const Text('Profil Düzenle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
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
                        ? const AssetImage('assets/images/avatar.jpg')
                        : NetworkImage(_profilePhotoUrl!) as ImageProvider,
              ),
            ),
            const SizedBox(height: 10),
            MyButton(
              onPressed: pickImage,
              text: 'Profil Fotoğrafı Seç',
              buttonColor: mainColor3,
              buttonTextColor: mainColor,
              buttonTextSize: 15,
              buttonTextWeight: FontWeight.normal,
            ),
            const SizedBox(height: 10),
            MyTextField(
              controller: _displayNameController,
              hintText: 'Adınız',
              obscureText: false,
              keyboardType: TextInputType.text,
              enabled: true,
            ),
            const SizedBox(height: 10),
            MyTextField(
              controller: _ageController,
              hintText: 'Yaşınız',
              obscureText: false,
              keyboardType: TextInputType.number,
              enabled: true,
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            MyTextField(
              controller: _phoneNumberController,
              hintText: 'Telefon Numaranız',
              obscureText: false,
              keyboardType: TextInputType.phone,
              enabled: true,
            ),
            const SizedBox(height: 10),
            MyTextField(
              controller: _addressController,
              hintText: 'Adresiniz',
              obscureText: false,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              enabled: true,
            ),
            const SizedBox(height: 10),
            MyTextField(
              controller: _welcomeMessageController,
              hintText: 'Hoş Geldiniz Mesajı',
              obscureText: false,
              keyboardType: TextInputType.multiline,
              maxLines: 8,
              enabled: true,
            ),
            const SizedBox(height: 20),
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
