import 'package:diyetisyenapp/screens/user/add_meals_screen.dart';
import 'package:diyetisyenapp/screens/user/chat/chat_screen.dart';
import 'package:diyetisyenapp/screens/user/home_page.dart';
import 'package:diyetisyenapp/screens/user/profile_screen.dart';
import 'package:diyetisyenapp/screens/user/progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

  static  List<Widget> widgetOptions = <Widget>[
    HomePage(),
    ChatScreen(),
    AddMeals(),
    ProgressScreenPage(),
    ProfileScreen(),
  ];

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
