# Tigidou 🚀

**Tigidou** is a smart, localized, and secure Todo application built with Flutter. It leverages natural language processing (NLP) to parse task metadata and provides a clean, gradient-based UI for an optimal user experience.

## ✨ Features

- 🧠 **Smart Parsing (NLP)**: Automatically detect dates, times, and people assignments using `@mention` syntax.
- 📂 **Hierarchical Tagging**: Organize tasks with dot-notated hashtags (e.g., `#work.urgent`, `#home.shopping`).
- 🔐 **Secure & Private**: Integrated with Firebase Authentication and Biometric Login (Face ID/Touch ID).
- 🌍 **Fully Localized**: Support for English and French, automatically matching system settings.
- 🎨 **Modern UI**: Signature "Tigidou Blue" gradient theme with support for Dark Mode.
- 🔍 **Real-time Search**: Instant filtering of tasks with draft previews for new entries.

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **Backend**: [Firebase](https://firebase.google.com/) (Firestore, Authentication)
- **Local Auth**: [local_auth](https://pub.dev/packages/local_auth)
- **Testing**: [Patrol](https://patrol.leancode.co/) for E2E tests, standard Flutter unit/widget tests.
- **CI/CD**: GitHub Actions with [Codemagic CLI tools](https://docs.codemagic.io/cli/welcome/).

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Firebase Account (for backend services)
- iOS/Android developer tools (Xcode/Android Studio)

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/ykoehler/tigidou.git
    cd tigidou
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the application**:
    ```bash
    flutter run
    ```

## 🧪 Testing

We use **Patrol** for robust E2E testing. To run integration tests:

```bash
patrol test -t integration_test/todo_management_test.dart
```

For standard unit and widget tests:

```bash
flutter test
```

## 📄 Documentation

For more detailed information, check the `docs/` folder:

- [Product Requirements](file:///Users/ykoehler/Projects/tigidou/tigidou/docs/requirements.md)
- [iOS Deployment Status](file:///Users/ykoehler/Projects/tigidou/tigidou/docs/ios_deployment_status.md)
- [Release Guide](file:///Users/ykoehler/Projects/tigidou/tigidou/docs/release_guide.md)

---
*Built with ❤️ by the Tigidou Team.*
