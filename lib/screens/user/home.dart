import 'package:diyetisyenapp/screens/user/add_meals_screen.dart';
import 'package:diyetisyenapp/screens/user/chat_screen.dart';
import 'package:diyetisyenapp/screens/user/home_page.dart';
import 'package:diyetisyenapp/screens/user/profile_screen.dart';
import 'package:diyetisyenapp/screens/user/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  static const List<Widget> widgetOptions = <Widget>[
    HomePage(),
    ChatScreen(),
    AddMeals(),
    ScanScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: selectedIndex,
        onTap: (i) => setState(() {
          selectedIndex = i;
        }),
        items: [
          SalomonBottomBarItem(
              icon: const Icon(Icons.home),
              title: const Text("Home"),
              selectedColor: Colors.black,
              unselectedColor: Colors.grey),
          SalomonBottomBarItem(
              icon: const Icon(Icons.chat),
              title: const Text("Progress"),
              selectedColor: Colors.black,
              unselectedColor: Colors.grey),
          SalomonBottomBarItem(
              icon: const Icon(Icons.add_box),
              title: const Text("Add"),
              selectedColor: Colors.black,
              unselectedColor: Colors.grey),
          SalomonBottomBarItem(
              icon: const Icon(Icons.qr_code_scanner),
              title: const Text("Scan"),
              selectedColor: Colors.black,
              unselectedColor: Colors.grey),
          SalomonBottomBarItem(
              icon: const Icon(Icons.person),
              title: const Text("Profile"),
              selectedColor: Colors.black,
              unselectedColor: Colors.grey),
        ],
      ),
    );
  }
}
