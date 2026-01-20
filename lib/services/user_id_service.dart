import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing unique user identification for SOS filtering
/// Generates and persists a unique ID to prevent users from receiving their own SOS alerts
class UserIdService {
  static const String _userIdKey = 'unique_user_id';
  
  /// Get or generate a unique user ID
  /// This ID is used to identify SOS senders and filter out self-notifications
  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if we already have a stored user ID
    String? existingId = prefs.getString(_userIdKey);
    
    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }
    
    // Generate a new unique ID
    final String newId = _generateUniqueId();
    
    // Store it for future use
    await prefs.setString(_userIdKey, newId);
    
    return newId;
  }
  
  /// Generate a random unique ID
  /// Format: user_[timestamp]_[random]
  static String _generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'user_${timestamp}_$random';
  }
  
  /// Clear stored user ID (for testing purposes)
  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }
}
