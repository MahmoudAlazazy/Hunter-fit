# Fitness Workout App

A comprehensive fitness workout application built with Flutter that uses SQL databases (SQLite) for all data storage instead of Firebase.

## Features

### Authentication & Profile
- User registration, login, and secure password hashing
- Complete profile setup: gender, date of birth, weight, height
- Fitness goal selection and onboarding tracking

### Workout Module
- User workouts, workout collections, and exercises
- Workout schedules, logs, and progress tracking
- CRUD operations for schedules, exercises, and logs using SQL

### Activity Tracking
- Track water intake, sleep, calories, steps, and heart rate
- All updates and reads go through SQL database

### Social / Community Module
- Users can post text with optional images
- Users can comment, reply, like posts/comments
- Comment replies count and notifications for replies
- All social data stored in SQL tables

### Notifications
- Store user notification preferences
- Notify users when someone replies to their comment

### Settings & Profile
- Update profile information
- Update notification preferences
- All stored in SQL

## Technology Stack

- **Frontend**: Flutter
- **State Management**: Provider
- **Database**: SQLite (via sqflite package)
- **Password Security**: SHA-256 hashing (via crypto package)

## Project Structure

```
lib/
├── main.dart
├── database/
│   └── database_helper.dart
├── models/
│   ├── user.dart
│   ├── workout.dart
│   ├── exercise.dart
│   ├── schedule.dart
│   ├── activity.dart
│   ├── post.dart
│   ├── comment.dart
│   └── notification.dart
├── providers/
│   ├── auth_provider.dart
│   ├── workout_provider.dart
│   ├── activity_provider.dart
│   ├── social_provider.dart
│   └── notification_provider.dart
├── services/
│   ├── auth_service.dart
│   ├── workout_service.dart
│   ├── activity_service.dart
│   ├── social_service.dart
│   └── notification_service.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── onboarding/
│   │   └── complete_profile_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   └── ... (more screens to be implemented)
└── widgets/
    ├── custom_button.dart
    └── custom_textfield.dart
```

## Database Schema

The app uses the following SQL tables:

1. **users** - Store user account information
2. **workouts** - User-created workout routines
3. **exercises** - Individual exercises within workouts
4. **workout_schedules** - Scheduled workout sessions
5. **activities** - Activity tracking data
6. **posts** - Social media posts
7. **comments** - Comments on posts
8. **likes** - Likes on posts and comments
9. **notifications** - User notifications
10. **notification_preferences** - User notification settings

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## Dependencies

- provider: ^6.0.5
- sqflite: ^2.3.0
- path: ^1.8.3
- path_provider: ^2.1.1
- crypto: ^3.0.3

## Future Implementation

The following screens and features are planned for future implementation:
- Complete workout tracking screens
- Activity tracking screens
- Social feed and notification screens
- Profile and settings screens
- Additional workout and exercise management features

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.