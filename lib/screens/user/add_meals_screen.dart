import 'package:flutter/material.dart';

class AddMeals extends StatefulWidget {
  const AddMeals({super.key});

  @override
  State<AddMeals> createState() => _AddMealsState();
}

class _AddMealsState extends State<AddMeals> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _meals = [
    {'name': 'Elma', 'image': 'assets/apple.png'},
    {'name': 'Pilav', 'image': 'assets/rice.jpg'},
    // Diğer yemekleri burada ekleyin
  ];
  List<Map<String, dynamic>> _filteredMeals = [];
  bool _showAiBox = true;

  @override
  void initState() {
    super.initState();
    _filteredMeals = _meals;
  }

  void _filterMeals(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredMeals = _meals;
        _showAiBox = true;
      });
    } else {
      setState(() {
        _filteredMeals = _meals
            .where((meal) => meal['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
        _showAiBox = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Meals'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _filterMeals,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            if (_showAiBox) _buildAiBox(),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _filteredMeals.length,
                itemBuilder: (context, index) {
                  final meal = _filteredMeals[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MealDetailScreen(meal: meal),
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.asset(
                              meal['image'],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(meal['name']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            Icon(Icons.camera, size: 50, color: Colors.blue),
            SizedBox(width: 16),
            Expanded(
              child: Text('Yapay Zeka ile Yiyecek Tanıma'),
            ),
            ElevatedButton(
              onPressed: () {
                // Kamera açma işlemi buraya gelecek
              },
              child: Text('Başlat'),
            ),
          ],
        ),
      ),
    );
  }
}

class MealDetailScreen extends StatelessWidget {
  final Map<String, dynamic> meal;

  const MealDetailScreen({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(meal['image']),
            SizedBox(height: 16),
            Text(
              'Kalori: 100 kcal', // Gerçek verilere göre güncelleyin
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Yağ: 0.5 g', // Gerçek verilere göre güncelleyin
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Karbonhidrat: 25 g', // Gerçek verilere göre güncelleyin
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Protein: 0.5 g', // Gerçek verilere göre güncelleyin
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Yemeği yendi olarak işaretleme işlemi buraya gelecek
              },
              child: Text('Yemeği Yedim'),
            ),
          ],
        ),
      ),
    );
  }
}
