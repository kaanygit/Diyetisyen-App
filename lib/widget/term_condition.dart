import 'package:flutter/material.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kullanım Koşulları'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kullanım Koşulları',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Diyetisyen Uygulaması Kullanım Koşulları\n'
              'Bu uygulamayı kullanarak aşağıdaki koşulları kabul etmiş olursunuz:\n\n'
              '1. Uygulamamızın kullanımı tamamen sizin sorumluluğunuzdadır. '
              'Uygulamayı kullanarak, kullanım koşullarını kabul etmiş olursunuz.\n\n'
              '2. Bu uygulamayı kötüye kullanmayacağınızı ve diğer kullanıcıların '
              'haklarını ihlal etmeyeceğinizi kabul edersiniz.\n\n'
              '3. Uygulamadaki içeriklerin doğruluğu ve güncelliği konusunda '
              'garanti vermemekteyiz. Herhangi bir bilgiye güvenmeden önce '
              'bağımsız bir kaynaktan doğruluğunu teyit etmelisiniz.\n\n'
              '4. Bu kullanım koşulları zaman zaman güncellenebilir. Güncellemeleri '
              'görmek için lütfen periyodik olarak bu sayfayı kontrol ediniz.\n\n'
              'Bu kullanım koşulları, bu uygulamanın kullanımıyla ilgili olarak '
              'size sunulan hizmetler için geçerlidir. Uygulamamızı kullanarak, '
              'bu koşulları kabul etmiş olursunuz.',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
