import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/screens/admin/admin_home_screen.dart';
import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_transition/page_transition.dart';

class DieticianDetailScreen extends StatelessWidget {
  final Map<String, dynamic> request;

  const DieticianDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    String userName = request['displayName'] ?? 'Bilinmeyen';
    String userEmail = request['email'] ?? 'E-posta yok';
    String userPhoto = request['profilePhoto'] ?? '';
    int userExperience = request['experience'] ?? 0;
    String userExpertise = request['expertise'] ?? 'Belirtilmemiş';
    String userGender = request['gender'] ?? 'Belirtilmemiş';
    String userTitle = request['title'] ?? 'Belirtilmemiş';
    String userWhyDietician = request['why_dietcian'] ?? 'Belirtilmemiş';
    int userAge = request['age'] ?? 0;
    String userEducationLevel = request['educationLevel'] ?? 'Belirtilmemiş';
    bool isDieticianConfirmed = request['dietcian_confirm'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text("$userName Bilgileri"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: userPhoto.isEmpty
                  ? const AssetImage('assets/images/default_avatar.jpg')
                  : NetworkImage(userPhoto) as ImageProvider,
            ),
            const SizedBox(height: 20),
            Text(
              userName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              userEmail,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildInfoRow('Deneyim', userExperience.toString()),
            _buildInfoRow('Uzmanlık', userExpertise),
            _buildInfoRow('Cinsiyet', userGender),
            _buildInfoRow('Ünvan', userTitle),
            _buildInfoRow('Neden Diyetisyen', userWhyDietician),
            _buildInfoRow('Yaş', userAge.toString()),
            _buildInfoRow('Eğitim Seviyesi', userEducationLevel),
            const SizedBox(height: 30),
            MyButton(
                text: isDieticianConfirmed
                    ? "Diyetisyen Onayını Kaldır"
                    : "Diyetisyen Olarak Onayla",
                buttonColor: mainColor,
                buttonTextColor: Colors.white,
                buttonTextSize: 20,
                buttonTextWeight: FontWeight.normal,
                onPressed: () => _showConfirmationDialog(context))
            // ElevatedButton(
            //   onPressed: () => _showConfirmationDialog(context),
            //   child: Text(isDieticianConfirmed
            //       ? "Diyetisyen Onayını Kaldır"
            //       : "Diyetisyen Olarak Onayla"),

            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            info,
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    bool isDieticianConfirmed = request['dietcian_confirm'] ?? false;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isDieticianConfirmed
            ? 'Onayı Kaldırmak İstiyor musunuz?'
            : 'Onaylamak İstiyor musunuz?'),
        content: Text(isDieticianConfirmed
            ? 'Bu kullanıcının diyetisyen onayını kaldırmak istediğinize emin misiniz?'
            : 'Bu kullanıcıyı diyetisyen olarak onaylamak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => _confirmDietician(context, !isDieticianConfirmed),
            child: const Text('Evet'),
          ),
        ],
      ),
    );
  }

  void _confirmDietician(BuildContext context, bool confirm) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(request['uid'])
        .update({'dietcian_confirm': confirm}).then((_) {
      Navigator.pop(context);

      Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.fade, child: const AdminHomeScreen()),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Hata: $error'),
      ));
    });
  }
}
