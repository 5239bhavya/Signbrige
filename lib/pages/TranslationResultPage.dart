import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'MyBottomNav.dart';

class TranslationResultPage extends StatelessWidget {
  const TranslationResultPage({super.key});

  Future<void> _navigate(BuildContext context, String route) async {
    await HapticFeedback.selectionClick();
    if (context.mounted && ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF4B4D4),
                    Color(0xFFD5C4E9),
                    Color(0xFFA3C1F1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Column(
              children: [
                AppBar(
                  title: const Text(
                    "Translation Result",
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.white.withValues(alpha: 0.7),
                  elevation: 0,
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 300,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              "https://m.media-amazon.com/images/I/51y5FbjexLL._AC_.jpg",
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 200,
                                color: Colors.white.withValues(alpha: 0.5),
                                child: const Center(
                                  child: Icon(Icons.sign_language, size: 60, color: Colors.teal),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Original Text:",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const Text(
                          "Hello",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF58A6FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                      ),
                      onPressed: () async {
                        await HapticFeedback.selectionClick();
                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(context, "/text_translation");
                      },
                      child: const Text(
                        "Translate Another",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: MyBottomNav(
          currentIndex: -1,
          onTap: (index) {
            switch (index) {
              case 0:
                _navigate(context, "/home");
                break;
              case 1:
                _navigate(context, "/text_translation");
                break;
              case 2:
                _navigate(context, "/eng_to_sign");
                break;
              case 3:
                _navigate(context, "/sign_to_english");
                break;
            }
          },
        ),
      ),
    );
  }
}
