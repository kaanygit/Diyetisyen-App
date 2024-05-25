import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diyetisyenapp/screens/auth/user_information_screen.dart';
import 'package:diyetisyenapp/screens/dietician/dietician_home_screen.dart';
import 'package:diyetisyenapp/widget/not_found_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // await saveDietPlans();
  runApp(const MyApp());
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
      home: StreamBuilder(
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
                builder: (context, AsyncSnapshot<int> profileTypeSnapshot) {
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
                        
                          print("Navigating to HomeScreen for profile type 0");
                          return HomeScreen();
                        case 1:
                          print(
                              "Navigating to MessagingScreen for profile type 1");

                          return DieticianHomeScreen();
                        
                        case 2:
                          print(
                              "Navigating to AdminHomeScreen for profile type 2");
                          return AdminHomeScreen();
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
      ),
    );
  }
}
