import 'package:flutter/material.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({Key? key}) : super(key: key);

  @override
  _PrivacyPageState createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gizlilik Politikası'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                'Diyetisyenlik Uygulaması İçin Gizlilik Politikası',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Bu uygulama, kullanıcıların gizliliğini önemsemektedir. Verilerinizin '
                'nasıl toplandığı, kullanıldığı ve paylaşıldığı hakkında bilgi edinmek '
                'için lütfen gizlilik politikamızı okuyunuz. Diyetisyenlik uygulamamız, '
                'kişisel verilerinizi korumak için en üst düzeyde güvenlik önlemleri '
                'almaktadır. Toplanan veriler, yalnızca sizin onayınızla ve belirttiğiniz '
                'amaçlar doğrultusunda kullanılacaktır.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20.0),
              Text(
                'Toplanan Veriler:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              Text(
                '- Adınız ve Soyadınız\n'
                '- E-posta adresiniz\n'
                '- Telefon numaranız\n'
                '- Diyet bilgileriniz ve sağlık verileriniz\n'
                '- Uygulama kullanım alışkanlıklarınız',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20.0),
              Text(
                'Verilerin Kullanımı:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              Text(
                'Toplanan veriler, size daha iyi bir hizmet sunabilmek ve diyetisyenlik '
                'hizmetlerimizi geliştirebilmek amacıyla kullanılacaktır. Verileriniz '
                'üçüncü şahıslarla paylaşılmayacak olup, yalnızca uygulama içinde ve '
                'onay verdiğiniz durumlarda kullanılacaktır.',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
