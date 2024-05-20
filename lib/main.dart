import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart'; // EasyLoading paketini ekleyin
import 'package:diyetisyenapp/screens/admin/admin_home_screen.dart';
import 'package:diyetisyenapp/screens/auth/auth_screen.dart';
import 'package:diyetisyenapp/screens/dietician/dietician_home_screen.dart';
import 'package:diyetisyenapp/screens/user/home.dart';
import 'package:diyetisyenapp/database/firebase.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: EasyLoading.init(), // EasyLoading'ı başlatın
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            EasyLoading.show(status: 'Loading...'); // Loading ekranını göster
            return Container(); // Boş bir Container döndür, loading ekranı yüklenirken
          } else {
            EasyLoading.dismiss(); // Loading ekranını kapat
            if (snapshot.hasData) {
              return FutureBuilder<int>(
                future: FirebaseOperations().getProfileType(),
                builder: (context, AsyncSnapshot<int> profileTypeSnapshot) {
                  if (profileTypeSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    EasyLoading.show(
                        status:
                            'Loading...'); // Yüklenirken loading ekranını göster
                    return Container(); // Boş bir Container döndür, loading ekranı yüklenirken
                  } else {
                    EasyLoading.dismiss(); // Loading ekranını kapat
                    switch (profileTypeSnapshot.data) {
                      case 0:
                        return HomeScreen();
                      case 1:
                        return DieticianHomeScreen();
                      case 2:
                        return AdminHomeScreen();
                      default:
                        return Scaffold(
                          body: Center(
                            child: Text(
                                "Tanımsız kullanıcı tipi: ${profileTypeSnapshot.data}"),
                          ),
                        );
                    }
                  }
                },
              );
            } else if (snapshot.hasError) {
              EasyLoading.dismiss(); // Loading ekranını kapat
              return Scaffold(
                body: Center(
                  child: Text(
                      "Bir hata oluştu. Detaylar için debug console'u kontrol edin."),
                ),
              );
            } else {
              EasyLoading.dismiss(); // Loading ekranını kapat
              return AuthScreen();
            }
          }
        },
      ),
    );
  }
}
