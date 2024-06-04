import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Gemini {
  late String googleGeminiApiKey;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initializeGemini() async {
    await dotenv.load();
    googleGeminiApiKey = await getApiKey();
  }

  Future<String> getApiKey() async {
    String? apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      return "null";
    }
    return apiKey;
  }

  Future<String?> geminiTextPrompt(String userPrompt) async {
    try {
      await initializeGemini(); // googleGeminiApiKey'yi başlatmak için
      final model = GenerativeModel(
          model: 'gemini-1.5-flash', apiKey: googleGeminiApiKey);
      final prompt = TextPart(userPrompt);
      final response = await model.generateContent([Content.text(prompt.text)]);
      print("Resimsiz geldi");
      print(response.text);
      return response.text;
    } catch (e) {
      print("Error generating content: $e");
      return null;
    }
  }

  Future<String?> geminImageAndTextPrompt(
      String userPrompt, String imagePath) async {
    try {
      await initializeGemini();
      final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: "AIzaSyCmd9Vek7eccUNUJmHJrCa7jWzmBlBrNOo");
      final prompt = TextPart(userPrompt);
      final image = await File(imagePath).readAsBytes();

      final imageParts = [DataPart('image/jpeg', image)];
      final response = await model.generateContent([
        Content.multi([prompt, ...imageParts])
      ]);
      print("Gemini Image And Text Prompt");
      print(response.text);
      return response.text;
    } catch (e) {
      print("Error generating content: $e");
      return null;
    }
  }

  Future<String?> geminImageLabelingPrompt(String imagePath) async {
    try {
      await initializeGemini();
      final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: "AIzaSyCmd9Vek7eccUNUJmHJrCa7jWzmBlBrNOo");
      final prompt = TextPart(
          "Resmi analiz et hangi gıda veya yemek ise bu gıdanın veya yemeğin sadece cevap olarak söyle.Eğer yiyecek değil ise Bulunamadı cevabını yolla.Eğer yiyecek ise {name:elma,kalori: 52,protein: 0.3,yağ: 0.2,karbonhidrat: 14,} bu şekilde sadece map ögesi döndür");
      final image = await File(imagePath).readAsBytes();

      final imageParts = [DataPart('image/jpeg', image)];
      final response = await model.generateContent([
        Content.multi([prompt, ...imageParts])
      ]);
      print("Gemini Image And Text Prompt");
      print(response.text);
      return response.text;
    } catch (e) {
      print("Error generating content: $e");
      return null;
    }
  }

  Future<void> setGeminiChatFirebase(String text, String response) async {
    try {
      print("Veriler Firebaseye kaydediliyor");

      // Get the current document snapshot
      DocumentSnapshot userDoc = await _firestore
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .get();

      // Initialize the aiChats list
      List<Map<String, String>> aiChats = [];

      // Check if the document exists and has the aiChats field
      if (userDoc.exists && userDoc.data() != null) {
        var data = userDoc.data() as Map<String, dynamic>;
        if (data["aiChats"] is List) {
          // Convert the existing aiChats field to a List<Map<String, String>>
          List<dynamic> existingChats = data["aiChats"];
          aiChats = existingChats.map((chat) {
            if (chat is Map<String, dynamic>) {
              return {
                "user": chat["user"] as String? ?? "",
                "gemini": chat["gemini"] as String? ?? ""
              };
            } else {
              return {"user": "", "gemini": ""};
            }
          }).toList();
        }
      }

      // Add the new chat entry to the list
      aiChats.add({"user": text, "gemini": response});

      // Update the document with the new list
      await _firestore.collection("users").doc(_auth.currentUser!.uid).update({
        "aiChats": aiChats,
      });
    } catch (e) {
      print("Verileri firebaseye kaydederken sorun yaşandı : $e");
    }
  }
}
