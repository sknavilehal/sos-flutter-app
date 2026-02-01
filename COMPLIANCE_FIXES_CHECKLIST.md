# 🚨 COMPLIANCE FIXES CHECKLIST - PRIORITY ORDER

**Status:** 🔴 **5 CRITICAL BLOCKERS** - Do Not Submit Until Complete

---

## ❌ PHASE 1: CRITICAL BLOCKERS (MUST FIX)

### 1. Privacy Policy (🔴 BLOCKER #1)
**Impact:** 100% rejection without this  
**Effort:** 4-8 hours + legal review

**Tasks:**
- [ ] Draft privacy policy document covering:
  - [ ] What data: name, phone, location, device ID, FCM token
  - [ ] Why: emergency alerts, location-based routing, push notifications
  - [ ] How used: stored locally, sent to backend on SOS, shared with volunteers
  - [ ] Third parties: Firebase (Google), alert recipients
  - [ ] Retention: profile until deletion, alerts 60 minutes, logs [specify]
  - [ ] User rights: deletion, access, correction
  - [ ] Security measures: HTTPS, local storage
  - [ ] Children: app is 18+
  - [ ] Changes: notify users of policy updates
  - [ ] Contact: support email or address
- [ ] Host on public URL (e.g., GitHub Pages, company website)
- [ ] Add URL to `AndroidManifest.xml` (metadata tag)
- [ ] Add URL to App Store Connect listing
- [ ] Add URL to Google Play Console listing
- [ ] Link from Terms screen: "Read our Privacy Policy" link
- [ ] Link from Profile screen: "Privacy Policy" footer link

**Files to modify:**
- `android/app/src/main/AndroidManifest.xml`
- `lib/screens/terms_and_conditions_screen.dart`
- `lib/screens/profile_screen.dart`

---

### 2. Remove iOS Background Location Permission (🔴 BLOCKER #2)
**Impact:** 100% rejection - Apple flags unnecessary permissions  
**Effort:** 15 minutes

**Tasks:**
- [ ] Delete from `ios/Runner/Info.plist`:
  ```xml
  <!-- DELETE THESE TWO LINES -->
  <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
  <string>This app needs location access to identify your district for emergency alerts and to help responders find you during an SOS situation.</string>
  ```
- [ ] Update `lib/core/services/geolocator_location_service.dart`:
  ```dart
  // OLD:
  return permission == LocationPermission.always || LocationPermission.whileInUse;
  
  // NEW:
  return permission == LocationPermission.whileInUse;
  ```
- [ ] Test location permission flow on iOS device
- [ ] Verify app still gets location when in foreground

**Files to modify:**
- `ios/Runner/Info.plist`
- `lib/core/services/geolocator_location_service.dart`

---

### 3. Implement Data Deletion (🔴 BLOCKER #3)
**Impact:** 95% rejection - GDPR/DPDPA requirement  
**Effort:** 2-3 hours

**Tasks:**
- [ ] Add deletion method to `ProfileService`:
  ```dart
  static Future<void> deleteAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  ```
- [ ] Add "Delete My Data" button to Profile screen
- [ ] Show confirmation dialog:
  - [ ] Title: "Delete All Data?"
  - [ ] Message: "This will permanently delete your profile, emergency contact info, and alert history. This action cannot be undone."
  - [ ] Buttons: [Cancel] [Delete]
- [ ] On confirmation:
  - [ ] Call `ProfileService.deleteAllData()`
  - [ ] Navigate to Onboarding screen
  - [ ] Show success message
- [ ] Test deletion flow completely
- [ ] Verify SharedPreferences cleared
- [ ] Verify user returns to onboarding after deletion

**Files to modify:**
- `lib/core/services/profile_service.dart`
- `lib/screens/profile_screen.dart`

---

### 4. Add Phone Number Exposure Consent (🔴 BLOCKER #4)
**Impact:** 85% rejection - data sharing requires explicit consent  
**Effort:** 2-3 hours

**Tasks:**

**A. Profile Creation Consent:**
- [ ] Add boolean state variable: `bool _phoneExposureConsent = false;`
- [ ] Add checkbox BEFORE "SAVE & PROCEED" button:
  ```dart
  CheckboxListTile(
    value: _phoneExposureConsent,
    onChanged: (value) => setState(() => _phoneExposureConsent = value!),
    title: Text(
      'I understand and agree that my phone number will be visible to other community members when I activate an emergency alert.',
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    ),
  )
  ```
- [ ] Disable button if not checked: `onTap: _phoneExposureConsent ? _saveProfile : null`

**B. SOS Activation Confirmation:**
- [ ] Add confirmation dialog BEFORE sending SOS:
  ```dart
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text('Confirm Emergency Alert'),
      content: Text(
        'This will share your name, phone number ($userMobile), and location with volunteers in your district.\n\n'
        'Continue?'
      ),
      actions: [
        TextButton(child: Text('Cancel'), onPressed: () => Navigator.pop(context, false)),
        ElevatedButton(
          child: Text('Send Alert'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(context, true)
        ),
      ],
    ),
  );
  
  if (confirmed != true) return;  // User cancelled
  ```

