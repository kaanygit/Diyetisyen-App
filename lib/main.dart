import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/screens/auth/user_information_screen.dart';
import 'package:diyetisyenapp/screens/auth/dietcian_information_screen.dart';
import 'package:diyetisyenapp/screens/dietician/dietician_home_screen.dart';
import 'package:diyetisyenapp/widget/not_found_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:diyetisyenapp/screens/admin/admin_home_screen.dart';
import 'package:diyetisyenapp/screens/auth/auth_screen.dart';
import 'package:diyetisyenapp/screens/user/home.dart';
import 'package:diyetisyenapp/database/firebase.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // addDataToFirestore();
  // saveDietPlans();
  runApp(const MyApp());
}

void addDataToFirestore() async {
  // JSON dosyasını oku
  String jsonString = await rootBundle.loadString('assets/data.json');
  Map<String, dynamic> data = jsonDecode(jsonString);

  // Firestore referansı al
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Firestore'a verileri ekle
  data.forEach((key, value) {
    firestore.collection('foods').doc(key).set(value);
  });
}

Future<void> saveDietPlans() async {
  // Create the diet plans
  List<Map<String, dynamic>> dietPlans = createDietPlans();

  try {
    // Save each diet plan to Firestore
    for (var dietPlan in dietPlans) {
      await FirebaseFirestore.instance.collection('diet_list').add(dietPlan);
    }
    print('Diet plans saved successfully');
  } catch (e) {
    print('Error saving diet plans: $e');
  }
}

List<Map<String, dynamic>> createDietPlans() {
  List<Map<String, dynamic>> dietPlans = [];
  for (int i = 0; i < 3; i++) {
    dietPlans.add(createDietPlan());
  }
  return dietPlans;
}

Map<String, dynamic> createDietPlan() {
  List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List<String> meals = ['breakfast', 'lunch', 'dinner'];
  Map<String, dynamic> dietPlan = {};

  for (int week = 1; week <= 4; week++) {
    Map<String, dynamic> weekData = {};
    for (String day in days) {
      Map<String, dynamic> dayData = {};
      for (String meal in meals) {
        dayData[meal] = generateMeal(meal);
      }
      weekData[day] = dayData;
    }
    dietPlan['week$week'] = weekData;
  }

  return dietPlan;
}

Map<String, dynamic> generateMeal(String mealType) {
  String diet = generateDiet(mealType);
  return {
    'diet': diet,
    'calories': calculateCalories(diet),
    'fat': calculateFat(diet),
    'protein': calculateProtein(diet),
    'carbs': calculateCarbs(diet),
    'water': 5, // Replace with actual water data
    'dailyMeat': [],
    'eat': false,
    "drinkWater": false
  };
}

String generateDiet(String mealType) {
  // Replace with actual diet generation logic
  switch (mealType) {
    case 'breakfast':
      return 'Oatmeal with fruits';
    case 'lunch':
      return 'Grilled chicken with vegetables';
    case 'dinner':
      return 'Salmon with quinoa';
    default:
      return 'Meal';
  }
}

// Placeholder functions for calculating nutritional values
int calculateCalories(String diet) {
  // Replace with actual calculation logic
  return 500;
}

int calculateFat(String diet) {
  // Replace with actual calculation logic
  return 20;
}

int calculateProtein(String diet) {
  // Replace with actual calculation logic
  return 30;
}

int calculateCarbs(String diet) {
  // Replace with actual calculation logic
  return 50;
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background messages here
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: EasyLoading.init(), // Initialize EasyLoading
      debugShowCheckedModeBanner: false,
      home: HomeScreenWrapper(),
    );
  }
}

class HomeScreenWrapper extends StatefulWidget {
  const HomeScreenWrapper({Key? key}) : super(key: key);

  @override
  _HomeScreenWrapperState createState() => _HomeScreenWrapperState();
}

