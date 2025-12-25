# Technical Stack

This document outlines the technologies and architectural patterns used in **Tigidou**.

## 📱 Mobile Framework
- **Flutter**: Used for building the cross-platform application (iOS, Android, macOS, Web).
- **Dart**: The programming language powering the application.

## ☁️ Backend & Infrastructure
- **Firebase Auth**: Identiy management and secure authentication.
- **Cloud Firestore**: NoSQL document database for task and person data.
- **Firebase Local Emulator**: Used during development and E2E testing to ensure isolation and speed.

## 🏗 State Management & Architecture
- **Provider**: Simple and scalable state management for managing todos, people, and authentication state.
- **Service-Oriented Architecture**: Logic is encapsulated in services (e.g., `AuthService`, `DatabaseService`, `BiometricService`).

## 🔐 Security
- **local_auth**: Integration with native biometric systems (Face ID, Touch ID, Fingerprint).
- **Firestore Security Rules**: Server-side enforcement of data ownership and access control.

## 🧪 Quality Assurance
- **Patrol**: Advanced E2E testing framework that handles native permissions and complex UI interactions.
- **Flutter Test**: Standard unit and widget testing.
- **Lefthook**: Git hooks for pre-commit linting and testing.

## 🛠 CI/CD
- **GitHub Actions**: Automated workflows for testing and deployment.
- **Codemagic CLI**: Specialized tools for iOS code signing and App Store / TestFlight distribution.

## 🎨 UI & UX
- **Custom Design System**: Based on a blue gradient theme (`GradientScaffold`).
- **Flutter Native Splash**: Customizable splash screen.
- **Flutter Launcher Icons**: Automated app icon generation.
- **intl/flutter_localizations**: Multi-language support (EN/FR).
