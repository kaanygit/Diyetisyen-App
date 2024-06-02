import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/screens/admin/dietcian_detail_confirm_screen.dart';
import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:diyetisyenapp/widget/flash_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:diyetisyenapp/database/firebase.dart';
// Varsayılan renkleri ekledim

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AdminMainScreen(),
    );
  }
}

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({Key? key}) : super(key: key);

  @override
  _AdminMainScreenState createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    ProfileScreen(),
    DieticiansScreen(),
    DieticianRequestsScreen(),
    DietListsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Paneli"),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.person),
            title: Text("Profil"),
            selectedColor: mainColor, // mainColor burada tanımlı olmalı
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.people),
            title: Text("Diyetisyenler"),
            selectedColor: mainColor,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.request_page),
            title: Text("Diyetisyen İstekleri"),
            selectedColor: mainColor,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.list),
            title: Text("Diyet Listeleri"),
            selectedColor: mainColor,
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class DieticiansScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Diyetisyenler"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where('userType', isEqualTo: 'diyetisyen')
            .where('dietcian_confirm', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          var dieticians = snapshot.data!.docs;

          if (dieticians.isEmpty) {
            return Center(child: Text('Kayıtlı diyetisyen bulunamadı.'));
          }

          return ListView.builder(
            itemCount: dieticians.length,
            itemBuilder: (context, index) {
              var dietician = dieticians[index].data() as Map<String, dynamic>;
              return _buildDieticianCard(dietician, context);
            },
          );
        },
      ),
    );
  }

  Widget _buildDieticianCard(
      Map<String, dynamic> dietician, BuildContext context) {
    String dieticianName = dietician['displayName'] ?? 'Bilinmeyen';
    String dieticianEmail = dietician['email'] ?? 'E-posta yok';
    String dieticianPhoto = dietician['profilePhoto'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: DieticianDetailScreen(request: dietician),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: dieticianPhoto.isEmpty
                  ? AssetImage('assets/images/default_avatar.jpg')
                  : NetworkImage(dieticianPhoto) as ImageProvider,
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dieticianName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    dieticianEmail,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DieticianRequestsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Diyetisyen İstekleri"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where('dietcian_confirm', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          var requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return Center(child: Text('Diyetisyenlik isteği bulunmamaktadır.'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index].data() as Map<String, dynamic>;
              return _buildRequestCard(request, context);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, BuildContext context) {
    String userName = request['displayName'] ?? 'Bilinmeyen';
    String userEmail = request['email'] ?? 'E-posta yok';
    String userPhoto = request['profilePhoto'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DieticianDetailScreen(request: request),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: userPhoto.isEmpty
                  ? AssetImage('assets/images/avatar.jpg')
                  : NetworkImage(userPhoto) as ImageProvider,
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    userEmail,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DietListsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Diyet Listeleri"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('diet_list').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          var dietLists = snapshot.data!.docs;

          if (dietLists.isEmpty) {
            return Center(child: Text('Diyet listesi bulunmamaktadır.'));
          }

          return ListView.builder(
            itemCount: dietLists.length,
            itemBuilder: (context, index) {
              var dietList = dietLists[index].data() as Map<String, dynamic>;
              return _buildDietListCard(dietList, context, dietLists[index].id);
            },
          );
        },
      ),
    );
  }

  Widget _buildDietListCard(
      Map<String, dynamic> dietList, BuildContext context, String docId) {
    String dietName = dietList['diet_name'] ?? 'Bilinmeyen';
    String description = dietList['description'] ?? 'Açıklama yok';

    return GestureDetector(
      onTap: () {
        _showDietListDetails(context, dietList, docId);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dietName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showEditDietListDialog(context, dietList, docId);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, docId);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDietListDetails(
      BuildContext context, Map<String, dynamic> dietList, String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Diyet Listesi"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: _buildWeekDetailWidgets(context, dietList, docId),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Kapat"),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildWeekDetailWidgets(
      BuildContext context, Map<String, dynamic> dietList, String docId) {
    List<String> excludeFields = ['dailyMeat', 'eat', 'drinkWater'];
    List<Widget> widgets = [];

    dietList.forEach((weekKey, weekValue) {
      if (weekValue is Map<String, dynamic>) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Text(
            "$weekKey",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ));

        weekValue.forEach((dayKey, dayValue) {
          if (dayValue is Map<String, dynamic>) {
            widgets.add(Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$dayKey",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      _showEditDayDialog(
                          context, docId, weekKey, dayKey, dayValue);
                    },
                  ),
                ],
              ),
            ));

            dayValue.forEach((mealKey, mealValue) {
              if (mealValue is Map<String, dynamic>) {
                widgets.add(Padding(
                  padding:
                      const EdgeInsets.only(left: 32.0, top: 2.0, bottom: 2.0),
                  child: Text(
                    "$mealKey",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ));

                mealValue.forEach((key, value) {
                  if (!excludeFields.contains(key)) {
                    widgets.add(Padding(
                      padding: const EdgeInsets.only(left: 48.0),
                      child: Text("$key: $value"),
                    ));
                  }
                });
              }
            });
          }
        });
      }
    });

    return widgets;
  }

  void _showDeleteConfirmationDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Diyet Listesini Sil"),
          content: Text(
              "Bu diyet listesini silmek istediğinizden emin misiniz? Bu işlem geri alınamaz."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("İptal"),
            ),
            TextButton(
              onPressed: () {
                _firestore.collection('diet_list').doc(docId).delete();
                Navigator.pop(context); // Close the confirmation dialog
                Navigator.pop(context); // Close the diet list details dialog
              },
              child: Text("Sil"),
            ),
          ],
        );
      },
    );
  }

  void _showEditDietListDialog(
      BuildContext context, Map<String, dynamic> dietList, String docId) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController =
            TextEditingController(text: dietList['diet_name']);
        TextEditingController descriptionController =
            TextEditingController(text: dietList['description']);

        return AlertDialog(
          title: Text("Diyet Listesini Düzenle"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Diyet Adı'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Açıklama'),
                ),
                // Add more TextFields for other diet list details if needed
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("İptal"),
            ),
            TextButton(
              onPressed: () {
                _firestore.collection('diet_list').doc(docId).update({
                  'diet_name': nameController.text,
                  'description': descriptionController.text,
                  // Add more fields to update if needed
                }).then((_) {
                  Navigator.pop(context);
                  showSuccessSnackBar(context, "Veri Başarıyla Güncellendi");
                });
              },
              child: Text("Kaydet"),
            ),
          ],
        );
      },
    );
  }

  void _showEditDayDialog(BuildContext context, String docId, String weekKey,
      String dayKey, Map<String, dynamic> dayValue) {
    showDialog(
      context: context,
      builder: (context) {
        Map<String, TextEditingController> controllers = {};

        dayValue.forEach((mealKey, mealValue) {
          if (mealValue is Map<String, dynamic>) {
            mealValue.forEach((key, value) {
              if (value is String) {
                controllers['$mealKey.$key'] =
                    TextEditingController(text: value);
              } else if (value is num) {
                controllers['$mealKey.$key'] =
                    TextEditingController(text: value.toString());
              }
            });
          }
        });

        return AlertDialog(
          title: Text("$weekKey - $dayKey"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: controllers.keys.map((key) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: controllers[key],
                    decoration: InputDecoration(labelText: key),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("İptal"),
            ),
            TextButton(
              onPressed: () {
                Map<String, dynamic> updatedDayValue = {};

                controllers.forEach((key, controller) {
                  List<String> keys = key.split('.');
                  if (updatedDayValue[keys[0]] == null) {
                    updatedDayValue[keys[0]] = {};
                  }
                  updatedDayValue[keys[0]][keys[1]] =
                      num.tryParse(controller.text) ?? controller.text;
                });

                _firestore
                    .collection('diet_list')
                    .doc(docId)
                    .update({'$weekKey.$dayKey': updatedDayValue}).then((_) {
                  Navigator.pop(context);
                  showSuccessSnackBar(context, "Veri Başarıyla Güncellendi");
                });
              },
              child: Text("Kaydet"),
            ),
          ],
        );
      },
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    String? currentUserUid = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profil"),
      ),
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
          String userPhoto = userData['profilePhoto'] ?? '';

          return _buildProfileContent(userName, userEmail, userPhoto, context);
        },
      ),
    );
  }

  Widget _buildProfileContent(
    String userName,
    String userEmail,
    String userPhoto,
    BuildContext context,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: userPhoto.isEmpty
                ? AssetImage("assets/images/avatar.jpg")
                : NetworkImage(userPhoto) as ImageProvider,
          ),
          SizedBox(height: 20),
          Text(
            userName,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            userEmail,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 20),
          // MyButton(
          //   onPressed: () {
          //     // Profil düzenleme ekranına gitmek için navigasyon kodu eklenebilir
          //     // Örneğin: Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEditScreen()));
          //     print("Profil düzenleme ekranına git");
          //   },
          //   text: "Profili Düzenle",
          //   buttonColor: Colors.blue,
          //   buttonTextColor: Colors.white,
          //   buttonTextSize: 16,
          //   buttonTextWeight: FontWeight.bold,
          // ),
          // SizedBox(height: 10),
          MyButton(
            onPressed: () async {
              try {
                await Future.delayed(Duration(seconds: 2));
                FirebaseOperations().signOut(context);
              } catch (e) {
                print("Çıkış yaparken hata oluştu: $e");
              }
            },
            text: "Çıkış Yap",
            buttonColor: Colors.red,
            buttonTextColor: Colors.white,
            buttonTextSize: 16,
            buttonTextWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
