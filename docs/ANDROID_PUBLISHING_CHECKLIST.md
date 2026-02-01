# Android Publishing Checklist

Use this checklist before every production release to ensure nothing is missed.

## Pre-Release Checklist

### Code & Build

- [ ] All features tested on physical Android devices
- [ ] No critical bugs or crashes
- [ ] Location services working correctly
- [ ] Push notifications functioning
- [ ] All screens tested on different screen sizes
- [ ] App tested on Android 5.0+ (minimum SDK)
- [ ] Dark mode tested (if applicable)
- [ ] Network error handling verified
- [ ] Offline functionality tested

### Version & Documentation

- [ ] Version bumped in `pubspec.yaml` (e.g., `0.1.0+1` → `0.1.1+2`)
- [ ] `CHANGELOG.md` updated with release notes
- [ ] Breaking changes documented (if any)
- [ ] Release notes prepared for Play Store

### Signing & Security

- [ ] Keystore file backed up securely
- [ ] `key.properties` file exists with correct credentials
- [ ] Keystore passwords stored in password manager
- [ ] No API keys or secrets hardcoded in source
- [ ] `.gitignore` configured (keystore, key.properties not tracked)
- [ ] Firebase config files present (`google-services.json`)

### Build Process

- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Build succeeds: `flutter build appbundle --release`
- [ ] App bundle signed and verified
- [ ] Test APK installed and runs on device: `flutter build apk --release`

### Google Play Console

- [ ] Store listing complete (app name, descriptions, screenshots)
- [ ] High-res icon (512x512) uploaded
- [ ] Feature graphic (1024x500) uploaded
- [ ] Screenshots uploaded (min 2, recommended 4-8)
- [ ] Content rating completed and approved
- [ ] Target audience declared
- [ ] Data safety section completed
- [ ] Privacy policy URL added (if required)
- [ ] Contact email verified
- [ ] Pricing and distribution countries selected
- [ ] App categorized correctly

## Release Checklist

### Upload

- [ ] App bundle uploaded to Play Console
- [ ] Release notes added
- [ ] Version code matches `pubspec.yaml`
- [ ] No warnings in Play Console
- [ ] Pre-launch report reviewed (if available)

### Testing Track (Optional but Recommended)

- [ ] Internal testing release created
- [ ] Testers invited and app shared
- [ ] Feedback collected
- [ ] Critical issues resolved

### Production Release

- [ ] All pre-release checks passed
- [ ] Release reviewed in Play Console
- [ ] Rollout percentage selected (start with 10-20% or 100%)
- [ ] Release submitted for review

## Post-Release Checklist

### Monitoring

- [ ] Release status checked in Play Console
- [ ] Install metrics reviewed after 24 hours
- [ ] Crash reports monitored
- [ ] ANR (App Not Responding) reports checked
- [ ] User reviews monitored and responded to
- [ ] Firebase Analytics checked (if integrated)

### Documentation

- [ ] Release tagged in Git: `git tag v0.1.1`
- [ ] Tag pushed to remote: `git push origin v0.1.1`
- [ ] Team notified of release
- [ ] Release notes shared with stakeholders

### Backup

- [ ] Keystore backed up (offsite, encrypted)
- [ ] `key.properties` backed up securely
- [ ] Release AAB archived
- [ ] Build configuration documented

## Rollback Plan

If critical issues are found post-release:

- [ ] Stop rollout in Play Console (if staged)
- [ ] Document the issue
- [ ] Prepare hotfix release
- [ ] Test hotfix thoroughly
- [ ] Deploy hotfix with incremented version

## Long-Term Maintenance

### Quarterly Reviews

- [ ] Update dependencies: `flutter pub upgrade`
- [ ] Update Flutter SDK to stable version
- [ ] Review and update target SDK version
- [ ] Check for deprecated APIs
- [ ] Review and update ProGuard rules

### Annual Reviews

- [ ] Renew certificates if needed
- [ ] Review app permissions (remove unused)
- [ ] Update privacy policy if data handling changes
- [ ] Refresh screenshots and store listing
- [ ] Review and improve app performance

---

## Quick Command Reference

```bash
# Clean and build
flutter clean && flutter pub get && flutter build appbundle --release

# Verify signing
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab

# Check bundle size
ls -lh build/app/outputs/bundle/release/app-release.aab

# Create git tag
git tag -a v0.1.1 -m "Release version 0.1.1"
git push origin v0.1.1
```

---

## Emergency Contacts

- **Google Play Support**: https://support.google.com/googleplay/android-developer
- **Flutter Issues**: https://github.com/flutter/flutter/issues
- **Firebase Support**: https://firebase.google.com/support

---

## Notes

- Keep this checklist updated as processes evolve
- Add team-specific steps as needed
- Review checklist quarterly for improvements