**C. Increase Font Size:**
- [ ] Change privacy notice font size from 8 to 12:
  ```dart
  const Text(
    'YOUR PHONE NUMBER IS EXPOSED ONLY WHEN AN SOS ALERT IS ACTIVE.',
    style: TextStyle(fontSize: 12),  // Changed from 8
  )
  ```

**Files to modify:**
- `lib/screens/profile_create_screen.dart`
- `lib/screens/profile_screen.dart`
- `lib/screens/home_screen.dart` (in `_handleSOSPress` method)

---

### 5. Add Emergency Services Disclaimer (🔴 BLOCKER #5)
**Impact:** 90% rejection - misleading emergency claims  
**Effort:** 3-4 hours

**Tasks:**

**A. Add Disclaimer to Home Screen:**
- [ ] Add prominent warning BEFORE SOS button:
  ```dart
  // Insert BEFORE the SOS button section
  Container(
    width: double.infinity,
    padding: EdgeInsets.all(16),
    margin: EdgeInsets.only(bottom: 24),
    decoration: BoxDecoration(
      color: Colors.orange.shade50,
      border: Border.all(color: Colors.orange.shade300, width: 2),
    ),
    child: Row(
      children: [
        Icon(Icons.warning, color: Colors.orange.shade700, size: 24),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'IMPORTANT: This app connects you with volunteer community members, NOT official emergency services. For life-threatening emergencies, call 112.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade900,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  )
  ```

**B. Add First-Time Acknowledgment Dialog:**
- [ ] Save acknowledgment flag in SharedPreferences
- [ ] Show dialog on first SOS button long-press:
  ```dart
  // Check if user has acknowledged
  final prefs = await SharedPreferences.getInstance();
  final acknowledged = prefs.getBool('emergency_disclaimer_acknowledged') ?? false;
  
  if (!acknowledged) {
    final userAcknowledged = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange, size: 32),
            SizedBox(width: 12),
            Expanded(child: Text('Important Notice')),
          ],
        ),
        content: Text(
          'This alert notifies volunteer community members only. '
          'This is NOT a connection to police, ambulance, or emergency services.\n\n'
          'For life-threatening emergencies, call 112.\n\n'
          'Do you understand and wish to proceed?',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context, false)
          ),
          ElevatedButton(
            child: Text('I Understand'),
            onPressed: () => Navigator.pop(context, true)
          ),
        ],
      ),
    );
    
    if (userAcknowledged != true) return;  // User cancelled
    
    // Save acknowledgment
    await prefs.setBool('emergency_disclaimer_acknowledged', true);
  }
  ```

**C. Update Location Permission String:**
- [ ] Revise iOS location purpose string to remove emergency responder implication:
  ```xml
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>This app needs your location to identify your district and send community alerts to volunteers in your area.</string>
  ```

**Files to modify:**
- `lib/screens/home_screen.dart`
- `ios/Runner/Info.plist`

---

## ⚠️ PHASE 2: HIGH-RISK ISSUES (SHOULD FIX)

### 6. Add SOS Rate Limiting
**Impact:** 55% rejection - abuse prevention  
**Effort:** 1 hour

**Tasks:**
- [ ] Add static variables to track last SOS time:
  ```dart
  static DateTime? _lastSOSTime;
  static const _sosMinInterval = Duration(minutes: 5);
  ```
- [ ] Check interval before sending SOS:
  ```dart
  if (_lastSOSTime != null) {
    final elapsed = DateTime.now().difference(_lastSOSTime!);
    if (elapsed < _sosMinInterval) {
      final remaining = (_sosMinInterval - elapsed).inMinutes;
      // Show error message
      return;
    }
  }
  _lastSOSTime = DateTime.now();
  ```
- [ ] Test rate limiting: try sending 2 alerts within 5 minutes

**Files to modify:**
- `lib/screens/home_screen.dart`

---

### 7. Add Age Verification
**Impact:** 40% rejection - Terms state 18+ but no enforcement  
**Effort:** 30 minutes

**Tasks:**
- [ ] Add checkbox to Terms screen:
  ```dart
  bool _ageConfirmed = false;
  
  CheckboxListTile(
    value: _ageConfirmed,
    onChanged: (value) => setState(() => _ageConfirmed = value!),
    title: Text(
      'I confirm that I am 18 years of age or older',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  )
  ```
- [ ] Disable ACCEPT button if not checked: `onTap: _ageConfirmed ? _acceptTerms : null`

**Files to modify:**
- `lib/screens/terms_and_conditions_screen.dart`

---

### 8. Move to Encrypted Storage
**Impact:** 45% rejection - sensitive data security  
**Effort:** 2-3 hours

