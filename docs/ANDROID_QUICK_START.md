# Android Publishing Quick Start

This is a condensed guide for developers who need to quickly set up and publish the Android app. For detailed information, see [ANDROID_PUBLISHING.md](ANDROID_PUBLISHING.md).

## Prerequisites

- Flutter SDK installed
- Android SDK/Studio installed
- Google Play Console account ($25 one-time)

## 1. Generate Keystore (One-time setup)

```bash
# Generate keystore
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Move to project
mv ~/upload-keystore.jks android/app/upload-keystore.jks
```

**Important**: Back up this file securely! Losing it means you can't update your app.

## 2. Create key.properties

Create `android/key.properties`:

```properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

**Important**: This file is gitignored. Keep a secure backup!

## 3. Update Version

In `pubspec.yaml`:

```yaml
version: 0.1.0+1  # Increment for each release
```

## 4. Build Release

```bash
# Clean and build
flutter clean
flutter pub get
flutter build appbundle --release
```

**Output**: `build/app/outputs/bundle/release/app-release.aab`

## 5. Upload to Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Create app (if first time)
3. Complete store listing (name, description, screenshots, icon)
4. Fill content rating questionnaire
5. Complete data safety section
6. Go to **Release > Production > Create new release**
7. Upload `app-release.aab`
8. Add release notes
9. Review and rollout

## 6. Wait for Review

Google reviews typically take 1-7 days. You'll receive email notifications.

## Quick Commands

```bash
# Build app bundle
flutter build appbundle --release

# Build APK for testing
flutter build apk --release

# Verify signing
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab

# Check size
ls -lh build/app/outputs/bundle/release/app-release.aab
```

## Common Issues

### "App not signed" error
- Check `key.properties` exists in `android/` directory
- Verify passwords in `key.properties` are correct
- Ensure `upload-keystore.jks` is in `android/app/` directory

### Build fails
```bash
# Clean and retry
flutter clean
flutter pub get
flutter build appbundle --release
```

### "Keystore file not found"
- Check path in `key.properties`: `storeFile=upload-keystore.jks`
- Ensure keystore is in `android/app/` directory

## Checklist

Use [ANDROID_PUBLISHING_CHECKLIST.md](ANDROID_PUBLISHING_CHECKLIST.md) before each release.

## Full Documentation

- [Complete Publishing Guide](ANDROID_PUBLISHING.md)
- [Publishing Checklist](ANDROID_PUBLISHING_CHECKLIST.md)
- [Version Management](RELEASING.md)
