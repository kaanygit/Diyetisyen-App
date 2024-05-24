import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({Key? key}) : super(key: key);

  @override
  _UserInformationScreenState createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController targetWeightController = TextEditingController();
  final TextEditingController likedFoodsController = TextEditingController();
  final TextEditingController dislikedFoodsController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildPage(
        title: 'Age and Weight',
        fields: [
          TextFormField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Age'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your age';
              }
              return null;
            },
          ),
          TextFormField(
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Weight (kg)'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your weight';
              }
              return null;
            },
          ),
        ],
      ),
      _buildPage(
        title: 'Height and Target Weight',
        fields: [
          TextFormField(
            controller: heightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Height (cm)'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your height';
              }
              return null;
            },
          ),
          TextFormField(
            controller: targetWeightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Target Weight (kg)'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your target weight';
              }
              return null;
            },
          ),
        ],
      ),
      _buildPage(
        title: 'Liked and Disliked Foods',
        fields: [
          TextFormField(
            controller: likedFoodsController,
            decoration: InputDecoration(labelText: 'Liked Foods'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter foods you like';
              }
              return null;
            },
          ),
          TextFormField(
            controller: dislikedFoodsController,
            decoration: InputDecoration(labelText: 'Disliked Foods'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter foods you dislike';
              }
              return null;
            },
          ),
        ],
      ),
    ];
  }

  Widget _buildPage({required String title, required List<Widget> fields}) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ...fields,
          SizedBox(height: 20),
        ],
      ),
    );
  }

  void _submitForm(String uid) {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed to save data
      FirebaseFirestore.instance.collection('users').doc(uid).set({
        'age': int.parse(ageController.text),
        'weight': double.parse(weightController.text),
        'height': double.parse(heightController.text),
        'targetWeight': double.parse(targetWeightController.text),
        'likedFoods': likedFoodsController.text,
        'dislikedFoods': dislikedFoodsController.text,
      }).then((_) {
        // Navigate to home screen after saving data
        Navigator.pushReplacementNamed(context, '/home');
      }).catchError((error) => print("Failed to add user: $error"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Information'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _pages[index];
              },
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentPageIndex > 0
                      ? () {
                          _pageController.previousPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        }
                      : null,
                  child: Text('Back'),
                ),
                ElevatedButton(
                  onPressed: _currentPageIndex < _pages.length - 1
                      ? () {
                          _pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        }
                      : () {
                          FirebaseAuth auth = FirebaseAuth.instance;
                          String uid = auth.currentUser!.uid;
                          _submitForm(uid);
                        },
                  child: _currentPageIndex == _pages.length - 1
                      ? Text('Finish')
                      : Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
