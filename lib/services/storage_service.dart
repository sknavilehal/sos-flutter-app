import '../models/user_profile.dart';

/// Abstract storage service interface
/// This allows switching between SQLite, SharedPreferences, Firestore, etc.
abstract class StorageService {
  /// Initialize the storage service
  Future<void> initialize();
  
  /// User Profile Operations
  Future<void> saveUserProfile(UserProfile profile);
  Future<UserProfile?> getUserProfile();
  Future<void> updateUserProfile(UserProfile profile);
  Future<void> deleteUserProfile();
  
  /// Alerts Operations (temporary storage for MVP)
  Future<void> saveAlert(Map<String, dynamic> alert);
  Future<List<Map<String, dynamic>>> getAlerts();
  Future<void> deleteAlert(String alertId);
  Future<void> clearAllAlerts();
}

/// SQLite implementation of StorageService
class SQLiteStorageService implements StorageService {
  // TODO: Implement SQLite logic using sqflite package
  
  @override
  Future<void> initialize() async {
    // Initialize SQLite database and create tables
    throw UnimplementedError('SQLite initialization implementation pending');
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    throw UnimplementedError('Save user profile implementation pending');
  }

  @override
  Future<UserProfile?> getUserProfile() async {
    throw UnimplementedError('Get user profile implementation pending');
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    throw UnimplementedError('Update user profile implementation pending');
  }

  @override
  Future<void> deleteUserProfile() async {
    throw UnimplementedError('Delete user profile implementation pending');
  }

  @override
  Future<void> saveAlert(Map<String, dynamic> alert) async {
    throw UnimplementedError('Save alert implementation pending');
  }

  @override
  Future<List<Map<String, dynamic>>> getAlerts() async {
    throw UnimplementedError('Get alerts implementation pending');
  }

  @override
  Future<void> deleteAlert(String alertId) async {
    throw UnimplementedError('Delete alert implementation pending');
  }

  @override
  Future<void> clearAllAlerts() async {
    throw UnimplementedError('Clear all alerts implementation pending');
  }
}