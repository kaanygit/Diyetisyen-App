import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      body: Column(
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
                  1.0,
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
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 16),
              padding: EdgeInsets.all(16),
              color: Colors.transparent,
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
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        dailyMeals("Meals"),
                        dailyMeals("Activity"),
                        dailyMeals("Water"),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InkWell dailyMeals(String x) {
    return InkWell(
      onTap: () {
        print("Bastınız");
      },
      child: Expanded(
        child: Container(
          margin: EdgeInsets.all(3),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              "$x",
              style: fontStyle(15, Colors.black, FontWeight.normal),
            ),
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