class _HomeScreenWrapperState extends State<HomeScreenWrapper> {
  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Internet Connection',
              style: fontStyle(20, mainColor, FontWeight.bold)),
          content: Text(
              'You are not connected to the internet. Please check your connection and try again.',
              style: fontStyle(20, mainColor, FontWeight.bold)),
          actions: <Widget>[
            TextButton(
              child: const Text('Retry'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {}); // Retry checking internet connection
              },
            ),
            TextButton(
              child: const Text('Exit'),
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop(); // Close the app
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkInternetConnection(),
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          EasyLoading.show(status: 'Checking internet connection...');
          return Container(); // Empty container while checking connection
        } else {
          EasyLoading.dismiss(); // Dismiss loading screen
          if (snapshot.hasData && snapshot.data == true) {
            return StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, AsyncSnapshot<User?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  EasyLoading.show(status: 'Loading...'); // Show loading screen
                  return Container(); // Empty container while loading
                } else {
                  EasyLoading.dismiss(); // Dismiss loading screen
                  if (snapshot.hasData) {
                    return FutureBuilder<int>(
                      future: FirebaseOperations().getProfileType(),
                      builder:
                          (context, AsyncSnapshot<int> profileTypeSnapshot) {
                        if (profileTypeSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          EasyLoading.show(
                              status:
                                  'Loading...'); // Show loading screen while fetching profile type
                          return Container(); // Empty container while loading
                        } else {
                          EasyLoading.dismiss(); // Dismiss loading screen
                          if (profileTypeSnapshot.hasData) {
                            int? profileType = profileTypeSnapshot.data;
                            print("Fetched profile type: $profileType");
                            switch (profileType) {
                              case 0:
                                print(
                                    "Navigating to HomeScreen for profile type 0");
                                return FutureBuilder<bool>(
                                  future: FirebaseOperations().getNewUser(),
                                  builder: (context,
                                      AsyncSnapshot<bool> newUserSnapshot) {
                                    if (newUserSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      EasyLoading.show(status: 'Loading...');
                                      return Container();
                                    } else {
                                      EasyLoading.dismiss();
                                      if (newUserSnapshot.hasData &&
                                          newUserSnapshot.data == true) {
                                        return new UserInformationScreen();
                                      } else {
                                        return new HomeScreen();
                                      }
                                    }
                                  },
                                );
                              case 1:
                                print(
                                    "Navigating to DieticianHomeScreen for profile type 1");
                                return FutureBuilder<bool>(
                                  future: FirebaseOperations().getNewDietcian(),
                                  builder: (context,
                                      AsyncSnapshot<bool>
                                          newDieticianSnapshot) {
                                    if (newDieticianSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      EasyLoading.show(status: 'Loading...');
                                      return Container();
                                    } else {
                                      EasyLoading.dismiss();
                                      if (newDieticianSnapshot.hasData &&
                                          newDieticianSnapshot.data == true) {
                                        return new DietcianInformationScreen();
                                      } else {
                                        return new DieticianHomeScreen();
                                      }
                                    }
                                  },
                                );
                              case 2:
                                print(
                                    "Navigating to AdminHomeScreen for profile type 2");
                                return new AdminHomeScreen();
                              default:
                                print("Unknown profile type: $profileType");
                                return NotFoundScreen();
                            }
                          } else if (profileTypeSnapshot.hasError) {
                            print(
                                "Error fetching profile type: ${profileTypeSnapshot.error}");
                            return Scaffold(
                              body: Center(
                                child: Text(
                                    "Profil tipi alınırken bir hata oluştu: ${profileTypeSnapshot.error}"),
                              ),
                            );
                          } else {
                            print("Profile type not found");
                            return const Scaffold(
                              body: Center(
                                child: Text("Profil tipi bulunamadı"),
                              ),
                            );
                          }
                        }
                      },
                    );
                  } else if (snapshot.hasError) {
                    EasyLoading.dismiss(); // Dismiss loading screen
                    print("Authentication error: ${snapshot.error}");
                    return const Scaffold(
                      body: Center(
                        child: Text(
                            "Bir hata oluştu. Detaylar için debug console'u kontrol edin."),
                      ),
                    );
                  } else {
                    EasyLoading.dismiss(); // Dismiss loading screen
                    return const AuthScreen();
                  }
                }
              },
            );
          } else {
            _showNoInternetDialog();
            return Container(); // Show an empty container if no internet
          }
        }
      },
    );
  }
}
