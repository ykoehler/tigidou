# Product Requirements

## Overview
**Tigidou** is a smart Todo application designed to streamline task management through natural language processing and social features. It acts as a personal assistant, understanding context from user input to automatically prioritize and schedule tasks.

## GitHub Project
> [!NOTE]
> Project management and task tracking for this application are handled in: [ykoehler/tigidou](https://github.com/ykoehler/tigidou)

## Current Feature Set

### 1. Task Management
- **Create Todos**: Users can add new tasks with a title.
- **Smart Parsing (NLP)**: The application automatically extracts metadata from the task description using the `@` syntax.
    - **Dates**: `@tomorrow`, `@today`, `@date:2023-12-31`
    - **Times**: `@14h`, `@14:00`, `@time:14h`
    - **Person Assignment**: `@username`, `@person:john`
- **List View**: Displays tasks filtering by status (completed/active).
- **Search**: Real-time filtering of tasks by title.
    - **Draft Preview**: If no existing task matches the search query, a "Draft" preview shows how the new task would look with parsed metadata.

### 2. Social Features
- **People Management**: Users can manage a list of people they collaborate with.
- **Task Association**: Tasks can be linked to specific people using their `@username` in the task title.
- **Person Profile**: Viewing a person shows all tasks associated with them.

### 3. Authentication
- **Firebase Auth**: Secure login and registration.
- **Persistent Session**: Users remain logged in across app restarts.

### 4. User Experience
- **Theme**: Dark mode with a signature "Tigidou Blue" gradient background.
- **Localization**: Full support for English (`en`) and French (`fr`), automatically detected based on system settings.
- **Responsive Design**: Optimized for mobile but functional on desktop/web.

## Technical Architecture
- **Framework**: Flutter (Mobile, Web, macOS).
- **State Management**: Provider.
- **Backend/Auth**: Firebase.
- **Testing**:
    - **Unit/Widget**: `flutter test`
    - **Integration**: Patrol / `flutter test` (web/macos)
    - **CI/CD**: Lefthook (pre-commit tests).

## Future Roadmap
*(This section to be populated based on future planning)*
