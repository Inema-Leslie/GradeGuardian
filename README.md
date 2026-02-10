# GradeGuardian

A Flutter mobile application designed to help students track their academic performance, manage assignments, monitor attendance, and stay on top of their course schedules.

## Features

- **Dashboard Overview**: Get a comprehensive view of your academic status at a glance
- **Assignment Management**: Track assignments, due dates, and grades
- **Attendance Tracking**: Monitor class attendance with warning notifications for at-risk students
- **Session Scheduling**: View and manage class sessions and schedules
- **Risk Assessment**: Visual indicators for students at academic risk
- **Course Management**: Organize and track multiple courses
- **Persistent Storage**: All data is saved locally using SharedPreferences

## Technology Stack

- **Framework**: Flutter (Dart SDK ^3.10.7)
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Date Handling**: intl
- **UI/UX**: Material Design with custom theming

## Project Structure

```
GradeGuardian/
├── mobile/
│   ├── lib/
│   │   ├── main.dart                      # Application entry point
│   │   ├── models/                        # Data models
│   │   │   ├── assignment.dart
│   │   │   ├── session.dart
│   │   │   └── student.dart
│   │   ├── providers/                     # State management
│   │   │   ├── assignment_provider.dart
│   │   │   ├── session_provider.dart
│   │   │   └── student_provider.dart
│   │   ├── screens/                       # UI screens
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── assignments_screen.dart
│   │   │   ├── schedule_screen.dart
│   │   │   └── login_screen.dart
│   │   ├── widgets/                       # Reusable UI components
│   │   │   ├── assignment_list_tile.dart
│   │   │   ├── attendance_warning_banner.dart
│   │   │   ├── risk_status_card.dart
│   │   │   └── session_list_tile.dart
│   │   ├── services/                      # Business logic services
│   │   └── theme/                         # App theming
│   ├── android/                           # Android platform files
│   ├── ios/                               # iOS platform files
│   ├── web/                               # Web platform files
│   ├── windows/                           # Windows platform files
│   ├── linux/                             # Linux platform files
│   ├── macos/                             # macOS platform files
│   └── pubspec.yaml                       # Dependencies
└── README.md
```

## Getting Started

### Prerequisites

- Flutter SDK (version 3.10.7 or higher)
- Dart SDK (version ^3.10.7)
- Android Studio / VS Code with Flutter extensions
- An Android emulator or iOS simulator (or physical device)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Inema-Leslie/GradeGuardian.git
   cd GradeGuardian
   ```

2. **Navigate to the mobile directory**
   ```bash
   cd mobile
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
- Ensure Android SDK is installed
- Set up an Android emulator or connect a physical device
- Enable USB debugging on your device

#### iOS (macOS only)
- Install Xcode from the App Store
- Set up CocoaPods: `sudo gem install cocoapods`
- Run `pod install` in the `ios/` directory

## Dependencies

- `provider: ^6.1.2` - State management solution
- `shared_preferences: ^2.3.5` - Local data persistence
- `intl: ^0.20.1` - Date and number formatting
- `cupertino_icons: ^1.0.8` - iOS-style icons

## Features in Detail

### Assignment Management
Track all your assignments with details including:
- Assignment name and description
- Due dates
- Course association
- Completion status
- Grades

### Attendance Tracking
- Monitor class attendance
- Receive warnings for low attendance
- Visual risk indicators
- Session-by-session tracking

### Dashboard
- Quick overview of academic performance
- At-a-glance risk status
- Upcoming assignments
- Recent sessions

## Running Tests

```bash
flutter test
```

## Build for Production

### Android APK
```bash
flutter build apk --release
```

### iOS IPA
```bash
flutter build ios --release
```

## License

This project is currently private. All rights reserved.