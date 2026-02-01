# Android App Publishing Guide

This guide walks through the complete process of publishing the RRT SOS app to the Google Play Store.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Generate Upload Keystore](#generate-upload-keystore)
3. [Configure Signing](#configure-signing)
4. [Build Release APK/AAB](#build-release-apkaab)
5. [Google Play Console Setup](#google-play-console-setup)
6. [Upload and Release](#upload-and-release)
7. [Post-Release](#post-release)

---

## Prerequisites

Before you begin, ensure you have:

- [ ] Flutter SDK installed and configured
- [ ] Android Studio or Android SDK command-line tools
- [ ] Google Play Console developer account ($25 one-time fee)
- [ ] All app assets ready (screenshots, description, privacy policy, etc.)
- [ ] App tested thoroughly on multiple devices/OS versions

---

## Generate Upload Keystore

A keystore is required to sign your Android app. **Keep this file secure** - losing it means you cannot update your app on the Play Store.

### Step 1: Create the Keystore

Run this command from the project root:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -storetype JKS
```

You'll be prompted for:
- **Keystore password**: Choose a strong password (save it securely)
- **Key password**: Can be the same as keystore password
- **Name, Organization, etc.**: Fill in your details (e.g., "RRT Team")

### Step 2: Move Keystore to Project

```bash
# Move keystore to android/app/ directory (gitignored)
mv ~/upload-keystore.jks android/app/upload-keystore.jks
```

**⚠️ IMPORTANT**: Never commit the keystore to version control!

### Step 3: Create key.properties File

Create `android/key.properties` with your keystore details:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

**⚠️ IMPORTANT**: This file is gitignored. Keep a secure backup!

---

## Configure Signing

The signing configuration is already set up in `android/app/build.gradle.kts`. 

### Verify Configuration

Ensure `android/app/build.gradle.kts` contains the signing config (it should already be configured):

```kotlin
android {
    ...
    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = java.util.Properties()
                keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))
                
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            minifyEnabled = true
            shrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

---

## Build Release APK/AAB

Google Play requires an **Android App Bundle (AAB)** for new apps.

### Step 1: Update Version

In `pubspec.yaml`, bump the version:

```yaml
version: 0.1.0+1  # Change to 0.1.1+2 (or appropriate version)
```

See [RELEASING.md](./RELEASING.md) for versioning guidelines.

### Step 2: Clean Build

```bash
# Clean previous builds
flutter clean
flutter pub get
```

### Step 3: Build App Bundle (Recommended)

```bash
# Build Android App Bundle for Play Store
flutter build appbundle --release
```

**Output**: `build/app/outputs/bundle/release/app-release.aab`

### Step 4: Build APK (Optional, for testing)

```bash
# Build APK for direct installation/testing
flutter build apk --release
```

**Output**: `build/app/outputs/flutter-apk/app-release.apk`

### Verify the Build

```bash
# Check file exists
ls -lh build/app/outputs/bundle/release/app-release.aab

# Verify signing
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

You should see "jar verified" in the output.

---

## Google Play Console Setup

### Step 1: Create Application

1. Go to [Google Play Console](https://play.google.com/console)
2. Click **Create app**
3. Fill in details:
   - **App name**: RRT SOS (or your app name)
   - **Default language**: English (United States)
   - **App or game**: App
   - **Free or paid**: Free (or Paid)
4. Accept declarations and create app

### Step 2: Complete Store Listing

Navigate to **Store presence > Main store listing**:

#### Required Assets

1. **App name**: RRT - Rapid Response Team
2. **Short description** (80 chars max):
   ```
   Emergency alert app for rapid response teams with location-based routing
   ```

3. **Full description** (4000 chars max):
   ```
   RRT SOS is an emergency alert application designed for rapid response teams.
   
   KEY FEATURES:
   • One-tap SOS alert with automatic location detection
   • Offline district mapping for accurate routing
   • Real-time push notifications for emergency alerts
   • Profile management with emergency contacts
   • Location-based alert distribution
   
   Perfect for emergency response teams, security personnel, and community safety networks.
   ```

4. **App icon**: 512x512 PNG (high-res icon)
5. **Feature graphic**: 1024x500 PNG
6. **Phone screenshots**: At least 2 (1080x1920 recommended)
   - Take screenshots from the app running on a device
7. **Tablet screenshots** (optional but recommended)
8. **Category**: Medical (or appropriate category)
9. **Contact details**: Email, phone (optional), website (optional)
10. **Privacy policy URL**: Required if app handles personal data

### Step 3: Content Rating

1. Go to **Policy > App content > Content rating**
2. Fill out the questionnaire honestly
3. Submit for rating (you'll receive IARC rating)

### Step 4: Target Audience and Content

1. **Policy > App content > Target audience**
   - Select age groups (e.g., 18+)
2. **Policy > App content > News apps**
   - Indicate if this is a news app (likely No)
3. **Policy > App content > COVID-19 contact tracing and status apps**
   - Indicate if applicable (likely No)
4. **Policy > App content > Data safety**
   - Declare what data you collect and how it's used
   - Be thorough and accurate (e.g., location data, user profiles)

### Step 5: App Access

**Policy > App content > App access**:
- If your app requires login or has restricted access, provide test credentials
- Otherwise, indicate all features are accessible

### Step 6: Ads

**Policy > App content > Ads**:
- Indicate whether your app contains ads

### Step 7: Set Up Pricing & Distribution

**Pricing and distribution**:
1. Select countries/regions for distribution
2. Confirm content guidelines and export laws compliance

---

## Upload and Release

### Step 1: Create Release

1. Go to **Release > Production**
2. Click **Create new release**

### Step 2: Upload App Bundle

1. Click **Upload** and select `app-release.aab`
2. Wait for upload and processing
3. Google Play will generate APKs for different device configurations

### Step 3: Release Notes

Add release notes (what's new):

```
Initial release of RRT SOS

Features:
• Emergency SOS alerts with one-tap activation
• Automatic location detection with offline district mapping
• Real-time push notifications for emergency updates
• User profile management
• Location-based alert routing
```

### Step 4: Review and Rollout

1. **Review release** - Check for warnings or errors
2. **Rollout percentage** (optional):
   - Start with 10-20% for staged rollout
   - Or 100% for full release
3. Click **Start rollout to Production**

### Step 5: Review Process

- Google will review your app (typically 1-7 days)
- You'll receive email notifications about the review status
- Address any issues flagged during review

---

## Post-Release

### Monitor Release

1. **Dashboard**: Check install metrics, crashes, ANRs
2. **User feedback**: Respond to reviews
3. **Crashes**: Use Play Console crash reports or Firebase Crashlytics

### Update the App

For subsequent releases:

1. Bump version in `pubspec.yaml`:
   ```yaml
   version: 0.1.1+2  # Increment build number
   ```

2. Update `CHANGELOG.md`

3. Build new bundle:
   ```bash
   flutter build appbundle --release
   ```

4. Create new release in Play Console:
   - Production > Create new release
   - Upload new AAB
   - Add release notes
   - Start rollout

### Internal Testing Track (Recommended)

Before production releases, use internal testing:

1. **Release > Internal testing**
2. Create release and upload AAB
3. Add test users via email list
4. Share testing link with team
5. Collect feedback before production release

---

## Troubleshooting

### Common Issues

#### "App not signed" error

- Ensure `key.properties` exists and has correct values
- Verify keystore file path in `key.properties`
- Check keystore password is correct

#### "Duplicate permissions" error

- Check `AndroidManifest.xml` for duplicate permission declarations
- Remove duplicates

#### "Missing content rating"

- Complete content rating questionnaire in Play Console
- Wait for IARC rating approval

#### Build fails with "Execution failed for task ':app:lintVitalRelease'"

```bash
# Skip lint checks (not recommended for production)
flutter build appbundle --release --no-tree-shake-icons

# Or fix lint errors shown in the build output
```

### Getting Help

- [Flutter Android Deployment Docs](https://docs.flutter.dev/deployment/android)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [Flutter Community](https://flutter.dev/community)

---

## Security Checklist

- [ ] Keystore backed up securely (encrypted cloud storage, password manager)
- [ ] `key.properties` added to `.gitignore`
- [ ] Keystore passwords stored in secure password manager
- [ ] API keys/secrets not hardcoded in source code
- [ ] App tested on multiple devices before release
- [ ] Privacy policy published and linked
- [ ] Data safety declarations accurate

---

## Quick Reference Commands

```bash
# Generate keystore
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Build app bundle
flutter build appbundle --release

# Build APK
flutter build apk --release

# Verify signing
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab

# Check bundle size
ls -lh build/app/outputs/bundle/release/app-release.aab

# Flutter doctor (check setup)
flutter doctor -v
```

---

## Additional Resources

- [Play Console](https://play.google.com/console)
- [Flutter Deployment Guide](https://docs.flutter.dev/deployment/android)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Play Store Requirements](https://support.google.com/googleplay/android-developer/answer/9859152)
