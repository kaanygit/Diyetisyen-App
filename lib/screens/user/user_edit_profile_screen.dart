import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:diyetisyenapp/widget/flash_message.dart';
import 'package:diyetisyenapp/widget/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  final String currentUserUid;

  const EditProfileScreen({super.key, required this.currentUserUid});

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
  late TextEditingController _targetWeightController;
  late TextEditingController _weightController;

  bool isLoading = false;
  File? _image;
  String? _profilePhotoUrl;

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
          _profilePhotoUrl = userData['profilePhoto'] ?? '';
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

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProfilePhoto() async {
    if (_image == null) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profilePhotos/${widget.currentUserUid}.jpg');

      var uploadTask = await storageRef.putFile(_image!);
      var downloadUrl = await (uploadTask).ref.getDownloadURL();

      setState(() {
        _profilePhotoUrl = downloadUrl;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserUid)
          .update({
        'profilePhoto': _profilePhotoUrl,
      });
    } catch (e) {
      print('Error uploading profile photo: $e');
      // Handle error
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
        'targetWeight':
            double.tryParse(_targetWeightController.text.trim()) ?? 0.0,
        'weight': double.tryParse(_weightController.text.trim()) ?? 0.0,
        'profilePhoto': _profilePhotoUrl ?? '',
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
    _targetWeightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Bilgileri Güncelleme'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        if (_profilePhotoUrl != null &&
                            _profilePhotoUrl!.isNotEmpty)
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(_profilePhotoUrl!),
                          )
                        else if (_image != null)
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: FileImage(_image!),
                          )
                        else
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _pickImage,
                          child: const Text('Fotoğraf Yükle'),
                        ),
                      ],
                    ),
                  ),
                  _buildEditableTextField("Ad", _displayNameController),
                  _buildEditableTextField("Yaş", _ageController),
                  _buildEditableTextField("Adres", _addressController),
                  _buildEditableTextField(
                      "Alerji Yiyecekler", _allergyFoodController),
                  _buildEditableTextField(
                      "Eğitim Seviyesi", _educationLevelController),
                  _buildEditableTextField("Boy", _heightController),
                  _buildEditableTextField(
                      "Telefon Numarası", _phoneNumberController),
                  _buildEditableTextField(
                      "Hedef Kilo", _targetWeightController),
                  _buildEditableTextField("Kilo", _weightController),
                  const SizedBox(
                    height: 15,
                  ),
                  MyButton(
                      text: "Kaydet",
                      buttonColor: mainColor,
                      buttonTextColor: Colors.white,
                      buttonTextSize: 18,
                      buttonTextWeight: FontWeight.bold,
                      onPressed: () async {
                        if (_image != null) {
                          await _uploadProfilePhoto();
                        }
                        saveProfile();
                      })
                ],
              ),
            ),
    );
  }

  Widget _buildEditableTextField(
      String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
