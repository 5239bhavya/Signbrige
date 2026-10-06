import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'MyBottomNav.dart';

class TextTranslationPage extends StatefulWidget {
  const TextTranslationPage({super.key});

  @override
  State<TextTranslationPage> createState() => _TextTranslationPageState();
}

class _TextTranslationPageState extends State<TextTranslationPage> {
  final TextEditingController _inputController = TextEditingController();
  String _translatedResult = "";
  String _inputLang = "English";
  String _outputLang = "American Sign Language (ASL)";

  Future<void> _navigate(String route) async {
    await HapticFeedback.selectionClick();
    if (!mounted) return;
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  void _performTranslation(String text) {
    if (text.trim().isEmpty) {
      setState(() => _translatedResult = "");
      return;
    }
    setState(() {
      _translatedResult = "ISL Sign Output: ${text.trim().toUpperCase()}";
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWideScreen = width > 600;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD6EAFF), Color(0xFFFDEBDC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Text Translation",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: isWideScreen ? 600 : 400),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withValues(alpha: 0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DropdownButtonFormField<String>(
                                initialValue: _inputLang,
                                items: const [
                                  DropdownMenuItem(value: "English", child: Text("English")),
                                  DropdownMenuItem(value: "Spanish", child: Text("Spanish")),
                                  DropdownMenuItem(value: "French", child: Text("French")),
                                ],
                                onChanged: (value) async {
                                  await HapticFeedback.selectionClick();
                                  if (value != null) {
                                    setState(() => _inputLang = value);
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: "Input Language",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _inputController,
                                maxLines: 4,
                                onChanged: _performTranslation,
                                decoration: InputDecoration(
                                  hintText: "Enter text to translate...",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.purple.withValues(alpha: 0.25),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.compare_arrows, size: 28, color: Colors.white),
                                    onPressed: () async {
                                      await HapticFeedback.selectionClick();
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              DropdownButtonFormField<String>(
                                initialValue: _outputLang,
                                items: const [
                                  DropdownMenuItem(
                                      value: "American Sign Language (ASL)",
                                      child: Text("American Sign Language (ASL)")),
                                  DropdownMenuItem(
                                      value: "Indian Sign Language (ISL)",
                                      child: Text("Indian Sign Language (ISL)")),
                                  DropdownMenuItem(
                                      value: "British Sign Language (BSL)",
                                      child: Text("British Sign Language (BSL)")),
                                ],
                                onChanged: (value) async {
                                  await HapticFeedback.selectionClick();
                                  if (value != null) {
                                    setState(() => _outputLang = value);
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: "Output Language",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                constraints: const BoxConstraints(minHeight: 120),
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.teal.shade200),
                                ),
                                child: Text(
                                  _translatedResult.isEmpty
                                      ? "Translation will appear here..."
                                      : _translatedResult,
                                  style: TextStyle(
                                    color: _translatedResult.isEmpty
                                        ? Colors.grey.shade600
                                        : const Color(0xFF2C3E50),
                                    fontSize: 16,
                                    fontWeight: _translatedResult.isEmpty
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: MyBottomNav(
          currentIndex: 1,
          onTap: (index) {
            switch (index) {
              case 0:
                _navigate("/home");
                break;
              case 1:
                _navigate("/text_translation");
                break;
              case 2:
                _navigate("/eng_to_sign");
                break;
              case 3:
                _navigate("/sign_to_english");
                break;
            }
          },
        ),
      ),
    );
  }
}
