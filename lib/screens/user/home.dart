import 'package:diyetisyenapp/screens/user/add_meals_screen.dart';
import 'package:diyetisyenapp/screens/user/chat/chat_screen.dart';
import 'package:diyetisyenapp/screens/user/finally_diet_screen.dart';
import 'package:diyetisyenapp/screens/user/home_page.dart';
import 'package:diyetisyenapp/screens/user/profile_screen.dart';
import 'package:diyetisyenapp/screens/user/progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

  static List<Widget> widgetOptions = <Widget>[
    const HomePage(),
    const ChatScreen(),
    const AddMeals(),
    const ProgressScreenPage(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    checkDietProgram();
  }

  Future<void> checkDietProgram() async {
    final user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;
      final userRef = _firestore.collection('users').doc(uid);
      final dietProgramRef = userRef.collection('dietProgram');
      final weeklyProgramRef = dietProgramRef.doc('weeklyProgram');

      weeklyProgramRef.get().then((weeklyProgramSnapshot) {
        if (weeklyProgramSnapshot.exists) {
          final startDate = weeklyProgramSnapshot['startDate'] as Timestamp;
          final currentDate = Timestamp.now();

          // Calculate the difference in days
          final differenceInDays =
              currentDate.toDate().difference(startDate.toDate()).inDays;

          if (differenceInDays > 28) {
            // If more than 28 days have passed, navigate to another screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const FinallyDietScreen()),
            );
          }
        }
      }).catchError((error) {
        print('Error checking diet program: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: selectedIndex,
        builder: (context, index, child) {
          return widgetOptions.elementAt(index);
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: selectedIndex,
        builder: (context, index, child) {
          return SalomonBottomBar(
            currentIndex: index,
            onTap: (i) {
              selectedIndex.value = i;
            },
            items: [
              SalomonBottomBarItem(
                icon: const Icon(Icons.home),
                title: const Text("Anasayfa"),
                selectedColor: Colors.black,
                unselectedColor: Colors.grey,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.chat),
                title: const Text("Sohbet"),
                selectedColor: Colors.black,
                unselectedColor: Colors.grey,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.add_box),
                title: const Text("Ekle"),
                selectedColor: Colors.black,
                unselectedColor: Colors.grey,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.trending_up),
                title: const Text("Gelişim"),
                selectedColor: Colors.black,
                unselectedColor: Colors.grey,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.person),
                title: const Text("Profil"),
                selectedColor: Colors.black,
                unselectedColor: Colors.grey,
              ),
            ],
          );
        },
      ),
    );
  }
}
