import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:diyetisyenapp/widget/flash_message.dart';
import 'package:diyetisyenapp/widget/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentUserUid;

  const EditProfileScreen({Key? key, required this.currentUserUid})
      : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _displayNameController;
  late TextEditingController _ageController;
  late TextEditingController _addressController;
  late TextEditingController _allergyFoodController;
  late TextEditingController _educationLevelController;
  late TextEditingController _heightController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _profilePhotoController;
  late TextEditingController _targetWeightController;
  late TextEditingController _weightController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _ageController = TextEditingController();
    _addressController = TextEditingController();
    _allergyFoodController = TextEditingController();
    _educationLevelController = TextEditingController();
    _heightController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _profilePhotoController = TextEditingController();
    _targetWeightController = TextEditingController();
    _weightController = TextEditingController();

    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(widget.currentUserUid)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data();

        if (userData != null) {
          _displayNameController.text = userData['displayName'] ?? '';
          _ageController.text = userData['age']?.toString() ?? '';
          _addressController.text = userData['address'] ?? '';
          _allergyFoodController.text = userData['allergy_food'] ?? '';
          _educationLevelController.text = userData['educationLevel'] ?? '';
          _heightController.text = userData['height']?.toString() ?? '';
          _phoneNumberController.text = userData['phoneNumber'] ?? '';
          _profilePhotoController.text = userData['profilePhoto'] ?? '';
          _targetWeightController.text =
              userData['targetWeight']?.toString() ?? '';
          _weightController.text = userData['weight']?.toString() ?? '';
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      // Handle error
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void saveProfile() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserUid)
          .update({
        'displayName': _displayNameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'address': _addressController.text.trim(),
        'allergy_food': _allergyFoodController.text.trim(),
        'educationLevel': _educationLevelController.text.trim(),
        'height': double.tryParse(_heightController.text.trim()) ?? 0.0,
        'phoneNumber': _phoneNumberController.text.trim(),
        'profilePhoto': _profilePhotoController.text.trim(),
        'targetWeight':
            double.tryParse(_targetWeightController.text.trim()) ?? 0.0,
        'weight': double.tryParse(_weightController.text.trim()) ?? 0.0,
      });
      Navigator.pop(context);
      showSuccessSnackBar(context, "Profil Güncelleme Başarılı");
    } catch (e) {
      print('Error updating profile: $e');
      showErrorSnackBar(
          context, "Profil bilgileri güncellenirken bir hata oluştu");
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _allergyFoodController.dispose();
    _educationLevelController.dispose();
    _heightController.dispose();
    _phoneNumberController.dispose();
    _profilePhotoController.dispose();
    _targetWeightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Bilgileri Güncelleme'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEditableTextField("Full Name", _displayNameController),
                  _buildEditableTextField("Age", _ageController),
                  _buildEditableTextField("Address", _addressController),
                  _buildEditableTextField(
                      "Allergy Food", _allergyFoodController),
                  _buildEditableTextField(
                      "Education Level", _educationLevelController),
                  _buildEditableTextField("Height", _heightController),
                  _buildEditableTextField(
                      "Phone Number", _phoneNumberController),
                  _buildEditableTextField(
                      "Profile Photo", _profilePhotoController),
                  _buildEditableTextField(
                      "Target Weight", _targetWeightController),
                  _buildEditableTextField("Weight", _weightController),
                  SizedBox(
                    height: 15,
                  ),
                  MyButton(
                      text: "Kaydet",
                      buttonColor: mainColor,
                      buttonTextColor: Colors.white,
                      buttonTextSize: 18,
                      buttonTextWeight: FontWeight.bold,
                      onPressed: saveProfile)
                ],
              ),
            ),
    );
  }

  Widget _buildEditableTextField(
      String label, TextEditingController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          MyTextField(
              controller: controller,
              hintText: label,
              obscureText: false,
              keyboardType: TextInputType.multiline,
              enabled: true)
        ],
      ),
    );
  }
}
