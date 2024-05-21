import 'package:diyetisyenapp/screens/dietician/dietician_home_screen.dart';
import 'package:diyetisyenapp/screens/dietician/message_screen.dart';
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

  runApp(const MyApp());
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

                          // return DieticianHomeScreen();
                          return MessagingScreen(
                            receiverId: 'QhmK9UJcR2bjTzn9fTsm7HJil3T2',
                          );
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