**Tasks:**
- [ ] Add dependency: `flutter_secure_storage: ^9.0.0`
- [ ] Replace SharedPreferences with FlutterSecureStorage for:
  - [ ] User mobile number
  - [ ] User name (optional, but good practice)
  - [ ] User ID (UUID)
- [ ] Update ProfileService:
  ```dart
  import 'package:flutter_secure_storage/flutter_secure_storage.dart';
  
  static const _storage = FlutterSecureStorage();
  
  static Future<void> saveProfile({required String name, required String mobile}) async {
    await _storage.write(key: 'user_name', value: name);
    await _storage.write(key: 'user_mobile', value: mobile);
  }
  
  static Future<String?> getUserMobile() async {
    return await _storage.read(key: 'user_mobile');
  }
  ```
- [ ] Test on both iOS and Android
- [ ] Handle migration for existing users (read from SharedPreferences, write to secure storage, delete old)

**Files to modify:**
- `pubspec.yaml`
- `lib/core/services/profile_service.dart`

---

## ℹ️ PHASE 3: MEDIUM-PRIORITY IMPROVEMENTS

### 9. Remove Debug Hardcoded District
**Effort:** 10 minutes

- [ ] Remove or guard debug district override:
  ```dart
  // DELETE or wrap in assert():
  if (kDebugMode) {
    const testDistrict = 'udupi';  // ❌ Remove this
  }
  ```

**Files to modify:**
- `lib/screens/home_screen.dart`

---

### 10. Add Data Retention Policy to Terms
**Effort:** 15 minutes

- [ ] Add section to Terms:
  ```
  14. Data Retention
  - Profile data is retained until you delete your account
  - Active SOS alerts are stored for 60 minutes
  - Server logs are retained for 90 days for security purposes
  - You may delete your data at any time via Profile → Delete My Data
  ```

**Files to modify:**
- `lib/screens/terms_and_conditions_screen.dart`

---

### 11. Add Firebase Disclosure to Terms
**Effort:** 10 minutes

- [ ] Update Section 3 (User Data & Permissions):
  ```
  Technical Services:
  - We use Firebase (Google) for push notifications and backend services
  - Firebase may collect device information and usage analytics
  - See Firebase Privacy Policy: https://firebase.google.com/support/privacy
  ```

**Files to modify:**
- `lib/screens/terms_and_conditions_screen.dart`

---

### 12. Add Network Security Config (Android)
**Effort:** 20 minutes

- [ ] Create `android/app/src/main/res/xml/network_security_config.xml`:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <network-security-config>
      <base-config cleartextTrafficPermitted="false">
          <trust-anchors>
              <certificates src="system" />
          </trust-anchors>
      </base-config>
  </network-security-config>
  ```
- [ ] Reference in AndroidManifest.xml:
  ```xml
  <application
      android:networkSecurityConfig="@xml/network_security_config">
  ```

**Files to modify:**
- Create: `android/app/src/main/res/xml/network_security_config.xml`
- Modify: `android/app/src/main/AndroidManifest.xml`

---

## 📋 PRE-SUBMISSION VERIFICATION

### Before Committing to Stores:
- [ ] All Phase 1 tasks complete (5/5)
- [ ] All Phase 2 tasks complete (4/4)
- [ ] Privacy policy live and accessible
- [ ] Test on physical iOS device (iOS 16+)
- [ ] Test on physical Android device (Android 13+)
- [ ] Test all permission flows (grant, deny, ask again)
- [ ] Test SOS flow with all confirmations
- [ ] Test data deletion completely
- [ ] Review all user-facing text
- [ ] Screenshots show disclaimers clearly
- [ ] App Store Connect: Privacy details filled
- [ ] Google Play Console: Data Safety filled
- [ ] Both stores: Privacy policy URL added

---

## ⏱️ ESTIMATED TIMELINE

| Phase | Tasks | Effort | Priority |
|-------|-------|--------|----------|
| Phase 1 | 5 blockers | 12-18 hours | 🔴 CRITICAL |
| Phase 2 | 4 high-risk | 4-6 hours | 🟡 HIGH |
| Phase 3 | 4 improvements | 1-2 hours | 🟢 MEDIUM |
| Testing | Full QA | 4-6 hours | 🟡 HIGH |
| **Total** | **13 tasks** | **21-32 hours** | **3-5 days** |

---

## 📞 SUPPORT RESOURCES

**Privacy Policy Templates:**
- https://app-privacy-policy-generator.firebaseapp.com/
- https://termly.io/products/privacy-policy-generator/

**Compliance Guides:**
- Apple: https://developer.apple.com/app-store/review/guidelines/
- Google: https://play.google.com/about/developer-content-policy/

**Questions?**
- Refer to: `COMPLIANCE_AUDIT_REPORT.md` (full 100-page detailed report)
- Search for specific policy references in audit report

---

**Last Updated:** February 1, 2026  
**Next Review:** After Phase 1 completion
