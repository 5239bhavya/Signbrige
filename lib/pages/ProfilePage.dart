import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/usage_tracker.dart';
import 'MyBottomNav.dart';

class ProfilePage extends StatefulWidget {
  final int engToSignUsage;
  final int signToEngUsage;

  const ProfilePage({
    super.key,
    this.engToSignUsage = 0,
    this.signToEngUsage = 0,
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
    final int engCount = widget.engToSignUsage > 0 ? widget.engToSignUsage : UsageTracker.engToSignCount;
    final int signCount = widget.signToEngUsage > 0 ? widget.signToEngUsage : UsageTracker.signToEngCount;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushReplacementNamed(context, "/home");
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          title: const Text("User Profile"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.tealAccent, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 48,
                    backgroundImage: AssetImage("assets/profile_placeholder.png"),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Bhavya Patel",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  "@Bhavyapatel • ISL Communicator",
                  style: TextStyle(fontSize: 14, color: Colors.tealAccent),
                ),
                const SizedBox(height: 30),

                // Statistics Header
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Real-Time App Analytics",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade900,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.translate, color: Colors.tealAccent),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          "English → Sign Studio Translations",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                      Text(
                        "$engCount times",
                        style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade900,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_front, color: Colors.tealAccent),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          "Sign → English Camera Scans",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                      Text(
                        "$signCount times",
                        style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
