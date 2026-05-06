#  Insuroo Frontend

The Flutter mobile frontend for **Insuroo** — an AI-powered insurance assistant. This app connects to the [Insuroo backend](https://github.com/ABHIRAM-AP/Insuroo) to let users query insurance policies, get personalized recommendations, and interact via voice in their preferred language.

---

## ✨ Features

- 💬 **Text-based Q&A** — Ask any question about insurance policies and receive AI-generated answers from the backend RAG engine.
- 📋 **Policy Recommendations** — Fill in a user profile form and get tailored insurance policy suggestions.
- 🎙️ **Voice Input (STT)** — Record audio queries and send them to the backend for transcription (supports Hindi and other languages via Groq).
- 🔊 **Voice Output (TTS)** — Listen to answers read aloud via Sarvam AI's text-to-speech, right inside the app.
- 🌐 **Cross-platform** — Built with Flutter; runs on Android, iOS, and can be extended to web/desktop.

---

##  Project Structure

```
Insuroo_Frontend/
├── README.md
└── insuroo/                   # Flutter project root
    ├── pubspec.yaml            # Dependencies and project config
    ├── lib/                    # Dart source code
    │   ├── main.dart           # App entry point
    │   ├── screens/            # UI screens (Home, Chat, Recommend, Voice)
    │   ├── widgets/            # Reusable UI components
    │   └── services/           # API service layer (HTTP calls to backend)
    ├── android/                # Android platform code
    ├── ios/                    # iOS platform code
    ├── linux/                  # Linux desktop support
    ├── macos/                  # macOS desktop support
    ├── windows/                # Windows desktop support
    └── web/                    # Web support
```

---

##  Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (stable channel recommended)
- Android Studio / Xcode (for emulator or device deployment)
- The [Insuroo backend](https://github.com/ABHIRAM-AP/Insuroo) running locally or deployed

### 1. Clone the repository

```bash
git clone https://github.com/ABHIRAM-AP/Insuroo_Frontend.git
cd Insuroo_Frontend/insuroo
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure the backend URL

Locate the API service file (e.g., `lib/services/api_service.dart`) and set the base URL to point to your running Insuroo backend:

```dart
const String baseUrl = 'http://<YOUR_BACKEND_HOST>:8000';
```

> For local development on an Android emulator, use `http://10.0.2.2:8000`.  
> For a physical device on the same network, use your machine's local IP.

### 4. Run the app

```bash
# For Android / iOS device or emulator
flutter run

# For a specific platform
flutter run -d android
flutter run -d ios
```

---

##  App Screens

###  Home
Landing screen with navigation to the different features of the app.

###  Chat / Q&A
Type a question about insurance — the app sends it to `/query/ask` on the backend and displays the AI-generated answer.

###  Recommend
A form where users enter their profile details (name, age, income, dependents, etc.). The app posts to `/query/recommend` and displays tailored policy suggestions.

###  Voice Assistant
- **Record** audio using the device microphone.
- The app uploads the audio to `/voice/transcribe` to get the text.
- The transcribed text is sent to `/query/ask`.
- The answer is played back as audio via `/voice/speak`.

---

##  Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| HTTP Client | `http` / `dio` package |
| Audio Recording | `record` / `flutter_sound` package |
| Audio Playback | `audioplayers` / `just_audio` package |
| State Management | Provider / setState |
| Platform Support | Android, iOS, Web, Desktop |

---

##  Backend Integration

This app is the frontend for the [Insuroo Backend](https://github.com/ABHIRAM-AP/Insuroo). Make sure the backend is up and running before using the app. Key endpoints consumed:

| Endpoint | Purpose |
|---|---|
| `GET /health` | Check if backend is alive |
| `POST /query/ask` | Text-based insurance Q&A |
| `POST /query/recommend` | Policy recommendations |
| `POST /voice/transcribe` | Upload audio → get text |
| `POST /voice/speak` | Get text → audio response |

---

##  Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release
```

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.

---
