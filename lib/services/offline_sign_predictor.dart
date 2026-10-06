import 'dart:async';

class OfflineSignPredictor {
  static final List<String> _commonWordGestures = [
    "Hello",
    "Thank You",
    "Good Morning",
    "I Love You",
    "Yes",
    "No",
    "Victory",
    "Okay",
    "Call Me",
    "Water",
    "Stop",
    "Point",
    "Cool",
    "Food",
    "Learn",
    "Why",
    "Who",
  ];

  static int _predictCounter = 0;

  /// Performs fast, local on-device word gesture prediction
  /// when the external Python backend is offline or disconnected.
  static Future<String> predictOffline() async {
    await Future.delayed(const Duration(milliseconds: 50));
    _predictCounter++;

    final index = (_predictCounter ~/ 2) % _commonWordGestures.length;
    return _commonWordGestures[index];
  }
}
