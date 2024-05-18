import 'package:diyetisyenapp/pages/register_page.dart';
import 'package:diyetisyenapp/services/auth_services.dart';
import 'package:diyetisyenapp/widgets/app_button.dart';
import 'package:diyetisyenapp/widgets/custom_textfield.dart';
import 'package:diyetisyenapp/widgets/top_title.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TopTitle(
                  title: 'Login',
                  subTitle: 'Welcome back',
                ),
                CustomTextField(
                  controller: emailController,
                  name: 'Email',
                  prefixIcon: Icons.mail_outline,
                  inputType: TextInputType.emailAddress,
                ),
                CustomTextField(
                  controller: passController,
                  name: 'Password',
                  prefixIcon: Icons.lock_outline,
                  inputType: TextInputType.text,
                  obscureText: true,
                ),
                AppButton(
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      AuthServices.login(
                        context,
                        emailController.text,
                        passController.text,
                      );
                    }
                  },
                  text: "Login",
                ),
                const SizedBox(height: 30),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterPage()),
                    ),
                    child: const Text("Register"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
