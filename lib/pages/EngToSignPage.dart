import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/api_config.dart';
import 'MyBottomNav.dart';

class EngToSignPage extends StatefulWidget {
  const EngToSignPage({super.key});

  @override
  State<EngToSignPage> createState() => _EngToSignPageState();
}

class _EngToSignPageState extends State<EngToSignPage>
    with TickerProviderStateMixin {
  bool isListening = false;
  final TextEditingController _textController = TextEditingController();

  String? translatedText;
  String? gifUrl;
  bool isLoading = false;

  late AnimationController waveController;
  late AnimationController pulseController;

  int _currentIndex = 2;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterTts _flutterTts = FlutterTts();
  String? _filePath;

  final List<String> _quickSuggestions = [
    "Hello",
    "Thank You",
    "Good Morning",
    "How Are You",
    "What Is Your Name",
    "Nice To Meet You",
    "Where Is The Bathroom",
    "Help",
  ];

  @override
  void initState() {
    super.initState();

    waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.95,
      upperBound: 1.1,
    )..repeat(reverse: true);

    initRecorderAndTts();
  }

  Future<void> initRecorderAndTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);

    if (await Permission.microphone.request().isGranted) {
      await _recorder.openRecorder();
      _recorder.setSubscriptionDuration(const Duration(milliseconds: 50));
    } else {
      Fluttertoast.showToast(msg: "Microphone permission required for voice translation");
    }
  }

  Future<void> _speakText(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    }
  }

  @override
  void dispose() {
    waveController.dispose();
    pulseController.dispose();
    _recorder.closeRecorder();
    _flutterTts.stop();
    _textController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/text_translation');
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/sign_to_english');
        break;
    }
  }

  Future<void> startRecording() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      Fluttertoast.showToast(msg: "Microphone permission denied");
      return;
    }

    try {
      Directory tempDir = await getTemporaryDirectory();
      _filePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.wav';
      await _recorder.startRecorder(
        toFile: _filePath,
        codec: Codec.pcm16WAV,
      );
      setState(() => isListening = true);
    } catch (e) {
      Fluttertoast.showToast(msg: "Recording error: $e");
    }
  }

  Future<void> stopRecordingAndTranslate() async {
    if (!_recorder.isRecording) return;
    try {
      await _recorder.stopRecorder();
      setState(() => isListening = false);
      if (_filePath != null) {
        await sendVoiceToServer(_filePath!);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error stopping recorder: $e");
    }
  }

  Future<void> sendVoiceToServer(String path) async {
    setState(() {
      isLoading = true;
      gifUrl = null;
      translatedText = null;
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(ApiConfig.voiceToIslUrl));
      request.files.add(await http.MultipartFile.fromPath('file', path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if ((data["status"] == "gif" || data["status"] == "letters") &&
            data["path"] != null) {
          final textResult = data["recognized_text"] ?? "";
          setState(() {
            translatedText = textResult;
            gifUrl = "${ApiConfig.baseUrl}/${data["path"]}";
          });
          _speakText(textResult);
        } else {
          Fluttertoast.showToast(msg: data["message"] ?? "Translation not found");
        }
      } else {
        Fluttertoast.showToast(msg: "Translation failed (${response.statusCode})");
      }
    } catch (e) {
      if (mounted) Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> translateText([String? customText]) async {
    final textToTranslate = customText ?? _textController.text.trim();
    if (textToTranslate.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter or speak a phrase");
      return;
    }

    setState(() {
      isLoading = true;
      translatedText = null;
      gifUrl = null;
    });

    try {
      final url = Uri.parse(ApiConfig.textToIslUrl);
      final response = await http.post(
        url,
        body: {'text': textToTranslate},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if ((data["status"] == "gif" || data["status"] == "letters") &&
            data["path"] != null) {
          setState(() {
            translatedText = textToTranslate;
            gifUrl = "${ApiConfig.baseUrl}/${data["path"]}";
          });
          _speakText(textToTranslate);
        } else {
          Fluttertoast.showToast(msg: data["message"] ?? "Translation error");
        }
      } else {
        Fluttertoast.showToast(msg: "Translation failed (${response.statusCode})");
      }
    } catch (e) {
      if (mounted) Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.translate, color: Colors.tealAccent, size: 24),
            SizedBox(width: 8),
            Text(
              "English → Sign Studio",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 600 : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade800, Colors.teal.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Voice & Text to Sign Language",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Type any English sentence or tap the microphone to generate instant ISL sign animations & voice messages.",
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _quickSuggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _quickSuggestions[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ActionChip(
                            backgroundColor: const Color(0xFF1E293B),
                            side: BorderSide(color: Colors.teal.withValues(alpha: 0.3)),
                            label: Text(
                              suggestion,
                              style: const TextStyle(color: Colors.tealAccent, fontSize: 12),
                            ),
                            onPressed: () {
                              _textController.text = suggestion;
                              translateText(suggestion);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  isListening ? _buildListeningView() : _buildInputView(),

                  const SizedBox(height: 24),

                  if (isLoading)
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.tealAccent),
                            SizedBox(height: 16),
                            Text(
                              "Generating Sign Language Animation...",
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (gifUrl != null)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.teal.withValues(alpha: 0.4), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade900,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "ISL Animation Output",
                                  style: TextStyle(
                                    color: Colors.tealAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.volume_up, color: Colors.tealAccent),
                                    onPressed: () {
                                      if (translatedText != null) {
                                        _speakText(translatedText!);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh, color: Colors.tealAccent),
                                    onPressed: () => translateText(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 220,
                              width: double.infinity,
                              color: Colors.white,
                              child: Image.network(
                                gifUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stack) => const Center(
                                  child: Text(
                                    "Unable to load sign animation",
                                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "\"$translatedText\"",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.volume_up, color: Colors.tealAccent, size: 20),
                                onPressed: () {
                                  if (translatedText != null) {
                                    _speakText(translatedText!);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNav(currentIndex: _currentIndex, onTap: _onNavTapped),
    );
  }

  Widget _buildInputView() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          padding: const EdgeInsets.all(6),
          child: TextField(
            controller: _textController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Enter text or tap mic to speak...",
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
              suffixIcon: CircleAvatar(
                backgroundColor: Colors.teal,
                child: IconButton(
                  icon: const Icon(Icons.mic, color: Colors.white),
                  onPressed: startRecording,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              shadowColor: Colors.teal.withValues(alpha: 0.4),
            ),
            onPressed: isLoading ? null : () => translateText(),
            icon: const Icon(Icons.auto_awesome),
            label: const Text(
              "Translate to ISL Sign",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListeningView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: LiveWavePainter(waveController.value),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Listening to Voice...",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Speak your English sentence clearly",
            style: TextStyle(fontSize: 13, color: Colors.white60),
          ),
          const SizedBox(height: 24),
          ScaleTransition(
            scale: pulseController,
            child: GestureDetector(
              onTap: stopRecordingAndTranslate,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.stop,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LiveWavePainter extends CustomPainter {
  final double animationValue;
  LiveWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.tealAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final midHeight = height / 2;

    path.moveTo(0, midHeight);

    for (double i = 0; i <= width; i++) {
      double sine = math.sin((i / width * 4 * math.pi) + (animationValue * 2 * math.pi));
      path.lineTo(i, midHeight + sine * 20);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LiveWavePainter oldDelegate) => true;
}
