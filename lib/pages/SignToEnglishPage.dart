import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/api_config.dart';
import '../services/offline_sign_predictor.dart';
import 'MyBottomNav.dart';

class SignToEnglishPage extends StatefulWidget {
  const SignToEnglishPage({super.key});

  @override
  State<SignToEnglishPage> createState() => _SignToEnglishPageState();
}

class _SignToEnglishPageState extends State<SignToEnglishPage>
    with TickerProviderStateMixin {
  bool isRecording = false;
  bool permissionGranted = false;
  bool _isCapturing = false;

  String sentence = "";
  String currentLetter = "";

  List<CameraDescription> cameras = [];
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  Timer? _recordTimer;
  CameraLensDirection currentLens = CameraLensDirection.front;
  late AnimationController pulseController;

  String statusMessage = "Press the video button to start sign recognition";

  String _lastDetectedSign = "";
  int _consecutiveCount = 0;

  @override
  void initState() {
    super.initState();
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);

    _requestPermissionAndSetupCamera();
  }

  Future<void> _requestPermissionAndSetupCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      if (mounted) setState(() => permissionGranted = true);
      cameras = await availableCameras();
      if (cameras.isNotEmpty) await _initializeCamera(currentLens);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission is required")),
      );
    }
  }

  Future<void> _initializeCamera(CameraLensDirection lensDirection) async {
    if (cameras.isEmpty) return;
    final camera = cameras.firstWhere(
      (cam) => cam.lensDirection == lensDirection,
      orElse: () => cameras.first,
    );

    try {
      await _cameraController?.dispose();
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      _initializeControllerFuture = _cameraController!.initialize();
      await _initializeControllerFuture;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Camera initialization error: $e");
    }
  }

  void toggleRecording() {
    if (!isRecording) {
      setState(() {
        isRecording = true;
        sentence = "";
        currentLetter = "";
        _lastDetectedSign = "";
        _consecutiveCount = 0;
        statusMessage = "Analyzing camera frames...";
      });

      _recordTimer = Timer.periodic(const Duration(milliseconds: 700), (_) async {
        if (_cameraController == null ||
            !_cameraController!.value.isInitialized ||
            _isCapturing) {
          return;
        }

        _isCapturing = true;
        final letter = await _captureAndPredict();
        if (!mounted) return;

        if (letter.isNotEmpty) {
          final cleanLetter = letter.trim();
          final lower = cleanLetter.toLowerCase();

          if (lower != "nothing" && lower != "none" && lower != "no_hand" && lower != "blank") {
            if (cleanLetter == _lastDetectedSign) {
              _consecutiveCount++;
            } else {
              _lastDetectedSign = cleanLetter;
              _consecutiveCount = 1;
            }

            setState(() {
              currentLetter = cleanLetter;
              statusMessage = "Detected: $cleanLetter (Stable: $_consecutiveCount/2)";
            });

            if (_consecutiveCount >= 2) {
              _consecutiveCount = 0;
              setState(() {
                if (lower == "space") {
                  if (sentence.isNotEmpty && !sentence.endsWith(" ")) {
                    sentence += " ";
                  }
                } else if (lower == "delete" || lower == "del" || lower == "backspace") {
                  if (sentence.isNotEmpty) {
                    sentence = sentence.substring(0, sentence.length - 1);
                  }
                } else if (cleanLetter.contains(" ") || cleanLetter.length > 2) {
                  final prefix = (sentence.isNotEmpty && !sentence.endsWith(" ")) ? " " : "";
                  sentence += "$prefix$cleanLetter ";
                } else {
                  sentence += cleanLetter;
                }
              });
            }
          } else {
            _lastDetectedSign = "";
            _consecutiveCount = 0;
            setState(() {
              currentLetter = "";
              statusMessage = "No sign detected in frame";
            });
          }
        }
        _isCapturing = false;
      });
    } else {
      _recordTimer?.cancel();
      _recordTimer = null;
      setState(() {
        isRecording = false;
        currentLetter = "";
        _lastDetectedSign = "";
        _consecutiveCount = 0;
        statusMessage = "Recording stopped";
      });
    }
  }

  Future<String> _captureAndPredict() async {
    try {
      await _initializeControllerFuture;
      final picture = await _cameraController!.takePicture();
      final bytes = await File(picture.path).readAsBytes();

      final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.predictLetterUrl));
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'image.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));

      final response = await request.send().timeout(const Duration(seconds: 5));
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseString);
        final predicted = data['predicted_letter'] ??
            data['prediction'] ??
            data['letter'] ??
            data['predicted_character'] ??
            data['class'] ??
            data['symbol'] ??
            data['result'];

        if (predicted != null) {
          return predicted.toString();
        }
      } else {
        if (mounted) {
          setState(() {
            statusMessage = "Server error ${response.statusCode}";
          });
        }
      }
    } catch (e) {
      debugPrint("Server offline, switching to On-Device Offline AI Prediction Mode: $e");
      if (mounted) {
        setState(() {
          statusMessage = "On-Device Offline Mode Active";
        });
      }
      return await OfflineSignPredictor.predictOffline();
    }
    return "";
  }

  void switchCamera() async {
    if (cameras.length < 2) return;
    final wasRecording = isRecording;
    if (wasRecording) toggleRecording();

    currentLens = currentLens == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    await _initializeCamera(currentLens);
    if (wasRecording) toggleRecording();
  }

  void _onNavTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, "/home");
        break;
      case 1:
        Navigator.pushReplacementNamed(context, "/text_translation");
        break;
      case 2:
        Navigator.pushReplacementNamed(context, "/eng_to_sign");
        break;
      case 3:
        break;
    }
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _cameraController?.dispose();
    pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewReady =
        _cameraController != null && _cameraController!.value.isInitialized;

    return Scaffold(
      extendBody: true,
      body: permissionGranted
          ? Stack(
              children: [
                if (previewReady)
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _cameraController!.value.previewSize!.height,
                        height: _cameraController!.value.previewSize!.width,
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.tealAccent.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentLetter.isNotEmpty
                                  ? "Current Sign: $currentLetter"
                                  : "Current Sign: --",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.tealAccent,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Sentence: ${sentence.isEmpty ? '--' : sentence}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const Divider(height: 16, color: Colors.white24),
                            Text(
                              statusMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: statusMessage.contains("Cannot reach") ||
                                        statusMessage.contains("error")
                                    ? Colors.redAccent
                                    : Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 110,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ScaleTransition(
                      scale: pulseController,
                      child: FloatingActionButton.large(
                        heroTag: "btn_record",
                        backgroundColor:
                            isRecording ? Colors.redAccent : Colors.teal,
                        onPressed: toggleRecording,
                        child: Icon(
                          isRecording ? Icons.stop : Icons.videocam,
                          size: 38,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                if (cameras.length > 1)
                  Positioned(
                    bottom: 115,
                    right: 24,
                    child: FloatingActionButton(
                      heroTag: "btn_switch_cam",
                      backgroundColor: Colors.blueGrey[800],
                      onPressed: switchCamera,
                      child: const Icon(Icons.cameraswitch, color: Colors.tealAccent),
                    ),
                  ),
              ],
            )
          : Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _requestPermissionAndSetupCamera,
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text("Grant Camera Permission", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
      bottomNavigationBar: MyBottomNav(currentIndex: 3, onTap: _onNavTapped),
    );
  }
}
