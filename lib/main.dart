import 'package:flutter/material.dart';

import 'pages/Homepage.dart';
import 'pages/Loadingpage.dart';
import 'pages/EngToSignPage.dart';
import 'pages/TextTranslationPage.dart';
import 'pages/TranslationResultPage.dart';
import 'pages/SignToEnglishPage.dart';
import 'pages/SignToTextPage.dart';
import 'pages/EcommerceStorePage.dart';
import 'pages/YouTubePage.dart';
import 'pages/DictionaryPage.dart';
import 'pages/ProfilePage.dart';
import 'pages/AboutUsPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "SignBridge",
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal,
          secondary: Colors.tealAccent,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/loading',
      routes: {
        '/home': (context) => const HomePage(),
        '/loading': (context) => const Loadingpage(),
        '/eng_to_sign': (context) => const EngToSignPage(),
        '/text_translation': (context) => const TextTranslationPage(),
        '/translation_result': (context) => const TranslationResultPage(),
        '/sign_to_english': (context) => const SignToEnglishPage(),
        '/sign_to_text': (context) => const SignToTextPage(),
        '/ecommerce_store': (context) => const EcommerceStorePage(),
        '/youtube': (context) => const YoutubePage(),
        '/dictionary': (context) => const DictionaryPage(),
        '/user': (context) => const ProfilePage(engToSignUsage: 0, signToEngUsage: 0),
        '/profile': (context) => const ProfilePage(engToSignUsage: 0, signToEngUsage: 0),
        '/about_us': (context) => const AboutUsPage(),
      },
    );
  }
}
