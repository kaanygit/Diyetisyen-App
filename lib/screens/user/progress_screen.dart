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
        title: Text('Health Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildWeeklyProgressCard(),
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
              'Weekly Progress',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Calories', style: TextStyle(fontSize: 16.0)),
                    Text('1,284', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    _buildProgressCircle(29, 'Fat'),
                    SizedBox(height: 8.0),
                    _buildProgressCircle(65, 'Pro'),
                    SizedBox(height: 8.0),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest Measurements',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Weight',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              '72.4 Kg',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            Text('21% Fat Mass', style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {},
              child: Text('Track new weight'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calories',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              '1,548 Cal',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            Text(
              '89% Goal',
              style: TextStyle(color: Colors.green, fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            // Here you could add a bar chart or any other representation for the calories data
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
            Text('$percentage%'),
          ],
        ),
        SizedBox(height: 4.0),
        Text(label),
      ],
    );
  }
}