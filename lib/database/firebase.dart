import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseOperations {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print("Hata: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      _auth.signOut();
    } catch (e) {
      print('Can not SignOut as :$e');
    }
  }

  Future<UserCredential?> signUpWithEmailAndPassword(
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
          'email': email,
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
            'email': user.email,
            'userType': 'kullanici',
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
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;

        if (data['userType'] == "kullanici") {
          return 0;
        } else if (data['userType'] == "diyetisyen") {
          return 1;
        } else {
          return 2;
        }
      } else {
        print("Belirtilen kullanıcının profil bilgisi bulunamadı.");
        return 3;
      }
    } catch (e) {
      print("Profil verisi getirilirken hata oluştu: $e");
      return 4;
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
