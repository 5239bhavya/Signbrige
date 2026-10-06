import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'AboutUsPage.dart';
import 'MyBottomNav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int engToSignUsage = 0;
  int signToEngUsage = 0;

  DateTime? lastBackPressTime;
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _mainFeatures = [
    {
      "icon": Icons.camera_front,
      "title": "Sign → English",
      "subtitle": "Live Camera Vision AI",
      "route": "/sign_to_english",
      "color": Colors.teal,
    },
    {
      "icon": Icons.translate,
      "title": "English → Sign",
      "subtitle": "Voice & Text Animation",
      "route": "/eng_to_sign",
      "color": Colors.indigo,
    },
    {
      "icon": Icons.text_fields,
      "title": "Text Translator",
      "subtitle": "Multilingual Workbench",
      "route": "/text_translation",
      "color": Colors.purple,
    },
    {
      "icon": Icons.menu_book,
      "title": "ISL Dictionary",
      "subtitle": "Visual Word Library",
      "route": "/dictionary",
      "color": Colors.amber,
    },
  ];

  void _onBottomNavTap(int index) async {
    if (index == _currentIndex) return;
    await HapticFeedback.selectionClick();
    if (!mounted) return;
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacementNamed(context, "/youtube");
        break;
      case 2:
        Navigator.pushReplacementNamed(context, "/dictionary");
        break;
      case 3:
        Navigator.pushReplacementNamed(context, "/user");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        DateTime now = DateTime.now();

        if (lastBackPressTime == null ||
            now.difference(lastBackPressTime!) > const Duration(seconds: 2)) {
          lastBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Press back again to exit")),
          );
          await HapticFeedback.lightImpact();
        } else {
          lastBackPressTime = null;
          if (!context.mounted) return;
          bool? exit = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text("Exit SignBridge"),
                content: const Text("Are you sure you want to exit?"),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await HapticFeedback.selectionClick();
                      if (!dialogContext.mounted) return;
                      Navigator.of(dialogContext).pop(false);
                    },
                    child: const Text("No"),
                  ),
                  TextButton(
                    onPressed: () async {
                      await HapticFeedback.mediumImpact();
                      if (!dialogContext.mounted) return;
                      Navigator.of(dialogContext).pop(true);
                    },
                    child: const Text("Yes", style: TextStyle(color: Colors.red)),
                  ),
                ],
              );
            },
          );
          if (exit == true) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: const Color(0xFF0F172A),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade900.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.4)),
                          ),
                          child: const Icon(Icons.sign_language, size: 28, color: Colors.tealAccent),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "SignBridge AI",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              "Communication Hub",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.tealAccent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white70, size: 26),
                      onPressed: () async {
                        await HapticFeedback.selectionClick();
                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AboutUsPage()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Hero Banner
                GestureDetector(
                  onTap: () async {
                    await HapticFeedback.selectionClick();
                    if (!mounted) return;
                    Navigator.pushNamed(context, "/sign_to_english");
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade700, const Color(0xFF0F766E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  "LIVE AI TRANSLATOR",
                                  style: TextStyle(
                                    color: Colors.tealAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Camera Sign Language Translation",
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Show ISL signs to your camera for instant full sentence translation.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.videocam, color: Colors.teal, size: 30),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                const Text(
                  "Core Translation Tools",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),

                // 2x2 Feature Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _mainFeatures.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.15,
                  ),
                  itemBuilder: (context, index) {
                    final item = _mainFeatures[index];
                    final Color color = item["color"] as Color;

                    return GestureDetector(
                      onTap: () async {
                        await HapticFeedback.selectionClick();
                        if (!mounted) return;
                        final String route = item["route"] as String;
                        Navigator.pushNamed(context, route);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color.withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(item["icon"] as IconData, color: color, size: 26),
                            ),
                            const Spacer(),
                            Text(
                              item["title"] as String,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item["subtitle"] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Accessible Store Hub Banner
                GestureDetector(
                  onTap: () async {
                    await HapticFeedback.selectionClick();
                    if (!mounted) return;
                    Navigator.pushNamed(context, "/ecommerce_store");
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade900.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shopping_bag_outlined, color: Colors.amberAccent, size: 26),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Accessible Store & Assistive Tools",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Hearing aids, canes & braille tools",
                                style: TextStyle(fontSize: 12, color: Colors.white60),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 80),
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
