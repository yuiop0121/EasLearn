# EasLearn 📚

**EasLearn** is an AI-powered learning companion built with Flutter and Firebase. Designed for secondary school students, it combines an intelligent AI tutor, PDF textbook viewer, automated grading, and a personal mistake tracker — all wrapped in a sleek dark-mode interface.

---

## ✨ Features

### 🏠 Dashboard
- Personalized greeting and daily learning progress tracker ("Daily Pulse")
- Subject grid covering Mathematics, Additional Mathematics, Physics, Chemistry, Biology, Science, and Sejarah
- Firebase Authentication integration — supports both guest and signed-in modes with a dynamic profile avatar

### 🤖 AI Chat (EduPulse Assistant)
- Powered by **Google Gemini AI** (`google_generative_ai`)
- Contextually aware of your indexed textbooks and mistake logs via RAG (Retrieval-Augmented Generation)
- Quick-action chips: *Summarize Page*, *Define Symbols*, *Practice Quiz*
- Maintains full conversation history within a session

### 📄 PDF Viewer
- In-app PDF textbook viewer using `syncfusion_flutter_pdfviewer`
- Directly accessible from subject cards (Physics chapter viewer implemented)

### ✏️ AI Grading
- Automatically grades submitted work and displays an overall accuracy score
- Provides key insight chips (grammar, logic, formatting, analysis depth)
- Detailed AI feedback narrative with a "Regrade" action

### 🧠 Memory Bank
- Logs mistakes by subject and topic (e.g., *Algebraic Sign Flip*, *Newton's 3rd Law*)
- Accuracy-over-time chart with a smooth Bézier curve visualization
- Filter logs by category: All Mistakes, Calculation Errors, Concept Errors
- Persistent storage via **Cloud Firestore**

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3 (Dart ≥ 3.0) |
| State Management | Riverpod (`flutter_riverpod`, `riverpod_annotation`) |
| Navigation | GoRouter |
| Backend / Auth | Firebase Auth, Cloud Firestore, Cloud Functions |
| AI | Google Gemini API (`google_generative_ai`) |
| PDF Rendering | Syncfusion Flutter PDF Viewer |
| Image Picking | `image_picker` |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.0
- A Firebase project with **Authentication**, **Firestore**, and **Cloud Functions** enabled
- A **Google Gemini API key**

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/yuiop0121/EasLearn.git
cd EasLearn

# 2. Install dependencies
flutter pub get

# 3. Run code generation (Riverpod providers)
dart run build_runner build --delete-conflicting-outputs
```

### Firebase Setup

1. Create a project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android / iOS / Web apps as needed
3. Download and place `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS) in the appropriate directories
4. Run `flutterfire configure` to regenerate `lib/firebase_options.dart`

### Running the App

```bash
# Run on a connected device or emulator
flutter run

# Build for web
flutter build web
```

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants.dart
│   ├── router/          # GoRouter configuration
│   ├── theme/           # Dark theme & color palette
│   └── widgets/         # Shared scaffold/navigation widgets
├── features/
│   ├── chat/            # AI chat screen
│   ├── dashboard/       # Home, login, PDF viewer, subject screens
│   ├── grading/         # AI grading result screen
│   └── memory_bank/     # Mistake log & accuracy tracker
├── services/
│   ├── chat_service.dart
│   ├── gemini_service.dart
│   ├── grading_service.dart
│   ├── mistake_log_service.dart
│   └── rag_service.dart
└── main.dart
```

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

---

## 📄 License

This project is for educational purposes. See [LICENSE](LICENSE) for details.
