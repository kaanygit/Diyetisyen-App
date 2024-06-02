import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/screens/user/user_edit_profile_screen.dart';
import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:diyetisyenapp/widget/flash_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProgressScreenPage extends StatefulWidget {
  ProgressScreenPage({Key? key}) : super(key: key);

  @override
  _ProgressScreenPageState createState() => _ProgressScreenPageState();
}

class _ProgressScreenPageState extends State<ProgressScreenPage> {
  int selectedWeek = 1;
  List<int> weeks = [1, 2, 3, 4];
  bool loadingValue = true;
  bool getDietcianPersonAvaliable = true;

  late Map<String, dynamic> dietData = {};
  late Map<String, dynamic> profileData = {};

  int totalCalories = 0;
  int totalFat = 0;
  int totalProtein = 0;
  int totalCarbs = 0;

  int totalDailyCalories = 0;
  int totalDailyeatCalories = 0;
  String dailyEatingRatio = "";

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future<void> getProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentSnapshot snapshot = await firestore
          .collection('users')
          .doc(user!.uid)
          .collection('dietProgram')
          .doc('weeklyProgram')
          .get();
      DocumentSnapshot snapshotProfile =
          await firestore.collection('users').doc(user.uid).get();
      DocumentSnapshot snapshotDietProgramAvaliable = await firestore
          .collection('users')
          .doc(user.uid)
          .collection("dietProgram")
          .doc("weeklyProgram")
          .get();

