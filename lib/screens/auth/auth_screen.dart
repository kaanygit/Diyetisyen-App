import 'package:diyetisyenapp/constants/fonts.dart';
import 'package:diyetisyenapp/database/firebase.dart';
import 'package:diyetisyenapp/screens/admin/admin_home_screen.dart';
import 'package:diyetisyenapp/screens/auth/user_information_screen.dart';
import 'package:diyetisyenapp/screens/dietician/dietician_home_screen.dart';
import 'package:diyetisyenapp/screens/user/home.dart';
import 'package:diyetisyenapp/widget/flash_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sign_button/sign_button.dart';
import 'package:diyetisyenapp/constants/fonts.dart';

class AuthScreenState extends StatelessWidget {
  const AuthScreenState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AuthScreen();
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseOperations _firebaseOperations = FirebaseOperations();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  late bool loginPageController = false;
  late bool startLoginPageController = false;
  String _selectedOption = 'Kullanıcı';
  int _selectedOptionNumber = 0;
  late int _loginPageSelectionType = 0;

  @override
  void dispose() {
    // Firebase işlemlerini temizle
    // _firebaseOperations.dispose();
    super.dispose();
  }

  final OutlineInputBorder _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.0),
    borderSide: const BorderSide(color: Colors.grey),
  );

  Future<void> _signUpWithEmailAndPassword() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String name = _nameController.text;

    // Password length validation
    if (password.length < 6) {
      showErrorSnackBar(context, "Şifre en az 6 karakter olmalıdır.");
      return;
    }

    // Password match validation
    if (password != confirmPassword) {
      showErrorSnackBar(context, "Şifreler eşleşmiyor. Lütfen tekrar deneyin.");
      return;
    }

    // Email and password are not empty
    if (email.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty) {
      if (_selectedOption == "Kullanıcı") {
        setState(() {
          _selectedOptionNumber = 0;
        });
      } else if (_selectedOption == "Diyetisyen") {
        setState(() {
          _selectedOptionNumber = 1;
        });
      } else {
        setState(() {
          _selectedOptionNumber = 2;
        });
      }
      UserCredential? userCredential =
          await _firebaseOperations.signUpWithEmailAndPassword(
              context, email, password, name, _selectedOptionNumber);
      if (userCredential != null && mounted) {
        // Check if the state is still mounted
        print("Kayıt başarılı: ${userCredential.user?.email}");
        int profileType = await FirebaseOperations().getProfileType();

        // Profil tipine göre yönlendirme yap
        switch (profileType) {
          case 0:
            print("Navigating to HomeScreen for profile type 0");
            Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.fade, child: new UserInformationScreen()),
            );
            break;
          case 1:
            print("Navigating to DieticianHomeScreen for profile type 1");
            Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.fade,
                  child: new DieticianHomeScreen()),
            );
            break;
          case 2:
            print("Navigating to AdminHomeScreen for profile type 2");
            Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.fade, child: new AdminHomeScreen()),
            );
            break;
          default:
            print("Unknown profile type: $profileType");
            showErrorSnackBar(context, "Tanımsız kullanıcı tipi: $profileType");
            break;
        }
      } else {
        // Show error message
        if (mounted) {
          // Check if the state is still mounted before showing the error message
          showErrorSnackBar(context, "Kayıt başarısız. Lütfen tekrar deneyin.");
        }
      }
    } else {
      // Show error message if email or password is empty
      if (mounted) {
        // Check if the state is still mounted before showing the error message
        showErrorSnackBar(context, "E-posta ve şifre gerekli");
      }
    }
  }

  Future<void> _signInEmailAndPassword() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    // E-posta ve şifre geçerli mi kontrol et
    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        // Firebase kimlik doğrulaması
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );


        // Giriş başarılı, kullanıcıyı yönlendir veya gerekli işlemleri yap
        print("Giriş başarılı: ${userCredential.user?.email}");
     
        int profileType = await FirebaseOperations().getProfileType();

      // Profil tipine göre yönlendirme yap
        print("SİGN İN GELİYOR : $profileType");
        switch (profileType) {
          case 0:
            print("Navigating to HomeScreen for profile type 0");
            Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.fade, child: new HomeScreen()),
            );
            break;
          case 1:
            print("Navigating to DieticianHomeScreen for profile type 1");
            Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.fade,
                  child: new DieticianHomeScreen()),
            );
            break;
          case 2:
            print("Navigating to AdminHomeScreen for profile type 2");
            Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.fade, child: new AdminHomeScreen()),
            );
            break;
          default:
            print("Unknown profile type: $profileType");
            showErrorSnackBar(context, "Tanımsız kullanıcı tipi: $profileType");
            break;
        }     

      } catch (e) {
        // Giriş başarısız, hata mesajını göster
        print("Giriş başarısız: $e");
        showErrorSnackBar(
            context, "Giriş başarısız. Lütfen bilgilerinizi kontrol edin.");
      }
    } else {
      // E-posta veya şifre boşsa hata mesajını göster
      showErrorSnackBar(context, "E-posta ve şifre gerekli");
    }
  }

  Future<void> _signInWithGoogle() async {
    bool result = await _firebaseOperations.signInWithGoogle();
    if (result) {
      Navigator.push(
        context,
        PageTransition(type: PageTransitionType.fade, child: UserInformationScreen()),
      );
    } else {
      showErrorSnackBar(
          context, "Giriş başarısız oldu. Lütfen daha sonra tekrar deneyiniz");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: startLoginPageController
          ? loginPageController
              ? signUpScreen()
              : signInScreen()
          : startLoginPageScreen(),
    );
  }

  Container startLoginPageScreen() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/food_background.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                Text(
                  "DiyetisyenApp",
                  style: fontStyle(50, Colors.white, FontWeight.bold),
                ),
                const Spacer(),
              ],
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                startButtons("Admin"),
                startButtons("Diyetisyen"),
                startButtons("Kullanıcı"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget startButtons(String text) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:  mainColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          print("Start App");
          setState(() {
            startLoginPageController = true;
            if (text == "Admin") {
              setState(() {
                _loginPageSelectionType = 2;
              });
            } else if (text == "Diyetisyen") {
              setState(() {
                _loginPageSelectionType = 1;
              });
            } else {
              setState(() {
                _loginPageSelectionType = 0;
              });
            }
            print(_loginPageSelectionType);
          });
        },
        child: Text(
          text,
          style: fontStyle(25, Colors.white, FontWeight.normal),
        ),
      ),
    );
  }

  Center signInScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(child: Text("DiyetisyenApp",
              style:fontStyle(25,mainColor,FontWeight.bold))
                  //  Image.asset(
                  //   "assets/images/icon.png",
                  //   width: 250,
                  //   height: 250,
                  // ),
                  ),
              const SizedBox(height: 30),
              TextField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "E-posta",
                  border: _border,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.visiblePassword,
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Şifre",
                  border: _border,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _signInEmailAndPassword,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          "Giriş Yap",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              const Row(
                children: [
                  Expanded(
                    child: Divider(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("veya"),
                  ),
                  Expanded(
                    child: Divider(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: SignInButton(
                    buttonType: ButtonType.google,
                    buttonSize: ButtonSize.medium,
                    onPressed: _signInWithGoogle,
                    btnText: "Google ile Giriş Yap",
                  )),
                ],
              ),
              const SizedBox(height: 16),
              if (_loginPageSelectionType != 2)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Hesabın Yokmu ? "),
                    TextButton(
                      onPressed: () {
                        print("Login In");
                        setState(() {
                          loginPageController = !loginPageController;
                        });
                      },
                      child: const Text(
                        "Üye ol",
                        style: TextStyle(color: Colors.lightGreen),
                      ),
                    )
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  Center signUpScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(child:  Text("DiyetisyenApp",
              style:fontStyle(25,mainColor,FontWeight.bold))
                  //  Image.asset(
                  //   "assets/images/icon.png",
                  //   width: 250,
                  //   height: 250,
                  // ),
                  ),
              const SizedBox(height: 24),
              TextField(
                keyboardType: TextInputType.multiline,
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "İsim",
                  border: _border,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "E-posta",
                  border: _border,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.visiblePassword,
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Şifre",
                  border: _border,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.visiblePassword,
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Şifre Doğrulama",
                  border: _border,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedOption,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedOption = newValue!;
                    });
                  },
                  items: <String>['Kullanıcı', 'Diyetisyen', 'Admin']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _signUpWithEmailAndPassword,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            "Üye Ol",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              const Row(
                children: [
                  Expanded(
                    child: Divider(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("veya"),
                  ),
                  Expanded(
                    child: Divider(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: SignInButton(
                    buttonType: ButtonType.google,
                    buttonSize: ButtonSize.medium,
                    onPressed: _signInWithGoogle,
                    btnText: "Google ile Giriş Yap",
                  )),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Hesabın Varmı ? "),
                  TextButton(
                    onPressed: () {
                      print("Login In");
                      setState(() {
                        loginPageController = !loginPageController;
                      });
                    },
                    child: const Text(
                      "Giriş Yap",
                      style: TextStyle(color: Colors.lightGreen),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
