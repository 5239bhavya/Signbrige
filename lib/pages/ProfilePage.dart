import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'MyBottomNav.dart';

class ProfilePage extends StatefulWidget {
  final int engToSignUsage;
  final int signToEngUsage;

  const ProfilePage({
    super.key,
    required this.engToSignUsage,
    required this.signToEngUsage,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3;

  void _onBottomNavTap(int index) async {
    if (index == _currentIndex) return;
    await HapticFeedback.selectionClick();
    if (!mounted) return;
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, "/home");
        break;
      case 1:
        Navigator.pushReplacementNamed(context, "/youtube");
        break;
      case 2:
        Navigator.pushReplacementNamed(context, "/dictionary");
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushReplacementNamed(context, "/home");
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/profile_placeholder.png"),
              ),
              const SizedBox(height: 15),
              const Text(
                "Bhavya Patel",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "@Bhavyapatel",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.translate, color: Colors.teal),
                  title: const Text("English → Sign usage"),
                  trailing: Text("${widget.engToSignUsage} times", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.camera_front, color: Colors.teal),
                  title: const Text("Sign → English usage"),
                  trailing: Text("${widget.signToEngUsage} times", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: MyBottomNav(
          currentIndex: _currentIndex,
          onTap: _onBottomNavTap,
        ),
      ),
    );
  }
}
