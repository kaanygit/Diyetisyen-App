import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/screens/add_meals_screen.dart';
import 'package:diyetisyenapp/screens/home_page.dart';
import 'package:diyetisyenapp/screens/profile_screen.dart';
import 'package:diyetisyenapp/screens/progress_screen.dart';
import 'package:diyetisyenapp/screens/scan_screen.dart';
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
    ProgressScreen(),
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
            icon: Icon(Icons.home),
            title: Text("Home"),
            selectedColor: mainColor,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.bar_chart),
            title: Text("Progress"),
            selectedColor: mainColor,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.add_box),
            title: Text("Add"),
            selectedColor: mainColor,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.qr_code_scanner),
            title: Text("Scan"),
            selectedColor: mainColor,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile"),
            selectedColor: mainColor,
          ),
        ],
      ),
    );
  }
}