      if (snapshotDietProgramAvaliable.exists) {
        setState(() {
          getDietcianPersonAvaliable = true;
        });
        if (snapshot.exists && snapshotProfile.exists) {
          dynamic data = snapshot.data();
          dynamic profileDatas = snapshotProfile.data();
          setState(() {
            dietData = data as Map<String, dynamic>;
            profileData = profileDatas as Map<String, dynamic>;
          });
          dietDataIfStatement();
        } else {
          showErrorSnackBar(context, "Hata1");
        }
      } else {
        setState(() {
          getDietcianPersonAvaliable = false;
        });
      }
      // if (snapshot.exists && snapshotProfile.exists) {
      //   dynamic data = snapshot.data();
      //   dynamic profileDatas = snapshotProfile.data();
      //   setState(() {
      //     dietData = data as Map<String, dynamic>;
      //     profileData = profileDatas as Map<String, dynamic>;
      //   });
      //   dietDataIfStatement();
      // } else {
      //   showErrorSnackBar(context, "Hata1");
      // }
      // if (snapshotDietProgramAvaliable.exists) {
      //   setState(() {
      //     getDietcianPersonAvaliable = true;
      //   });
      // } else {
      //   setState(() {
      //     getDietcianPersonAvaliable = false;
      //   });
      // }
    } catch (e) {
      print("Profil verileri getirilirken hata oluştu : $e");
      showErrorSnackBar(context, "Profil verileri getirilirken hata oluştu");
    }
  }

  Future<void> dietDataIfStatement() async {
    User? user = FirebaseAuth.instance.currentUser;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final List<String> days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];

    DateTime? startDate = dietData['startDate']?.toDate();
    DateTime now = DateTime.now();
    int daysSinceStart = now.difference(startDate!).inDays;

    DocumentSnapshot<Map<String, dynamic>> snapshotEating = await firestore
        .collection('users')
        .doc(user!.uid)
        .collection('dietProgram')
        .doc('weeklyProgram')
        .collection('meals')
        .doc('day_$daysSinceStart')
        .get();

    Map<String, dynamic>? ekstraYemeler = snapshotEating.data();
    if (ekstraYemeler != null) {
      List<dynamic> meals = ekstraYemeler['meals'];
      meals.forEach((meal) {
        print(meal);
        setState(() {
          totalDailyeatCalories += (meal['calories'] as num).toInt();
          totalCalories += (meal['calories'] as num).toInt();
          totalCarbs += (meal['carbs'] as num).toInt();
          totalFat += (meal['fat'] as num).toInt();
          totalProtein += (meal['protein'] as num).toInt();
        });
      });
      print("TEST:$totalCalories");
    }

    int week = (daysSinceStart ~/ 7) % 4 + 1;
    int dayIndex = daysSinceStart % 7;
    String day = days[dayIndex];

    if (dietData['week$selectedWeek'][day]['breakfast']['eat'] == true) {
      setState(() {
        totalDailyeatCalories +=
            dietData['week$week'][day]['breakfast']['calories'] as int;
      });
    }
    if (dietData['week$selectedWeek'][day]['lunch']['eat'] == true) {
      setState(() {
        totalDailyeatCalories +=
            dietData['week$week'][day]['lunch']['calories'] as int;
      });
    }
    if (dietData['week$selectedWeek'][day]['dinner']['eat'] == true) {
      setState(() {
        totalDailyeatCalories +=
            dietData['week$week'][day]['dinner']['calories'] as int;
      });
    }
    setState(() {
      totalDailyCalories +=
          dietData['week$week'][day]['dinner']['calories'] as int;
      totalDailyCalories +=
          dietData['week$week'][day]['breakfast']['calories'] as int;
      totalDailyCalories +=
          dietData['week$week'][day]['lunch']['calories'] as int;
    });

    double percentageCompleted =
        (totalDailyeatCalories / totalDailyCalories) * 100;
    String formattedPercentage = percentageCompleted.toStringAsFixed(1);
    setState(() {
      dailyEatingRatio = formattedPercentage;
    });
    print("testt $percentageCompleted");

    Map<String, dynamic> data = dietData['week$selectedWeek'];

    int dailyCalories = 0;
    int dailyFat = 0;
    int dailyProtein = 0;
    int dailyCarbs = 0;
    for (var day in days) {
      if (data[day]['breakfast']['eat'] == true) {
        dailyCalories += data[day]['breakfast']['calories'] as int;
        dailyFat += data[day]['breakfast']['fat'] as int;
        dailyProtein += data[day]['breakfast']['protein'] as int;
        dailyCarbs += data[day]['breakfast']['carbs'] as int;
      }
      if (data[day]['lunch']['eat'] == true) {
        dailyCalories += data[day]['lunch']['calories'] as int;
        dailyFat += data[day]['lunch']['fat'] as int;
        dailyProtein += data[day]['lunch']['protein'] as int;
        dailyCarbs += data[day]['lunch']['carbs'] as int;
      }
      if (data[day]['dinner']['eat'] == true) {
        dailyCalories += data[day]['dinner']['calories'] as int;
        dailyFat += data[day]['dinner']['fat'] as int;
        dailyProtein += data[day]['dinner']['protein'] as int;
        dailyCarbs += data[day]['dinner']['carbs'] as int;
      }
    }
    setState(() {
      totalCalories += dailyCalories;
      totalCarbs += dailyCarbs;
      totalFat += dailyFat;
      totalProtein += dailyProtein;
    });
  }

  @override
  Widget build(BuildContext context) {
    return getDietcianPersonAvaliable
        ? Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gelişim',
                    style: fontStyle(18, mainColor, FontWeight.bold),
                  ),
                  DropdownButton<int>(
                    value: selectedWeek,
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                    underline: SizedBox(),
                    items: weeks.map((int week) {
                      return DropdownMenuItem<int>(
                        value: week,
                        child: Text('Week $week',
                            style: TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedWeek = newValue!;
                        totalCalories = 0;
                        totalFat = 0;
                        totalProtein = 0;
                        totalCarbs = 0;

                        totalDailyCalories = 0;
                        totalDailyeatCalories = 0;
                        dailyEatingRatio = "";
                        getProfile();
                      });
                    },
                  ),
                ],
              ),
            ),
            body: loadingValue
                ? SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWeeklyProgressCard(),
                        SizedBox(height: 16.0),
                        Text(
                          'Son Değerleriniz',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16.0),
                        _buildWeightCard(),
                        SizedBox(height: 16.0),
                        _buildCaloriesCard(),
                      ],
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(
                "Gelişim",
                style: fontStyle(18, mainColor, FontWeight.bold),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    "Lütfen Diyetisyeninizden Diyet Listenizi Alınız",
                    textAlign: TextAlign.center, // Metni yatayda ortalamak için
                    style: fontStyle(25, mainColor, FontWeight.bold),
                  ),
                ),
              ),
            ),
          );
  }

  Widget _buildWeeklyProgressCard() {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Haftalık Gelişim',
              style: fontStyle(18.0, Colors.black, FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kalori',
                        style: fontStyle(12.0, Colors.grey, FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Icon(Icons.whatshot, color: Colors.red),
                          SizedBox(width: 4.0),
                          Text(
                            '$totalCalories',
                            style:
                                fontStyle(24.0, Colors.black, FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _buildProgressCircle(totalFat, 'Fat'),
                    SizedBox(width: 10.0),
                    _buildProgressCircle(totalProtein, 'Pro'),
                    SizedBox(width: 10.0),
                    _buildProgressCircle(totalCarbs, 'Carb'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightCard() {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kilonuz',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    '${profileData['weight'] ?? "0.0"} Kg',
                    style: fontStyle(24.0, Colors.black, FontWeight.bold),
                  ),
                  Text(
                    'Hedef kilonuz : ${profileData['targetWeight'] ?? "0.0"} Kg',
                    style: fontStyle(16.0, Colors.grey, FontWeight.normal),
                  ),
                  SizedBox(height: 20.0),
                  MyButton(
                    text: "Yeni bir kilo giriniz",
                    buttonColor: mainColor,
                    buttonTextColor: Colors.white,
                    buttonTextSize: 15,
                    buttonTextWeight: FontWeight.bold,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(
                              currentUserUid: profileData['uid'] ?? ''),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.0),
            Container(
              width: 80.0,
              height: 80.0,
              child: CustomPaint(
                  painter: _WeightGraphPainter(
                currentWeight: (profileData['weight'] ?? 0.0).toDouble(),
                targetWeight: (profileData['targetWeight'] ?? 0.0).toDouble(),
              )
                  // targetWeight: (profileData['targetWeight'] ?? 0.0)),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesCard() {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kalori',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '${totalDailyeatCalories} Kcal',
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${dailyEatingRatio}% Tamamlandı',
                    style: TextStyle(color: Colors.green, fontSize: 16.0),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.0),
            Container(
              width: 80.0,
              height: 80.0,
              child: CustomPaint(
                painter: CaloriesGraphPainter(
                    percentage:
                        ((totalDailyeatCalories / totalDailyCalories) * 100)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCircle(int percentage, String label) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 50.0,
              width: 50.0,
              child: CircularProgressIndicator(
                value: percentage / 100.0,
                strokeWidth: 6.0,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            Column(
              children: [
                Text(
                  '$percentage',
                  style: fontStyle(15, Colors.black, FontWeight.bold),
                ),
                Text(
                  'Gram',
                  style: fontStyle(12, Colors.grey, FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 4.0),
        Text(label),
      ],
    );
  }
}

class CaloriesGraphPainter extends CustomPainter {
  final double percentage;

  CaloriesGraphPainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = mainColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = -3.14 / 2;
    final sweepAngle = 2 * 3.14 * (percentage / 100);

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class _WeightGraphPainter extends CustomPainter {
  final double currentWeight;
  final double targetWeight;

  _WeightGraphPainter({
    required this.currentWeight,
    required this.targetWeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue // mainColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final difference = targetWeight - currentWeight;
    final percentage = (difference / targetWeight).clamp(-1.0, 1.0);
    print(
        'Percentage: $percentage'); // Hata ayıklama için yüzdelik değeri yazdır

    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = -3.14 / 2;
    final sweepAngle = -2 * 3.14 * percentage; // current progress

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
