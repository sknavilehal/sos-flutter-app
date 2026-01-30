import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/profile_service.dart';

/// State notifier for managing active SOS alerts
/// This provider manages the list of active emergency alerts received via FCM
class ActiveAlertsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  Timer? _cleanupTimer;
  
  ActiveAlertsNotifier() : super([]) {
    // Schedule async loading to avoid modifying state during construction
    Future.microtask(() async {
      await _loadAlertsFromStorage();
      // Add debug placeholder alert in debug mode for TTL testing
      if (kDebugMode) {
        _addDebugPlaceholderAlert();
      }
    });
    // Start automatic background cleanup timer (checks every 5 minutes)
    _startCleanupTimer();
  }

  static const String _alertsKey = 'active_alerts';
  static const double _alertTTLHours = 1.5; // 1.5 hours
  static const Duration _cleanupInterval = Duration(minutes: 5); // Check every 5 minutes

  /// Add a debug placeholder alert for testing TTL functionality
  /// Only called in debug mode to test alert expiration
  void _addDebugPlaceholderAlert() {
    final debugAlert = {
      'name': 'Debug Test User',
      'mobile_number': '+1234567890',
      'approx_loc': 'Sample Location, Debug City',
      'exact_lat': 12.9716,
      'exact_lng': 77.5946,
      'message': 'This is a placeholder alert for debug mode testing. Should disappear in 1 minute.',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'sos_id': 'debug_placeholder_alert', // Unique ID for debug alert
    };
    
    state = [debugAlert, ...state];
  }

  /// Start automatic background cleanup timer
  /// Periodically removes expired alerts without manual intervention
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(_cleanupInterval, (timer) {
      removeExpiredAlerts();
    });
  }

  /// Stop the cleanup timer (called on dispose)
  @override
  void dispose() {
    _cleanupTimer?.cancel();
    super.dispose();
  }

  /// Load alerts from SharedPreferences on app start
  /// Automatically filters out expired alerts based on timestamp
  Future<void> _loadAlertsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = prefs.getStringList(_alertsKey) ?? [];
      
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final validAlerts = <Map<String, dynamic>>[];
      
      // Get user's SOS ID to filter out their own alerts
      final userId = await ProfileService.getUserId();
      final userSosId = 'sos_$userId';
      
      // Parse each stored alert and check if it's still valid (not expired)
      for (final alertJson in alertsJson) {
        try {
          final alert = jsonDecode(alertJson) as Map<String, dynamic>;
          final alertTimestamp = alert['timestamp'] as int? ?? 0;
          final alertSosId = alert['sos_id'] as String?;
          
          // Skip user's own alerts
          if (alertSosId == userSosId) {
            continue;
          }
          
          // Check if alert is within TTL (Time To Live)
          final alertAge = Duration(milliseconds: currentTime - alertTimestamp);
          
          if (alertAge.inMinutes < (_alertTTLHours * 60)) {
            validAlerts.add(alert);
          }
        } catch (e) {
          // Skip malformed alerts
        }
      }
      
      state = validAlerts;
    } catch (e) {
      // Handle any errors during loading gracefully
      debugPrint('Failed to load stored alerts: $e');
      state = [];
    }
  }

  /// Save current alerts to SharedPreferences for persistence
  /// This ensures alerts survive app restarts within the TTL period
  Future<void> _saveAlertsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = state.map((alert) => jsonEncode(alert)).toList();
      await prefs.setStringList(_alertsKey, alertsJson);
    } catch (e) {
      // Silent error handling
    }
  }

  /// Add a new SOS alert to the active list
  /// Called when a new FCM notification is received
  Future<void> addAlert(Map<String, dynamic> alert) async {
    // Add timestamp for TTL tracking if not present
    if (!alert.containsKey('timestamp')) {
      alert['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    }
    
    // Prevent duplicate alerts by checking SOS ID
    final sosId = alert['sos_id'] as String?;
    if (sosId != null && state.any((a) => a['sos_id'] == sosId)) {
      return; // Alert already exists
    }
    
    // Don't show user's own SOS alerts to themselves
    if (sosId != null) {
      final userId = await ProfileService.getUserId();
      final userSosId = 'sos_$userId';
      if (sosId == userSosId) {
        debugPrint('Ignoring own SOS alert: $sosId');
        return; // Don't add user's own alert
      }
    }
    
    // Add alert to the beginning of the list (newest first)
    state = [alert, ...state];
    await _saveAlertsToStorage();
  }

  /// Remove a specific alert by SOS ID
  /// Called when an alert is resolved or manually dismissed
  Future<void> removeAlert(String sosId) async {
    state = state.where((alert) => alert['sos_id'] != sosId).toList();
    await _saveAlertsToStorage();
  }

  /// Force reload alerts from SharedPreferences
  /// Useful when alerts are added from background/external processes
  Future<void> refreshFromStorage() async {
    await _loadAlertsFromStorage();
  }

  /// Update an existing alert with new information
  /// Useful for status updates or additional messages
  Future<void> updateAlert(String sosId, Map<String, dynamic> updates) async {
    state = state.map((alert) {
      if (alert['sos_id'] == sosId) {
        return {...alert, ...updates};
      }
      return alert;
    }).toList();
    await _saveAlertsToStorage();
  }

  /// Automatically remove expired alerts
  /// Called periodically by background timer and on app start
  Future<void> removeExpiredAlerts() async {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final initialCount = state.length;
    
    state = state.where((alert) {
      final alertTimestamp = alert['timestamp'] as int? ?? 0;
      final alertAge = Duration(milliseconds: currentTime - alertTimestamp);
      final ageInMinutes = alertAge.inMinutes;
      final ttlMinutes = _alertTTLHours * 60;
      final isValid = ageInMinutes < ttlMinutes;
      
      return isValid;
    }).toList();
    
    // Only save if alerts were actually removed
    if (state.length != initialCount) {
      await _saveAlertsToStorage();
    }
  }

}

/// Provider for accessing active SOS alerts throughout the app
/// This is the main interface for reading alert state in UI components
final activeAlertsProvider = StateNotifierProvider<ActiveAlertsNotifier, List<Map<String, dynamic>>>((ref) {
  return ActiveAlertsNotifier();
});