import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State notifier for managing active SOS alerts
/// This provider manages the list of active emergency alerts received via FCM
class ActiveAlertsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ActiveAlertsNotifier() : super([]) {
    // Schedule async loading to avoid modifying state during construction
    Future.microtask(() => _loadAlertsFromStorage());
  }

  static const String _alertsKey = 'active_alerts';
  static const int _alertTTLHours = 1; // Alerts expire after 1 hour

  /// Load alerts from SharedPreferences on app start
  /// Automatically filters out expired alerts based on timestamp
  Future<void> _loadAlertsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = prefs.getStringList(_alertsKey) ?? [];
      
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final validAlerts = <Map<String, dynamic>>[];
      
      // Parse each stored alert and check if it's still valid (not expired)
      for (final alertJson in alertsJson) {
        try {
          final alert = jsonDecode(alertJson) as Map<String, dynamic>;
          final alertTimestamp = alert['timestamp'] as int? ?? 0;
          
          // Check if alert is within TTL (Time To Live)
          final alertAge = Duration(milliseconds: currentTime - alertTimestamp);
          
          if (alertAge.inHours < _alertTTLHours) {
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

  /// Manually remove expired alerts
  /// TODO: Implement automatic background cleanup timer
  Future<void> removeExpiredAlerts() async {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    
    state = state.where((alert) {
      final alertTimestamp = alert['timestamp'] as int? ?? 0;
      final alertAge = Duration(milliseconds: currentTime - alertTimestamp);
      return alertAge.inHours < _alertTTLHours;
    }).toList();
    
    await _saveAlertsToStorage();
  }

}

/// Provider for accessing active SOS alerts throughout the app
/// This is the main interface for reading alert state in UI components
final activeAlertsProvider = StateNotifierProvider<ActiveAlertsNotifier, List<Map<String, dynamic>>>((ref) {
  return ActiveAlertsNotifier();
});