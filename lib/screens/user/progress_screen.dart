import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/widget/buttons.dart';
import 'package:flutter/material.dart';

class ProgressScreenPage extends StatefulWidget {
  ProgressScreenPage({Key? key}) : super(key: key);

  @override
  _ProgressScreenPageState createState() => _ProgressScreenPageState();
}

class _ProgressScreenPageState extends State<ProgressScreenPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gelişim'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeeklyProgressCard(),
            SizedBox(height: 16.0),
            Text(
              'Son Değerleriniz',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            _buildWeightCard(),
            SizedBox(height: 16.0),
            _buildCaloriesCard(),
          ],
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
                            '1,284',
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
                    _buildProgressCircle(29, 'Fat'),
                    SizedBox(width: 10.0),
                    _buildProgressCircle(65, 'Pro'),
                    SizedBox(width: 10.0),
                    _buildProgressCircle(85, 'Carb'),
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
                    '72.4 Kg',
                    style: fontStyle(24.0, Colors.black, FontWeight.bold),
                  ),
                  Text(
                    'Hedef kilonuz : 70 Kg',
                    style: fontStyle(16.0, Colors.grey, FontWeight.normal),
                  ),
                  SizedBox(height: 20.0),
                  MyButton(
                    text: "Yeni bir kilo giriniz",
                    buttonColor: mainColor,
                    buttonTextColor: Colors.white,
                    buttonTextSize: 15,
                    buttonTextWeight: FontWeight.bold,
                    onPressed: () {},
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
                    currentWeight: 72.4, targetWeight: 70.0),
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
                    '1,548 Kcal',
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '89% Tamamlandı',
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
                painter: _CaloriesGraphPainter(),
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

class _CaloriesGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = -3.14 / 2;
    final sweepAngle = 2 * 3.14 * 0.89; // 89% completed

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class _WeightGraphPainter extends CustomPainter {
  final double currentWeight;
  final double targetWeight;

  _WeightGraphPainter(
      {required this.currentWeight, required this.targetWeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final percentage = (currentWeight / targetWeight).clamp(0.0, 1.0);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = -3.14 / 2;
    final sweepAngle = 2 * 3.14 * percentage; // current progress

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
