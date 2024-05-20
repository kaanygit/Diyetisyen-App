import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/database/firebase.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedMeal = "Meals"; // State variable to track the selected button

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseOperations().getProfileType();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage("assets/images/avatar.jpg")),
            Container(
              child: Text("Home"),
            ),
            Icon(
              Icons.calendar_month,
              color: Colors.white,
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Üstteki kutu (renk geçişli)
            Container(
              // height: MediaQuery.of(context).size.height *
              // 0.4, // Yüksekliği ayarlayabilirsiniz
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    mainColor,
                    Colors.white,
                  ],
                  stops: [
                    0.1,
                    0.75,
                  ],
                ),
              ),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: EdgeInsets.all(25),
                      child: Row(
                        // tüm satırı kaplasınlar
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          daysScroll("w", "25"),
                          daysScroll("w", "25"),
                          daysScroll("w", "25"),
                          daysScroll("w", "25"),
                          daysScroll("w", "25"),
                          daysScroll("w", "25"),
                          daysScroll("w", "25"),
                          daysScroll("w", "25"),
                          daysScroll("w", "25"),
                          daysScroll("w", "25"),
                          daysScroll("w", "25"),
                          daysScroll("w", "25"),
                          daysScroll("w", "25"),
                          daysScroll("w", "25"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          color: Colors.grey.shade200,
                        ),
                        Container(
                          child: Text(
                            "1286",
                            style: fontStyle(
                                MediaQuery.of(context).size.width / 4,
                                Colors.white,
                                FontWeight.bold),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey.shade200,
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(
                  //   height: 15,
                  // ),
                  Container(
                    alignment: Alignment.center,
                    child: Text("Kcal",
                        style: fontStyle(15, Colors.white, FontWeight.normal)),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        proteinCarbsFat("Protein", "32"),
                        proteinCarbsFat("Carbs", "44"),
                        proteinCarbsFat("Fat", "28"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Alttaki kutu (renk geçişsiz)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          "Daily meals",
                          style: fontStyle(20, Colors.black, FontWeight.bold),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.info_outline,
                          color: Colors.grey.shade700,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        Expanded(child: dailyMeals("Meals")),
                        Expanded(child: dailyMeals("Activity")),
                        Expanded(child: dailyMeals("Water")),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  if (selectedMeal == "Meals")
                    Container(
                      child: Column(
                        children: [
                          // her bir
                          meals(),
                          meals(),
                          meals(),
                        ],
                      ),
                    )
                  else if (selectedMeal == "Activity")
                    Container(
                      child: Text("Activity"),
                    )
                  else
                    Container(
                      child: Text("Water"),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column meals() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white70,
                  mainColor2,
                ],
                stops: [
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
                        "Breakfast",
                        style: fontStyle(15, Colors.black, FontWeight.bold),
                      ),
                      Text(
                        "421 kcal",
                        style: fontStyle(15, Colors.grey, FontWeight.normal),
                      ),
                    ],
                  ),
                  Container(
                      alignment: Alignment.topRight,
                      child: Icon(Icons.more_horiz_outlined))
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      child: Row(
                    children: [
                      Container(
                          padding: EdgeInsets.all(5),
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
                                "84%",
                                style: fontStyle(
                                    10, Colors.black, FontWeight.bold),
                              ),
                            ],
                          )),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              Text(
                                "Carbs :",
                                style: fontStyle(
                                    10, Colors.grey, FontWeight.normal),
                              ),
                              Text(
                                "42%",
                                style: fontStyle(
                                    10, Colors.black, FontWeight.bold),
                              ),
                            ],
                          )),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              Text(
                                "Fat :",
                                style: fontStyle(
                                    10, Colors.grey, FontWeight.normal),
                              ),
                              Text(
                                "10%",
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
                        icon: Icon(Icons.add_rounded),
                        onPressed: () {
                          print("Ekle");
                        },
                      )),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
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
        margin: EdgeInsets.all(3),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selectedMeal == x ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            "$x",
            style: fontStyle(15, Colors.black, FontWeight.normal),
          ),
        ),
      ),
    );
  }

  Container proteinCarbsFat(String x, String y) {
    // Calculate the maximum width based on the longest label ("Protein", "Carbs", "Fat")
    double maxWidth =
        MediaQuery.of(context).size.width / 3 - 32; // Adjust padding as needed

    return Container(
      width: maxWidth,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xfff2f2fd),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            x,
            style: fontStyle(15, Colors.black, FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Text(
            "$y%",
            style: fontStyle(15, Colors.grey.shade600, FontWeight.normal),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Row daysScroll(String x, String y) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            print("Şu güne gidildi");
          },
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                color: Colors.transparent),
            child: Column(
              children: [
                Text(
                  x,
                  style: fontStyle(14, Colors.white, FontWeight.bold),
                ),
                Text(
                  y,
                  style: fontStyle(14, Colors.white, FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 10,
        )
      ],
    );
  }
}
