import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user profile data in local storage
class ProfileService {
  static const String _nameKey = 'user_name';
  static const String _mobileKey = 'user_mobile';
  static const String _termsAcceptedKey = 'terms_accepted';

  /// Save user profile data
  static Future<void> saveProfile({
    required String name,
    required String mobile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_mobileKey, mobile);
  }

  /// Get user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  /// Get user mobile number
  static Future<String?> getUserMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mobileKey);
  }

  /// Check if user profile exists
  static Future<bool> hasUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_nameKey) && prefs.containsKey(_mobileKey);
  }

  /// Clear user profile
  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_mobileKey);
  }

  /// Validate Indian mobile number
  static bool isValidIndianMobile(String mobile) {
    // Remove any spaces, dashes, or other formatting
    final cleanMobile = mobile.replaceAll(RegExp(r'[^\d]'), '');
    
    // Indian mobile numbers: 10 digits, starts with 6-9
    final mobileRegex = RegExp(r'^[6-9]\d{9}$');
    return mobileRegex.hasMatch(cleanMobile);
  }

  /// Format Indian mobile number for display
  static String formatMobileNumber(String mobile) {
    final cleanMobile = mobile.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanMobile.length == 10) {
      return '+91 ${cleanMobile.substring(0, 5)} ${cleanMobile.substring(5)}';
    }
    return mobile;
  }

  /// Check if user has accepted terms and conditions
  static Future<bool> hasAcceptedTerms() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_termsAcceptedKey) ?? false;
  }

  /// Set terms and conditions acceptance status
  static Future<void> setTermsAccepted(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_termsAcceptedKey, accepted);
  }
}