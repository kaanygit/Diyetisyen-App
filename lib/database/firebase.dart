import 'package:diyetisyenapp/screens/admin/admin_home_screen.dart';
import 'package:diyetisyenapp/screens/auth/auth_screen.dart';
import 'package:diyetisyenapp/screens/auth/user_information_screen.dart';
import 'package:diyetisyenapp/screens/auth/dietcian_information_screen.dart';
import 'package:diyetisyenapp/screens/dietician/dietician_home_screen.dart';
import 'package:diyetisyenapp/screens/user/home.dart';
import 'package:diyetisyenapp/widget/flash_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';

class FirebaseOperations {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      // Firebase kimlik doğrulaması
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Giriş başarılı, kullanıcıyı yönlendir veya gerekli işlemleri yap
      print("Giriş başarılı: ${userCredential.user?.email}");

      // Profil tipi almak için getProfileType fonksiyonunu çağır
      int profileType = await getProfileType();

      // Profil tipine göre yönlendirme yap
      print("SİGN İN GELİYOR : $profileType");
      switch (profileType) {
        case 0:
          print("Navigating to HomeScreen for profile type 0");
          Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.fade, child: new HomeScreen()),
          );
          break;
        case 1:
          print("Navigating to DieticianHomeScreen for profile type 1");
          Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.fade,
                child: new DieticianHomeScreen()),
          );
          break;
        case 2:
          print("Navigating to AdminHomeScreen for profile type 2");
          Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.fade, child: new AdminHomeScreen()),
          );
          break;
        default:
          print("Unknown profile type: $profileType");
          showErrorSnackBar(context, "Tanımsız kullanıcı tipi: $profileType");
          break;
      }
    } catch (e) {
      // Giriş başarısız, hata mesajını göster
      print("Giriş başarısız: $e");
      showErrorSnackBar(
          context, "Giriş başarısız. Lütfen bilgilerinizi kontrol edin.");
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Can not SignOut as :$e');
    }
  }

  Future<UserCredential?> signUpWithEmailAndPassword(BuildContext context,
      String email, String password, String name, int methodsType) async {
    try {
      var existingUser = await _auth.fetchSignInMethodsForEmail(email);
      if (existingUser.isNotEmpty) {
        print("Hata: Bu e-posta zaten kullanımda.");
        return null;
      }

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Firestore'a kullanıcı bilgilerini kaydet
      try {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'displayName': name,
          'uid': userCredential.user?.uid,
          'profilePhoto': "",
          'phoneNumber': '',
          'educationLevel': '',
          'address': '',
          "fcmToken": "",
          'email': email,
          "aiChats": [],
          "diet-program": [],
          "dietician-person-uid": [],
          "dietician-danisanlar-uid": [],
          "danisanlar-istek": [],
          "new_user": true,
          "new_dietcian": true,

          'userType': methodsType == 0
              ? 'kullanici'
              : methodsType == 1
                  ? 'diyetisyen'
                  : 'admin',
          'updatedUser': DateTime.now(),
          'createdAt': DateTime.now(),
          // İsteğe bağlı diğer kullanıcı bilgileri buraya eklenebilir
        });
        print('Firestore\'a veri başarıyla kaydedildi.');

        int profileType = await getProfileType();

        // Profil tipine göre yönlendirme yap
        switch (profileType) {
          case 0:
            print("Navigating to HomeScreen for profile type 0");
            Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.fade,
                  child: new UserInformationScreen()),
            );
            break;
          case 1:
            print("Navigating to DieticianHomeScreen for profile type 1");
            Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.fade,
                  child: new DietcianInformationScreen()),
            );
            break;
          case 2:
            print("Navigating to AdminHomeScreen for profile type 2");
            Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.fade, child: new AdminHomeScreen()),
            );
            break;
          default:
            print("Unknown profile type: $profileType");
            showErrorSnackBar(context, "Tanımsız kullanıcı tipi: $profileType");
            break;
        }
      } catch (e) {
        print('Firestore\'a veri kaydederken hata oluştu: $e');
      }

      return userCredential;
    } catch (e) {
      print("Hata: $e");
      return null;
    }
  }

  Future<bool> signInWithGoogle() async {
    bool result = false;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          await _firestore.collection('users').doc(user.uid).set({
            'displayName': user.displayName,
            'uid': user.uid,
            'profilePhoto': user.photoURL,
            'phoneNumber': '',
            'educationLevel': '',
            'address': '',
            "fcmToken": "",
            'email': user.email,
            "aiChats": [],
            "diet-program": [],
            "dietician-person-uid": [],
            "dietician-danisanlar-uid": [],
            "danisanlar-istek": [],
            'userType': 'kullanici',
            "new_user": true,
            "new_dietcian": true,
            'updatedUser': DateTime.now(),
            'createdAt': DateTime.now(),
          });
        }
        result = true;
      }
      return result;
    } catch (e) {
      print("Error Google Sign In : $e");
    }
    return result;
  }

  Future<int> getProfileType() async {
    try {
      String uid = _auth.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        print("Kullanıcı oturum açmamış.");
        return 4;
      }

      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(uid).get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;
        print("Veri tipi ana sunucudan gelen cevap : $data");
        if (data.containsKey('userType')) {
          if (data['userType'] == "kullanici") {
            return 0;
          } else if (data['userType'] == "diyetisyen") {
            return 1;
          } else if (data['userType'] == "admin") {
            return 2;
          }
        }
        return 3; // Unrecognized userType
      } else {
        print("Belirtilen kullanıcının profil bilgisi bulunamadı.");
        return 3;
      }
    } catch (e) {
      print("Profil verisi getirilirken hata oluştu: $e");
      return 4;
    }
  }

  Future<bool> getNewUser() async {
    try {
      String uid = _auth.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        print("Kullanıcı oturum açmamış.");
        return false;
      }

      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(uid).get();

      if (snapshot.exists) {
        // Kullanıcı verisinin içindeki 'new_user' ögesinin değerini kontrol ediyoruz.
        bool isNewUser = snapshot.data()?['new_user'] ?? false;
        return isNewUser;
      } else {
        print("Kullanıcı verisi bulunamadı.");
        return false;
      }
    } catch (e) {
      print("Yeni kullanıcı olma verisi getirilemedi: $e");
      return false;
    }
  }

  Future<bool> getNewDietcian() async {
    try {
      String uid = _auth.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        print("Kullanıcı oturum açmamış.");
        return false;
      }

      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(uid).get();

      if (snapshot.exists) {
        // Kullanıcı verisinin içindeki 'new_user' ögesinin değerini kontrol ediyoruz.
        bool isNewDietcian = snapshot.data()?['new_dietcian'] ?? false;
        return isNewDietcian;
      } else {
        print("Kullanıcı verisi bulunamadı.");
        return false;
      }
    } catch (e) {
      print("Yeni kullanıcı olma verisi getirilemedi: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getDieticianData() async {
    try {
      print("Diyetisyenler getiriliyor");

      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'diyetisyen')
          .get();

      List<Map<String, dynamic>> dieticians = [];

      snapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        dieticians.add(data);
      });

      print("Diyetisyenler getirildi");
      return dieticians;
    } catch (e) {
      print("Diyetisyenler getirilirken hata oluştu : $e");
      return []; // veya null dönebilirsiniz, işlem başarısız olduğunda
    }
  }

  Future<void> addMealsFirebase(
      BuildContext context, Map<String, dynamic> meals) async {
    try {
      String uid = _auth.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        print("Kullanıcı oturum açmamış.");
        return;
      }

      DocumentSnapshot<Object?> snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('dietProgram')
          .doc('weeklyProgram')
          .get();

      if (snapshot.exists) {
        // Başlangıç tarihini kontrol et
        DateTime? startDate =
            (snapshot.data() as Map<String, dynamic>)['startDate']?.toDate();
        print("burası çalısıyor");
        if (startDate == null) {
          print("Başlangıç tarihi bulunamadı.");
          return;
        }

        // Güncel tarihi al
        DateTime now = DateTime.now();

        // Başlangıç tarihinden bugüne kadar geçen gün sayısı
        int daysSinceStart = now.difference(startDate).inDays;

        // Firebase'e eklenecek yemek verileri
        Map<String, dynamic> mealData = {
          'name': meals['name'],
          'foodName': meals['name'],
          'calories': meals['kalori'],
          'protein': meals['protein'],
          'fat': meals['yağ'],
          'carbs': meals['karbonhidrat'],
        };

        print("Meal Data : $mealData");

        // O güne ait mevcut yemek bilgilerini al
        DocumentReference dayDocRef = _firestore
            .collection('users')
            .doc(uid)
            .collection('dietProgram')
            .doc('weeklyProgram')
            .collection('meals')
            .doc('day_$daysSinceStart');

        DocumentSnapshot<Object?> daySnapshot = await dayDocRef.get();

        List<dynamic> updatedMeals = [];

        if (daySnapshot.exists && daySnapshot.data() != null) {
          // Mevcut yemek verilerini alın
          updatedMeals = List.from(
              (daySnapshot.data() as Map<String, dynamic>)['meals'] ?? []);
        }

        // Yeni yemek verisini ekleyin
        updatedMeals.add(mealData);

        // Güncellenmiş yemek listesini Firebase'e kaydedin
        await dayDocRef.set({'meals': updatedMeals}, SetOptions(merge: true));

        showSuccessSnackBar(context, "Yemeğiniz başarılı bir şekilde eklendi!");
      } else {
        print("Kullanıcı verisi bulunamadı.");
        showErrorSnackBar(
            context, "Kullanici verisi bulunamadı Lütfen tekrar deneyinizs");
      }
    } catch (e) {
      print("Veriler yüklenirken hata oluştu : $e");
      showErrorSnackBar(context, "Yemek eklenirken hata oluştu");
    }
  }

  Future<Map<String, dynamic>> getProfileBio() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;
        data['id'] = snapshot.id;
        return data;
      } else {
        print("Belirtilen kullanıcının profil bilgisi bulunamadı.");
        return {};
      }
    } catch (e) {
      print("Profil verisi getirilirken hata oluştu: $e");
      return {};
    }
  }

  Future<void> setEditProfileBio(String newAddress, String newDisplayName,
      String newEducationLevel, String newPhoneNumber) async {
    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'address': newAddress,
        'displayName': newDisplayName,
        'educationLevel': newEducationLevel,
        'phoneNumber': newPhoneNumber,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print(
          "Profil Verisi Güncellendi"); //buradaki bilgileri güncelliycem sistemdekiyle
    } catch (e) {
      print("Profil Verisi Eklenirken bir hata oluştu : $e");
    }
  }

  Future<DocumentSnapshot?> fetchUser(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      print('Error fetching user profile: $e');
      throw e; // Throw an error or handle it as per your application's error handling strategy
    }
  }

  Future<void> updateUserProfile(
      String uid, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('users').doc(uid).update(updatedData);
    } catch (e) {
      print('Error updating user profile: $e');
      throw e; // Throw an error or handle it as per your application's error handling strategy
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).delete();
      await _auth.currentUser!.delete();
    } catch (e) {
      print("Profil verileri silinirken bir hata oluştu : $e");
    }
  }

  // List<Map<String, dynamic>> yukleneceler = [
  //   {
  //     "resim":
  //         "https://www.tarihlisanat.com/wp-content/uploads/2018/09/2223.jpg",
  //     "isim": "Kolezyum",
  //     "ücreti": "1299",
  //     "konumu": "İtalya",
  //     "id": 1,
  //     "gün": 5,
  //     "hakkında":
  //         "Roma İmparatorluğu döneminde gladyatör dövüşlerine ve diğer kamusal etkinliklere ev sahipliği yapmış antik bir amfi tiyatro.",
  //     "kayıtlılar": [],
  //     "içerik": [],
  //     "beğenenler": []
  //   },
  //   {
  //     "resim":
  //         "https://i20.haber7.net/resize/1280x720//haber/haber7/photos/2019/40/piramitler_firavunlar_5_bin_yillik_gizemli_tarih_misir_gezi_rehberi_1570283520_9177.jpg",
  //     "isim": "Piramitler",
  //     "ücreti": "999",
  //     "konumu": "Mısır",
  //     "id": 2,
  //     "gün": 3,
  //     "hakkında":
  //         "Eski Mısır uygarlığının bir parçası olan piramitler, ölülerin gömülmesi için yapılmış anıtsal yapılardır.",
  //     "kayıtlılar": [],
  //     "içerik": [],
  //     "beğenenler": []
  //   },
  //   {
  //     "resim":
  //         "https://www.villacim.com.tr/uploads/1600x900xc1/474_artemistapinagigezilecekyerler.jpg",
  //     "isim": "Artemis Tapınağı",
  //     "ücreti": "650",
  //     "konumu": "Türkiye",
  //     "id": 3,
  //     "gün": 2,
  //     "hakkında":
  //         "Efes Antik Kenti'nde bulunan ve antik dünyanın yedi harikasından biri olarak kabul edilen Artemis Tapınağı, Artemis'e adanmış bir tapınaktı.",
  //     "kayıtlılar": [],
  //     "içerik": [],
  //     "beğenenler": []
  //   },
  //   {
  //     "resim":
  //         "https://www.hepsiburadaseyahat.com/blog/wp-content/uploads/2023/04/machu-picchu2.jpg",
  //     "isim": "Machu Picchu",
  //     "ücreti": "1999",
  //     "konumu": "Peru",
  //     "id": 4,
  //     "gün": 7,
  //     "hakkında":
  //         "Machu Picchu, Inka İmparatorluğu'nun döneminde inşa edilmiş muhteşem bir antik kenttir ve dünya mirası listesinde yer almaktadır.",
  //     "kayıtlılar": [],
  //     "içerik": [],
  //     "beğenenler": []
  //   },
  //   {
  //     "resim":
  //         "https://nafidurmus.com/wp-content/uploads/2020/05/20180827165739_IMG_3306-01-2048x2048.jpeg",
  //     "isim": "Tac Mahal",
  //     "ücreti": "899",
  //     "konumu": "Hindistan",
  //     "id": 5,
  //     "gün": 6,
  //     "hakkında":
  //         "Tac Mahal, Hindistan'ın Agra kentindeki bir anıt mezar kompleksi ve dünya mirasıdır. İmparator Şah Cihan'ın eşi Mumtaz Mahal'in anısına yapılmıştır.",
  //     "kayıtlılar": [],
  //     "içerik": [],
  //     "beğenenler": []
  //   },
  //   {
  //     "resim":
  //         "https://nafidurmus.com/wp-content/uploads/2020/05/20190828072443_IMG_5683-01-scaled.jpeg",
  //     "isim": "Çin Seddi",
  //     "ücreti": "1099",
  //     "konumu": "Çin",
  //     "id": 6,
  //     "gün": 4,
  //     "hakkında":
  //         "Çin Seddi, Çin'in kuzey sınırını korumak için inşa edilmiş devasa bir surlardır. Binlerce kilometre uzunluğundadır ve tarih boyunca pek çok Çin hanedanı tarafından inşa edilmiştir.",
  //     "kayıtlılar": [],
  //     "içerik": [],
  //     "beğenenler": []
  //   },
  // ];

  // Future<void> setFirebaseData() async {
  //   try {
  //     // Verileri Firestore'e kaydet
  //     for (var data in yukleneceler) {
  //       await _firestore.collection('places').add(data);
  //     }
  //     print("Veri başarıyla kaydedildi");
  //   } catch (e) {
  //     print("Veri Yüklenirken hata oluştu : $e");
  //   }
  // }

  void dispose() {
    // Firebase ile ilişkili kaynakları temizle
    _auth.signOut(); // Oturumu kapat
    // Firestore bağlantısını kapat (Opsiyonel olarak)
    // _firestore.terminate();
  }

  // Firestore ile iletişim işlevleri buraya eklenebilir
}
