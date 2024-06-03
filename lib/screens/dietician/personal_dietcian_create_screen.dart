import 'package:flutter/material.dart';

class PersonalDietcianCreateScreen extends StatefulWidget {
  final String userUid;
  const PersonalDietcianCreateScreen({required this.userUid,Key? key}) : super(key: key);

  @override
  State<PersonalDietcianCreateScreen> createState() => _PersonalDietcianCreateScreenState();
}

class _PersonalDietcianCreateScreenState extends State<PersonalDietcianCreateScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.userUid);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kişisel Diyetisyen Oluştur'),
      ),
      body: const Center(
        child: Text('Kişisel Diyetisyen Oluştur Ekranı'),
      ),
    );
  }
}
