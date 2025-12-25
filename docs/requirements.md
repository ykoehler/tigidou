# Product Requirements

## Overview
**Tigidou** is a smart Todo application designed to streamline task management through natural language processing and organizational tools. It acts as a personal assistant, understanding context from user input to automatically prioritize and schedule tasks.

## GitHub Project
> [!NOTE]
> Project management and task tracking for this application are handled in: [ykoehler/tigidou](https://github.com/ykoehler/tigidou)

## Current Feature Set

### 1. Task Management
- **Create Todos**: Users can add new tasks with a title.
- **Smart Parsing (NLP)**: The application automatically extracts metadata from the task description using the `@` syntax.
    - **Dates**: `@tomorrow`, `@today`, `@date:2023-12-31`, `@2days`, `@monday`
    - **Times**: `@14h`, `@14:00`, `@time:14h`
    - **Person Assignment**: `@username`, `@person:john` (automatically maps to "People" list).
- **Hierarchical Tagging**: Use `#` to categorize tasks with nested paths (e.g., `#work.urgent`, `#personal.shopping`).
    - The system automatically "explodes" tags (e.g., `#a.b.c` becomes `#a`, `#a.b`, and `#a.b.c`).
- **List View**: Displays tasks filtering by status (completed/active).
- **Search**: Real-time filtering of tasks by title and tags.
    - **Draft Preview**: If no existing task matches the search query, a "Draft" preview shows how the new task would look with parsed metadata.
    - **Focus Retention**: Search bar retains focus during input for seamless item creation.

### 2. Social & People
- **People Management**: Dedicated screen to manage collaborators and contacts.
- **Task Association**: Tasks are automatically linked to people if they are `@mentioned` in the title.
- **Person Profile**: Viewing a person shows all tasks (active and completed) associated with them.

### 3. Authentication & Security
- **Firebase Auth**: Secure login and registration with email/password.
- **Biometric Login**: Support for Face ID and Touch ID (iOS) for quick access.
- **Persistent Session**: Users remain logged in across app restarts.
- **Data Isolation**: Firestore security rules ensure users can only access their own data.

### 4. User Experience
- **Theme**: Premium Dark mode with a signature "Tigidou Blue" gradient background (`GradientScaffold`).
- **Localization**: Full support for English (`en`) and French (`fr`), including date/time formats.
- **App Icon & Splash**: Custom branding with a transparent logo and thematic splash screen.

## Technical Architecture
- **Framework**: Flutter (Mobile, Web, macOS).
- **State Management**: Provider.
- **Backend/Auth**: Firebase (Firestore, Auth).
- **Testing**:
    - **Unit/Widget**: `flutter test`
    - **Integration**: Patrol (Native interactions, Firebase Emulator).
    - **CI/CD**: GitHub Actions + Codemagic CLI for iOS signing and deployment.

## Future Roadmap
- **Collaboration**: Sharing specific tags or lists with other users.
- **Smart Reminders**: Push notifications based on parsed `@time` and `@date`.
- **Global Search**: Search across people, tags, and todos simultaneously.
- **Voice Input**: Create tasks using voice commands and NLP parsing.
