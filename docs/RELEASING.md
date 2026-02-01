# Releasing the App

This project uses Semantic Versioning (SemVer) with a build number in
`pubspec.yaml`:

```
version: MAJOR.MINOR.PATCH+BUILD
```

Notes:
- `MAJOR.MINOR.PATCH` is the user-facing version.
- `BUILD` is required by both stores and must **increase** for every upload.
- Even for manual builds, choose any integer build number as long as it is
  monotonically increasing (e.g., 1, 2, 3, ...).

Flutter maps this to:
- Android: `versionName` = `MAJOR.MINOR.PATCH`, `versionCode` = `BUILD`
- iOS: `CFBundleShortVersionString` = `MAJOR.MINOR.PATCH`,
  `CFBundleVersion` = `BUILD`

## When to bump versions
- **Bug fix**: bump PATCH (e.g., `0.1.0+1` → `0.1.1+2`)
- **Feature**: bump MINOR (e.g., `0.1.1+2` → `0.2.0+3`)
- **Breaking change**: bump MAJOR (e.g., `0.2.0+3` → `1.0.0+4`)

## Release checklist (every release)
1. **Update CHANGELOG.md**
   - Move items from `[Unreleased]` into a new version section.
   - Add the release date.
2. **Bump version in `pubspec.yaml`**
   - Update `MAJOR.MINOR.PATCH`.
   - Increment `+BUILD` by 1 (or more).
3. **Commit and push**
   - Example: `git commit -m "Release 0.1.1"`
4. **Build artifacts**
   - Android: `flutter build appbundle`
   - iOS: `flutter build ipa` (or Xcode Archive)
5. **Upload to stores with release notes**
   - Play Store: Release > Production > "What's new"
   - App Store Connect: "What's New in This Version"
6. **Verify listing**
   - Confirm the store listing shows the new version.

## Platform-Specific Guides

### Android
For detailed Android publishing steps, see:
- **[Android Publishing Guide](ANDROID_PUBLISHING.md)** - Complete step-by-step guide
- **[Android Publishing Checklist](ANDROID_PUBLISHING_CHECKLIST.md)** - Pre-release checklist

### iOS
iOS publishing guide coming soon.

## Optional: override version at build time
If needed, you can override during build:
```
flutter build appbundle --build-name=0.2.0 --build-number=5
```
But the preferred approach is to keep `pubspec.yaml` as the source of truth.
