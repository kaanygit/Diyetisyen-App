import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/database/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedMeal = "Meals"; // Seçilen butonu takip etmek için değişken
  List<Map<String, dynamic>> dietProgram = [];
  bool isLoading = true;
  int currentDayIndex = 0; // Günlük veriler için indeks
  bool hasDietProgram = true;

  int totalCalories = 0;
  int totalProtein = 0;
  int totalCarbs = 0;
  int totalFat = 0;
  int totalWater = 0;

  dynamic dailyCalories = 0; // Günlük toplam kalorileri saklamak için değişken
  dynamic dailyProtein =
      0; // Günlük toplam protein miktarını saklamak için değişken
  dynamic dailyCarbs =
      0; // Günlük toplam karbonhidrat miktarını saklamak için değişken
  dynamic dailyFat = 0;
  dynamic dailyWater = 0;

  @override
  void initState() {
    super.initState();
    fetchDietProgram();
  }

  Future<void> fetchDietProgram() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String? uid = user?.uid;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('dietProgram')
          .doc('weeklyProgram')
          .get();
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> weeklyProgram = [];

        // Haftalık programı düzenle
        for (int i = 1; i <= 4; i++) {
          for (int j = 1; j <= 7; j++) {
            String dayName = '';
            switch (j) {
              case 1:
                dayName = 'Monday';
                break;
              case 2:
                dayName = 'Tuesday';
                break;
              case 3:
                dayName = 'Wednesday';
                break;
              case 4:
                dayName = 'Thursday';
                break;
              case 5:
                dayName = 'Friday';
                break;
              case 6:
                dayName = 'Saturday';
                break;
              case 7:
                dayName = 'Sunday';
                break;
              default:
                dayName = '';
            }

            // Günlük öğünler
            var breakfast = data['week$i'][dayName]['breakfast'];
            var lunch = data['week$i'][dayName]['lunch'];
            var dinner = data['week$i'][dayName]['dinner'];

            int dayCalories = (breakfast['calories'] ?? 0) +
                (lunch['calories'] ?? 0) +
                (dinner['calories'] ?? 0);

            int dayProtein = (breakfast['protein'] ?? 0) +
                (lunch['protein'] ?? 0) +
                (dinner['protein'] ?? 0);

            int dayCarbs = (breakfast['carbs'] ?? 0) +
                (lunch['carbs'] ?? 0) +
                (dinner['carbs'] ?? 0);

            int dayFat = (breakfast['fat'] ?? 0) +
                (lunch['fat'] ?? 0) +
                (dinner['fat'] ?? 0);

            int dayWater = (breakfast['water'] ?? 0) +
                (lunch['water'] ?? 0) +
                (dinner['water'] ?? 0);

            Map<String, dynamic> dayProgram = {
              'day': dayName,
              'meals': {
                'breakfast': breakfast,
                'lunch': lunch,
                'dinner': dinner,
              },
              'calories': dayCalories,
              'protein': dayProtein,
              'carbs': dayCarbs,
              'fat': dayFat,
              'water': dayWater,
            };

            weeklyProgram.add(dayProgram);
          }
        }

        setState(() {
          dietProgram = weeklyProgram;
          updateDailyValues();
          print(dietProgram);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasDietProgram = false;
        });
      }
    } catch (e) {
      print("Error fetching diet program: $e");
      setState(() {
        isLoading = false;
        hasDietProgram = false;
      });
    }
  }

  Future<void> updateEatField(
      String mealType, dynamic dietProgram, int weekIndex, int dayss) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('Kullanıcı oturumu bulunamadı.');
        return;
      }

      print("diyet programı : $mealType");
      final int hafta;
      final String yemekVakti;

      if (currentDayIndex >= 0 && currentDayIndex <= 6) {
        hafta = 1;
      } else if (currentDayIndex >= 7 && currentDayIndex <= 13) {
        hafta = 2;
      } else if (currentDayIndex >= 14 && currentDayIndex <= 20) {
        hafta = 3;
      } else if (currentDayIndex >= 21 && currentDayIndex <= 27) {
        hafta = 4;
      } else {
        throw Exception("Geçersiz gün indeksi: $currentDayIndex");
      }

      if (mealType == "kahvaltı") {
        yemekVakti = "breakfast";
      } else if (mealType == "öğlen yemeği") {
        yemekVakti = "lunch";
      } else {
        yemekVakti = "dinner";
      }

      String getDayName(int index) {
        String dayName = "";
        if (index == 0) {
          dayName = "Monday";
        } else if (index == 1) {
          dayName = "Tuesday";
        } else if (index == 2) {
          dayName = "Wednesday";
        } else if (index == 3) {
          dayName = "Thursday";
        } else if (index == 4) {
          dayName = "Friday";
        } else if (index == 5) {
          dayName = "Saturday";
        } else if (index == 6) {
          dayName = "Sunday";
        } else {
          // Geçersiz indeks durumu
          dayName = "Invalid Day";
        }
        return dayName;
      }

      String gun = getDayName(currentDayIndex % 7);
      print("gun $currentDayIndex => $gun");
      String uid = user.uid;
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentReference dietProgramRef = firestore
          .collection('users')
          .doc(uid)
          .collection('dietProgram')
          .doc('weeklyProgram');

      Map<String, dynamic> updateData = {
        'week$hafta.$gun.$yemekVakti.eat': true,
      };

      await dietProgramRef.update(updateData);
      dailyCalories = 1000;
      print('Eat alanı başarıyla güncellendi.');
      fetchDietProgram();
    } catch (e) {
      print('Hata oluştu: $e');
    }
  }

  Future<void> updateDrinkWater(
      String mealType, dynamic dietProgram, int weekIndex, int dayss) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('Kullanıcı oturumu bulunamadı.');
        return;
      }

      print("diyet programı : $mealType");
      final int hafta;
      final String yemekVakti;

      if (currentDayIndex >= 0 && currentDayIndex <= 6) {
        hafta = 1;
      } else if (currentDayIndex >= 7 && currentDayIndex <= 13) {
        hafta = 2;
      } else if (currentDayIndex >= 14 && currentDayIndex <= 20) {
        hafta = 3;
      } else if (currentDayIndex >= 21 && currentDayIndex <= 27) {
        hafta = 4;
      } else {
        throw Exception("Geçersiz gün indeksi: $currentDayIndex");
      }

      if (mealType == "kahvaltı") {
        yemekVakti = "breakfast";
      } else if (mealType == "öğlen yemeği") {
        yemekVakti = "lunch";
      } else {
        yemekVakti = "dinner";
      }

      String getDayName(int index) {
        String dayName = "";
        if (index == 0) {
          dayName = "Monday";
        } else if (index == 1) {
          dayName = "Tuesday";
        } else if (index == 2) {
          dayName = "Wednesday";
        } else if (index == 3) {
          dayName = "Thursday";
        } else if (index == 4) {
          dayName = "Friday";
        } else if (index == 5) {
          dayName = "Saturday";
        } else if (index == 6) {
          dayName = "Sunday";
        } else {
          // Geçersiz indeks durumu
          dayName = "Invalid Day";
        }
        return dayName;
      }

      String gun = getDayName(currentDayIndex % 7);
      print("gun $currentDayIndex => $gun");
      String uid = user.uid;
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentReference dietProgramRef = firestore
          .collection('users')
          .doc(uid)
          .collection('dietProgram')
          .doc('weeklyProgram');

      Map<String, dynamic> updateData = {
        'week$hafta.$gun.$yemekVakti.drinkWater': true,
      };

      await dietProgramRef.update(updateData);
      print('Eat alanı başarıyla güncellendi.');
      fetchDietProgram();
    } catch (e) {
      print('Hata oluştu: $e');
    }
  }

  void updateDailyValues() {
    if (dietProgram.isNotEmpty && currentDayIndex < dietProgram.length) {
      var dayData = dietProgram[currentDayIndex];
      dailyCalories = 0;
      dailyProtein = 0;
      dailyCarbs = 0;
      dailyFat = 0;
      dailyWater = 0;

      // Breakfast
      if (!(dayData['meals']['breakfast']['eat'] ?? true)) {
        dailyCalories += dayData['meals']['breakfast']['calories'] ?? 0;
        dailyProtein += dayData['meals']['breakfast']['protein'] ?? 0;
        dailyCarbs += dayData['meals']['breakfast']['carbs'] ?? 0;
        dailyFat += dayData['meals']['breakfast']['fat'] ?? 0;
        dailyWater += dayData['meals']['breakfast']['water'] ?? 0;
      }

      // Lunch
      if (!(dayData['meals']['lunch']['eat'] ?? true)) {
        dailyCalories += dayData['meals']['lunch']['calories'] ?? 0;
        dailyProtein += dayData['meals']['lunch']['protein'] ?? 0;
        dailyCarbs += dayData['meals']['lunch']['carbs'] ?? 0;
        dailyFat += dayData['meals']['lunch']['fat'] ?? 0;
        dailyWater += dayData['meals']['lunch']['water'] ?? 0;
      }

      // Dinner
      if (!(dayData['meals']['dinner']['eat'] ?? true)) {
        dailyCalories += dayData['meals']['dinner']['calories'] ?? 0;
        dailyProtein += dayData['meals']['dinner']['protein'] ?? 0;
        dailyCarbs += dayData['meals']['dinner']['carbs'] ?? 0;
        dailyFat += dayData['meals']['dinner']['fat'] ?? 0;
        dailyWater += dayData['meals']['dinner']['water'] ?? 0;
      }
    }
  }

  void nextDay() {
    setState(() {
      if (currentDayIndex < dietProgram.length - 1) {
        currentDayIndex++;
        updateDailyValues();
      }
    });
  }

  void previousDay() {
    setState(() {
      if (currentDayIndex > 0) {
        currentDayIndex--;
        updateDailyValues();
      }
    });
  }

  String getDayInitial(String day) {
    switch (day) {
      case 'Monday':
        return 'M';
      case 'Tuesday':
        return 'T';
      case 'Wednesday':
        return 'W';
      case 'Thursday':
        return 'T';
      case 'Friday':
        return 'F';
      case 'Saturday':
        return 'S';
      case 'Sunday':
        return 'S';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage("assets/images/avatar.jpg")),
            Container(
              child: const Text("Anasayfa"),
            ),
            const Icon(
              Icons.calendar_month,
              color: Colors.white,
            )
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: !isLoading
          ? !dietProgram.isEmpty || hasDietProgram
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      // Üstteki kutu (renk geçişli)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              mainColor,
                              Colors.white,
                            ],
                            stops: const [
                              0.1,
                              0.95,
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                padding: const EdgeInsets.all(25),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: List.generate(
                                    dietProgram.length,
                                    (index) => daysScroll(index),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.grey.shade200,
                                    ),
                                    onPressed: previousDay,
                                  ),
                                  Container(
                                    child: Text(
                                      "${dailyCalories}",
                                      style: fontStyle(
                                          MediaQuery.of(context).size.width / 4,
                                          Colors.white,
                                          FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey.shade200,
                                    ),
                                    onPressed: nextDay,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: Text("Kcal",
                                  style: fontStyle(15, Colors.transparent,
                                      FontWeight.normal)),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                              color: Colors.transparent,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  proteinCarbsFat("Protein", "${dailyProtein}"),
                                  proteinCarbsFat(
                                      "Karbonhidrat", "${dailyCarbs}"),
                                  proteinCarbsFat("Yağ", "${dailyFat}"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Text("Günlük Yemek",
                                style: fontStyle(
                                    18, Colors.black, FontWeight.bold)),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.info_outline,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.transparent,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xfff2f2fd),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: dailyMeals("Meals")),
                                  Expanded(child: dailyMeals("Activity")),
                                  Expanded(child: dailyMeals("Water")),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            if (selectedMeal == "Meals")
                              Container(
                                child: isLoading
                                    ? CircularProgressIndicator()
                                    : Column(
                                        children: [
                                          meals(
                                              dietProgram[currentDayIndex]
                                                  ['meals']['breakfast'],
                                              'Kahvaltı',
                                              dietProgram,
                                              currentDayIndex),
                                          meals(
                                              dietProgram[currentDayIndex]
                                                  ['meals']['lunch'],
                                              'Öğlen Yemeği',
                                              dietProgram,
                                              currentDayIndex),
                                          meals(
                                              dietProgram[currentDayIndex]
                                                  ['meals']['dinner'],
                                              'Akşam Yemeği',
                                              dietProgram,
                                              currentDayIndex),
                                        ],
                                      ),
                              )
                            else if (selectedMeal == "Activity")
                              Container(
                                child: Column(
                                  children: [
                                    activityScreen(
                                        dietProgram[currentDayIndex]['meals']
                                            ['breakfast'],
                                        'Kahvaltı',
                                        dietProgram,
                                        currentDayIndex),
                                    activityScreen(
                                        dietProgram[currentDayIndex]['meals']
                                            ['lunch'],
                                        'Öğlen Yemeği',
                                        dietProgram,
                                        currentDayIndex),
                                    activityScreen(
                                        dietProgram[currentDayIndex]['meals']
                                            ['dinner'],
                                        'Akşam Yemeği',
                                        dietProgram,
                                        currentDayIndex),
                                    waterActivity(
                                        dietProgram[currentDayIndex]['meals']
                                            ['breakfast'],
                                        'Kahvaltı',
                                        currentDayIndex),
                                    waterActivity(
                                        dietProgram[currentDayIndex]['meals']
                                            ['lunch'],
                                        'Öğlen Yemeği',
                                        currentDayIndex),
                                    waterActivity(
                                        dietProgram[currentDayIndex]['meals']
                                            ['dinner'],
                                        'Akşam Yemeği',
                                        currentDayIndex),
                                  ],
                                ),
                              )
                            else
                              Container(
                                child: Column(
                                  children: [
                                    water(
                                        dietProgram[currentDayIndex]['meals']
                                            ['breakfast'],
                                        'Kahvaltı',
                                        currentDayIndex),
                                    water(
                                        dietProgram[currentDayIndex]['meals']
                                            ['lunch'],
                                        'Öğlen Yemeği',
                                        currentDayIndex),
                                    water(
                                        dietProgram[currentDayIndex]['meals']
                                            ['dinner'],
                                        'Akşam Yemeği',
                                        currentDayIndex),
                                  ],
                                ),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : notDietScreen()
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Container notDietScreen() {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              mainColor,
              Colors.white,
            ],
            stops: const [
              0.1,
              0.75,
            ],
          ),
        ),
        child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/avatar.jpg",
                  width: 100,
                  height: 100,
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "Diyet listeniz bulunmamaktadır :(",
                    style: fontStyle(18, mainColor, FontWeight.normal),
                  ),
                )
              ],
            )));
  }

  Column meals(Map<dynamic, dynamic> meal, String mealType, dynamic dietProgram,
      int dayss) {
    return !meal['eat']
        ? Column(
            children: [
              GestureDetector(
                onTap: () => showMealDetails(meal, mealType),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white70,
                          mainColor2,
                        ],
                        stops: const [
                          0.0,
                          2.0,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mealType,
                                style: fontStyle(
                                    15, Colors.black, FontWeight.bold),
                              ),
                              Text(
                                "${meal['calories']} kcal",
                                style: fontStyle(
                                    15, Colors.grey, FontWeight.normal),
                              ),
                            ],
                          ),
                          Container(
                              alignment: Alignment.topRight,
                              child: const Icon(Icons.more_horiz_outlined))
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              child: Row(
                            children: [
                              Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Protein :",
                                        style: fontStyle(
                                            10, Colors.grey, FontWeight.normal),
                                      ),
                                      Text(
                                        "${meal['protein']} Gram",
                                        style: fontStyle(
                                            10, Colors.black, FontWeight.bold),
                                      ),
                                    ],
                                  )),
                              const SizedBox(
                                width: 5,
                              ),
                              Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Karbonhidrat :",
                                        style: fontStyle(
                                            10, Colors.grey, FontWeight.normal),
                                      ),
                                      Text(
                                        "${meal['carbs']} Gram",
                                        style: fontStyle(
                                            10, Colors.black, FontWeight.bold),
                                      ),
                                    ],
                                  )),
                              const SizedBox(
                                width: 5,
                              ),
                              Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Yağ :",
                                        style: fontStyle(
                                            10, Colors.grey, FontWeight.normal),
                                      ),
                                      Text(
                                        "${meal['fat']} Gram",
                                        style: fontStyle(
                                            10, Colors.black, FontWeight.bold),
                                      ),
                                    ],
                                  )),
                            ],
                          )),
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Colors.white,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.add_rounded),
                                onPressed: () async {
                                  print("Ekle");
                                  print(mealType);
                                  await updateEatField(mealType.toLowerCase(),
                                      dietProgram, 1, dayss);
                                },
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              )
            ],
          )
        : Column();
  }

  Column activityScreen(Map<dynamic, dynamic> meal, String mealType,
      dynamic dietProgram, int dayss) {
    return Column(
      children: [
        if (meal['eat'] == true)
          GestureDetector(
            onTap: () => showMealDetails(meal, mealType),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white70,
                      mainColor2,
                    ],
                    stops: const [
                      0.0,
                      2.0,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mealType,
                            style: fontStyle(15, Colors.black, FontWeight.bold),
                          ),
                          Text(
                            "${meal['calories']} kcal",
                            style:
                                fontStyle(15, Colors.grey, FontWeight.normal),
                          ),
                        ],
                      ),
                      Container(
                          alignment: Alignment.topRight,
                          child: const Icon(Icons.more_horiz_outlined))
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          child: Row(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  Text(
                                    "Protein :",
                                    style: fontStyle(
                                        10, Colors.grey, FontWeight.normal),
                                  ),
                                  Text(
                                    "${meal['protein']} Gram",
                                    style: fontStyle(
                                        10, Colors.black, FontWeight.bold),
                                  ),
                                ],
                              )),
                          const SizedBox(
                            width: 5,
                          ),
                          Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  Text(
                                    "Karbonhidrat :",
                                    style: fontStyle(
                                        10, Colors.grey, FontWeight.normal),
                                  ),
                                  Text(
                                    "${meal['carbs']} Gram",
                                    style: fontStyle(
                                        10, Colors.black, FontWeight.bold),
                                  ),
                                ],
                              )),
                          const SizedBox(
                            width: 5,
                          ),
                          Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  Text(
                                    "Yağ :",
                                    style: fontStyle(
                                        10, Colors.grey, FontWeight.normal),
                                  ),
                                  Text(
                                    "${meal['fat']} Gram",
                                    style: fontStyle(
                                        10, Colors.black, FontWeight.bold),
                                  ),
                                ],
                              )),
                        ],
                      )),
                      if (meal['eat'] == false)
                        Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.white,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.add_rounded),
                              onPressed: () async {
                                print("Ekle");
                                print(mealType);
                                if (meal['eat'] == false) {
                                  print("eklenmez");
                                  await updateEatField(mealType.toLowerCase(),
                                      dietProgram, 1, dayss);
                                }
                              },
                            )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }

  Column water(Map<dynamic, dynamic> meal, String mealType, int dayss) {
    return meal['drinkWater'] == false
        ? Column(
            children: [
              GestureDetector(
                onTap: () => print("Su"),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white70,
                          mainColor2,
                        ],
                        stops: const [
                          0.0,
                          2.0,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mealType,
                                style: fontStyle(
                                    15, Colors.black, FontWeight.bold),
                              ),
                              Text(
                                "${meal['water']} Bardak",
                                style: fontStyle(15, Colors.grey.shade600,
                                    FontWeight.normal),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () async {
                              await updateDrinkWater(mealType.toLowerCase(),
                                  dietProgram, 1, dayss);
                            },
                            child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.white),
                                alignment: Alignment.topRight,
                                child: const Icon(Icons.add_outlined)),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              )
            ],
          )
        : Column();
  }

  Column waterActivity(Map<dynamic, dynamic> meal, String mealType, int dayss) {
    return Column(
      children: [
        if (meal['drinkWater'] == true)
          GestureDetector(
            onTap: () => print("Su"),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white70,
                      mainColor2,
                    ],
                    stops: const [
                      0.0,
                      2.0,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mealType,
                            style: fontStyle(15, Colors.black, FontWeight.bold),
                          ),
                          Text(
                            "${meal['water']} Bardak Su",
                            style: fontStyle(
                                15, Colors.grey.shade600, FontWeight.normal),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () async {
                          print("su zaten içildi");
                        },
                        child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white),
                            alignment: Alignment.topRight,
                            child: const Icon(Icons.add_outlined)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(
          height: 15,
        )
      ],
    );
  }

  InkWell dailyMeals(String x) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedMeal = x; // Set the selected button
        });
      },
      child: Container(
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selectedMeal == x ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            x,
            style: fontStyle(15, Colors.black, FontWeight.normal),
          ),
        ),
      ),
    );
  }

  Container proteinCarbsFat(String x, String y) {
    double maxWidth =
        MediaQuery.of(context).size.width / 3 - 20; // Adjust padding as needed

    return Container(
      width: maxWidth,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xfff2f2fd),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            x,
            style: fontStyle(12, Colors.black, FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            "$y Gram",
            style: fontStyle(12, Colors.grey.shade600, FontWeight.normal),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Row daysScroll(int index) {
    var dayData = dietProgram[index];
    String dayInitial = getDayInitial(dayData['day']);
    String dayNumber = (index + 1).toString();

    return Row(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              currentDayIndex = index;
              updateDailyValues();
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
                color:
                    currentDayIndex == index ? mainColor2 : Colors.transparent),
            child: Column(
              children: [
                Text(
                  dayInitial,
                  style: fontStyle(14, Colors.white, FontWeight.bold),
                ),
                Text(
                  dayNumber,
                  style: fontStyle(14, Colors.white, FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        )
      ],
    );
  }

  void showMealDetails(Map<dynamic, dynamic> meal, String mealType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$mealType Detayları'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Kalori: ${meal['calories']} kcal'),
              Text('Protein: ${meal['protein']} Gram'),
              Text('Karbonhidrat: ${meal['carbs']} Gram'),
              Text('Yağ: ${meal['fat']} Gram'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
