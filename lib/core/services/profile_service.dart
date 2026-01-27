import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Service for managing user profile data in local storage
class ProfileService {
  static const String _nameKey = 'user_name';
  static const String _mobileKey = 'user_mobile';
  static const String _termsAcceptedKey = 'terms_accepted';
  static const String _userIdKey = 'user_unique_id';
  
  static const Uuid _uuid = Uuid();

  /// Save user profile data
  static Future<void> saveProfile({
    required String name,
    required String mobile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_mobileKey, mobile);
    
    // Generate and save user ID if it doesn't exist
    if (!prefs.containsKey(_userIdKey)) {
      final userId = _uuid.v4();
      await prefs.setString(_userIdKey, userId);
    }
  }
  
  /// Get or generate a unique user ID
  /// This ID persists across profile changes (name, mobile changes)
  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_userIdKey);
    
    // If no user ID exists, generate one
    if (userId == null) {
      userId = _uuid.v4();
      await prefs.setString(_userIdKey, userId);
    }
    
    return userId;
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

  /// Validate Indian mobile number
  static bool isValidIndianMobile(String mobile) {
    // Remove any spaces, dashes, or other formatting
    final cleanMobile = mobile.replaceAll(RegExp(r'[^\d]'), '');
    
    // Indian mobile numbers: 10 digits, starts with 6-9
    final mobileRegex = RegExp(r'^[6-9]\d{9}$');
    return mobileRegex.hasMatch(cleanMobile);
  }

  /// Set terms and conditions acceptance status
  static Future<void> setTermsAccepted(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_termsAcceptedKey, accepted);
  }
}