# RRT Flutter App

Cross-platform mobile application for emergency SOS alerts with location-based routing.

## Setup

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Firebase Configuration

**Required Files:**
- `ios/Runner/GoogleService-Info.plist` (iOS)
- `android/app/google-services.json` (Android)

**Setup Steps:**
1. Create Firebase project
2. Add iOS app: `com.rrt.app.rrtFlutterApp`
3. Add Android app: `com.rrt.app.rrt_flutter_app`
4. Enable Authentication (Anonymous) and Cloud Messaging
5. Place config files in correct locations

### 3. Backend Configuration

Update `lib/core/config/api_config.dart`:
```dart
static String get baseUrl => 'https://your-ngrok-url.ngrok.io';
```

### 4. Run Application
```bash
flutter run
```

## Features

- **Emergency SOS** with one-tap alert
- **Location Detection** with offline district mapping
- **Push Notifications** via FCM district topics  
- **Profile Management** for emergency contacts
- **Responsive UI** for all screen sizes

## Architecture

```
lib/
├── core/
│   ├── config/          # API endpoints, constants
│   ├── services/        # Location, FCM services
│   └── providers/       # Riverpod state management
├── models/              # Data models
├── screens/             # UI screens
└── main.dart           # App entry point
```

## Key Services

- **LocationService**: GPS + offline district detection
- **FCMService**: Push notifications and topic management
- **SOSService**: Emergency alert API calls

## Development

- **Hot Reload**: `r` for UI changes
- **Hot Restart**: `R` for logic changes  
- **Debug**: Use real device for location/notifications
- **Firebase**: App gracefully handles missing config

## Publishing

### Android

See [Android Publishing Guide](docs/ANDROID_PUBLISHING.md) for complete steps to publish to Google Play Store.

Quick commands:
```bash
# Build release app bundle
flutter build appbundle --release

# Build release APK
flutter build apk --release
```

### Version Management

See [RELEASING.md](docs/RELEASING.md) for version management guidelines.

---

## Documentation

- [Android Publishing Guide](docs/ANDROID_PUBLISHING.md) - Complete Play Store publishing steps
- [Android Publishing Checklist](docs/ANDROID_PUBLISHING_CHECKLIST.md) - Pre-release checklist
- [Releasing Guide](docs/RELEASING.md) - Version management
- [Smoke Test Checklist](docs/SMOKE_TEST_CHECKLIST.md) - Testing checklist
- [Implementation Summary](docs/IMPLEMENTATION_SUMMARY.md) - Architecture overview
