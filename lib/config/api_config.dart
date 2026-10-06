import 'dart:io';

class ApiConfig {
  // Base server IP & Port
  // Update this to your local Wi-Fi IP or domain as needed
  static const String _pcIp = "192.168.1.3";
  static const int port = 5000;

  static String get baseUrl {
    if (Platform.isAndroid) {
      // You can return "http://10.0.2.2:$port" for Android Emulator
      // or "http://$_pcIp:$port" for real devices on Wi-Fi
      return "http://$_pcIp:$port";
    }
    return "http://127.0.0.1:$port";
  }

  // Endpoints
  static String get predictLetterUrl => "$baseUrl/predict-letter/";
  static String get voiceToIslUrl => "$baseUrl/voice-to-isl/";
  static String get textToIslUrl => "$baseUrl/text-to-isl/";
}
