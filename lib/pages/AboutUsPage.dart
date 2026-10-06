import 'package:flutter/material.dart';
import 'MyBottomNav.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  Widget build(BuildContext context) {
    final int currentIndex =
        MyBottomNav.getCurrentIndex(ModalRoute.of(context)?.settings.name);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushReplacementNamed(context, '/home');
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text("About Us"),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Center(
                child: Icon(Icons.info_outline, size: 60, color: Colors.teal),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Welcome to SignBridge",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "SignBridge is an AI-powered communication platform designed to bridge the gap between English speakers and sign language users. Our application provides tools for translating English to Sign Language, Sign Language to English, and interactive learning resources.",
                style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              ),
              const SizedBox(height: 25),
              _buildFeature(Icons.translate, "English → Sign",
                  "Convert English words and voice sentences into accurate sign language animations."),
              const SizedBox(height: 20),
              _buildFeature(Icons.camera_front, "Sign → English",
                  "Translate camera gesture signs into readable English text in real-time."),
              const SizedBox(height: 20),
              _buildFeature(Icons.text_fields, "Text Translator",
                  "Translate text between English and sign language quickly and efficiently."),
              const SizedBox(height: 25),
              const Text(
                "Our mission is to empower communication for everyone, making learning and understanding sign language easy and accessible.",
                style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              ),
            ],
          ),
        ),
        bottomNavigationBar: MyBottomNav(currentIndex: currentIndex),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.teal),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 5),
                Text(
                  desc,
                  style: const TextStyle(
                      fontSize: 15, color: Colors.black87, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
