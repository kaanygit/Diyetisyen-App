// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

class AuthServices {
  static final auth = FirebaseAuth.instance;
  static final firestore = FirebaseFirestore.instance;

  static createUser(
    BuildContext context,
    String name,
    String email,
    String pass,
  ) async {
    context.loaderOverlay.show();
    try {
      // Kullanıcıyı Firebase Authentication'a kaydet
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      await userCredential.user?.updateDisplayName(name);

      // Kullanıcı bilgilerini Firestore'a kaydet
      await firestore.collection('users').doc(userCredential.user?.uid).update({
        'name': name,
        'email': email,
      });

      // İşlem başarılı olduğunda, kayıt ekranından çık
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showMsg(context, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showMsg(context, 'The account already exists for that email.');
      } else {
        showMsg(context, e.message.toString());
      }
    } catch (e) {
      showMsg(context,
          'An error occurred while creating the user: ${e.toString()}');

      // Eğer Firestore'a kaydetme başarısız olursa, kullanıcıyı Firebase Authentication'dan sil
      final user = auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } finally {
      context.loaderOverlay.hide();
    }
  }

  static login(BuildContext context, String email, String pass) async {
    context.loaderOverlay.show();
    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        showMsg(context, 'Invalid Email & Password');
      } else {
        showMsg(context, e.message.toString());
      }
    } finally {
      context.loaderOverlay.hide();
    }
  }

  static showMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
