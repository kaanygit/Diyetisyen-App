import 'package:flutter/material.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({Key? key}) : super(key: key);

  @override
  _PrivacyPageState createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  bool _isAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gizlilik Politikası'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gizlilik Politikası',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Bu uygulama, kullanıcıların gizliliğini önemsemektedir. '
              'Verilerinizin nasıl toplandığı, kullanıldığı ve paylaşıldığı '
              'hakkında bilgi edinmek için lütfen gizlilik politikamızı '
              'okuyunuz.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Checkbox(
                  value: _isAccepted,
                  onChanged: (value) {
                    setState(() {
                      _isAccepted = value!;
                    });
                  },
                ),
                Text('Gizlilik politikasını kabul ediyorum.'),
              ],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _isAccepted
                  ? () {
                      // Gizlilik politikasını kabul ettiğinde yapılacak işlemler
                    }
                  : null,
              child: Text('Devam Et'),
            ),
          ],
        ),
      ),
    );
  }
}
