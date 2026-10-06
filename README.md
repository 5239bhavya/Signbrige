# 🤟 SignBridge — Real-Time Sign Language & Communication Platform

**SignBridge** is a modern, AI-powered accessibility platform built with **Flutter** and a self-contained **FastAPI + MediaPipe Python AI Backend**. It bridges the communication gap between hearing/speaking individuals and the Deaf/Hard-of-Hearing community through live camera sign translation, speech-to-sign animations, and voice message synthesis.

---

## 🚀 Key Features

1. **Camera Sign → English Live Translation**:
   - Uses **MediaPipe 3D Hand Landmark Sequence Analysis** to detect whole sign words and phrases (*Hello, Thank You, Good Morning, I Love You, Call Me, Water, Food, Learn, Yes, No, Victory, Okay, Stop, Point, Cool*).
   - Features a **2-frame stability filter** to eliminate flickering during hand transitions.
   - Fallback **On-Device Offline Mode** when no network connection is available.

2. **English → ISL Sign Language Animation Studio**:
   - Accepts both **Typed English Text** and **Recorded Speech Audio** via microphone.
   - Maps English phrases and words to high-definition **Indian Sign Language (ISL) GIF animations**.
   - Integrated **Text-To-Speech (TTS)** voice message generator that speaks translated words out loud.

3. **Multilingual ISL Dictionary**:
   - Interactive visual word library with search and category filters (*Greetings, Emergency, Actions, Basics*).
   - Multilingual translations in **English, Hindi, and Gujarati** with video GIF previews.

4. **Assistive E-Commerce Store & Learning Hub**:
   - Storefront for verified assistive products (Hearing aids, White canes, Braille slates, Vibrating watches).
   - Integrated YouTube video tutorial playlists for learning sign language.

---

## 📁 Project Directory Structure

```text
signbridge/
├── lib/                        # Flutter Application Code
│   ├── config/
│   │   └── api_config.dart     # Centralized Backend API URLs
│   ├── services/
│   │   └── offline_sign_predictor.dart  # On-Device Offline AI Predictor
│   ├── pages/
│   │   ├── Loadingpage.dart            # App Splash Screen
│   │   ├── Homepage.dart               # Executive Dashboard
│   │   ├── SignToEnglishPage.dart      # Camera Gesture Translator
│   │   ├── EngToSignPage.dart          # Voice & Text to ISL Studio
│   │   ├── TextTranslationPage.dart    # Dual-Pane Text Translator
│   │   ├── DictionaryPage.dart         # Multilingual ISL Dictionary
│   │   ├── EcommerceStorePage.dart     # Assistive E-Commerce Store
│   │   ├── YouTubePage.dart            # Video Learning Hub
│   │   ├── ProfilePage.dart            # User Profile & Analytics
│   │   ├── AboutUsPage.dart            # Mission Overview
│   │   └── MyBottomNav.dart            # Floating Navigation Bar
│   └── main.dart               # Flutter Entry Point
├── backend/                    # Self-Contained Python AI Backend
│   ├── ISL_GIFs/               # Indian Sign Language Animation Dataset
│   ├── letters/                # ISL Alphabet Sign Image Dataset
│   ├── Model/                  # Trained Keras (.h5) & TFLite Models
│   ├── api_server.py           # FastAPI AI Server & MediaPipe Detector
│   └── requirements.txt        # Python Backend Dependencies
├── android/                    # Android Project Configuration
├── run_app.bat                 # One-Click Batch App & Backend Launcher
├── requirements.txt            # Root Requirements File
├── HOW_TO_USE_SIGN.md          # User Sign Performance Manual
├── GESTURES_GUIDE.md           # Technical Gestures Reference
└── README.md                   # Project Documentation
```

---

## 🛠️ Prerequisites & Installation

### 1. Requirements
- **Flutter SDK**: `3.10.0` or higher ([Download Flutter](https://docs.flutter.dev/get-started/install))
- **Python**: `3.10` or higher ([Download Python](https://www.python.org/downloads/))
- **Android Studio** or an Android device for testing.

### 2. Python Backend Setup
Open a terminal in the project directory and install the required Python packages:

```bash
pip install -r requirements.txt
```

### 3. Flutter App Setup
Fetch the Flutter packages:

```bash
flutter pub get
```

---

## 🏁 Running the Application

### Option 1: Automatic Launch (Recommended)
Run the convenience script in the project root:

```cmd
run_app.bat
```

This will automatically start the Python AI Backend Server on `http://192.168.1.3:5000` and launch the Flutter application simultaneously.

### Option 2: Manual Step-by-Step Launch

1. **Start the Python AI Backend**:
   ```cmd
   cd backend
   python api_server.py
   ```

2. **Run the Flutter Application**:
   Open a new terminal window in the project root and run:
   ```cmd
   flutter run
   ```

---

## 📡 API Endpoints Reference

| Method | Endpoint | Description |
| :---: | :--- | :--- |
| `GET` | `/health` | Server health check |
| `POST` | `/predict-letter/` | Accepts camera frame upload (`file`) and predicts gesture word |
| `POST` | `/text-to-isl/` | Accepts text input (`text`) and returns matching ISL sign GIF path |
| `POST` | `/voice-to-isl/` | Accepts audio `.wav` upload (`file`), converts to text & ISL sign GIF |
| `GET` | `/ISL_Gifs/{file}` | Serves static ISL sign animation GIFs |

---

## 📄 User Guides & Gesture Manuals

- **How to Perform Signs**: Refer to [`HOW_TO_USE_SIGN.md`](./HOW_TO_USE_SIGN.md) for step-by-step performance instructions.
- **Detailed Gesture Reference**: Refer to [`GESTURES_GUIDE.md`](./GESTURES_GUIDE.md) for MediaPipe joint angles and classification rules.

---

## 📜 License
This project is licensed under the MIT License.
