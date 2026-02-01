import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/profile_service.dart';
import '../constants/app_constants.dart';

/// State notifier for managing active SOS alerts
/// This provider manages the list of active emergency alerts received via FCM
class ActiveAlertsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  Timer? _cleanupTimer;
  Timer? _expiryTimer;
  
  ActiveAlertsNotifier() : super([]) {
    // Schedule async loading to avoid modifying state during construction
    Future.microtask(() async {
      await _loadAlertsFromStorage();
    });
    // Start automatic background cleanup timer (checks every 5 minutes)
    _startCleanupTimer();
  }

  static const String _alertsKey = 'active_alerts';
  static const Duration _alertTtl = AppConstants.alertTtl;
  static const Duration _cleanupInterval = Duration(minutes: 5); // Check every 5 minutes

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
    _expiryTimer?.cancel();
    super.dispose();
  }

  int _parseTimestampMillis(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) {
      final parsedInt = int.tryParse(value);
      if (parsedInt != null) return parsedInt;
      final parsedDouble = double.tryParse(value);
      if (parsedDouble != null) return parsedDouble.toInt();
    }
    return 0;
  }

  void _scheduleNextExpiry() {
    _expiryTimer?.cancel();
    if (state.isEmpty) {
      return;
    }

    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    int? nextExpiryMillis;

    for (final alert in state) {
      final timestampMillis = _parseTimestampMillis(alert['timestamp']);
      final expiresAt = timestampMillis + _alertTtl.inMilliseconds;

      if (expiresAt <= nowMillis) {
        nextExpiryMillis = nowMillis;
        break;
      }

      if (nextExpiryMillis == null || expiresAt < nextExpiryMillis) {
        nextExpiryMillis = expiresAt;
      }
    }

    if (nextExpiryMillis == null) {
      return;
    }

    final delayMillis = nextExpiryMillis - nowMillis;
    final delay = Duration(milliseconds: delayMillis > 0 ? delayMillis : 0);
    _expiryTimer = Timer(delay, () {
      removeExpiredAlerts();
    });
  }

  /// Load alerts from SharedPreferences on app start
  /// Automatically filters out expired alerts based on timestamp
  Future<void> _loadAlertsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // CRITICAL: Reload from disk to get updates from background isolate
      // Background handler writes in separate isolate, main app cache may be stale
      await prefs.reload();
      
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
          final alertTimestamp = _parseTimestampMillis(alert['timestamp']);
          final alertSosId = alert['sos_id'] as String?;
          
          // Skip user's own alerts
          if (alertSosId == userSosId) {
            continue;
          }
          
          // Check if alert is within TTL (Time To Live)
          final alertAge = Duration(milliseconds: currentTime - alertTimestamp);
          
          if (alertAge < _alertTtl) {
            validAlerts.add(alert);
          }
        } catch (e) {
          // Skip malformed alerts
        }
      }
      
      state = validAlerts;
      _scheduleNextExpiry();
    } catch (e) {
      // Handle any errors during loading gracefully
      debugPrint('Failed to load stored alerts: $e');
      state = [];
      _scheduleNextExpiry();
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
    _scheduleNextExpiry();
  }

  /// Remove a specific alert by SOS ID
  /// Called when an alert is resolved or manually dismissed
  Future<void> removeAlert(String sosId) async {
    state = state.where((alert) => alert['sos_id'] != sosId).toList();
    await _saveAlertsToStorage();
    _scheduleNextExpiry();
  }

  /// Clear all alerts (debug-only action in UI)
  Future<void> clearAllAlerts() async {
    state = [];
    await _saveAlertsToStorage();
    _scheduleNextExpiry();
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
    _scheduleNextExpiry();
  }

  /// Automatically remove expired alerts
  /// Called periodically by background timer and on app start
  Future<void> removeExpiredAlerts() async {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final initialCount = state.length;
    
    state = state.where((alert) {
      final alertTimestamp = _parseTimestampMillis(alert['timestamp']);
      final alertAge = Duration(milliseconds: currentTime - alertTimestamp);
      final isValid = alertAge < _alertTtl;
      
      return isValid;
    }).toList();
    
    // Only save if alerts were actually removed
    if (state.length != initialCount) {
      await _saveAlertsToStorage();
    }
    _scheduleNextExpiry();
  }

}

/// Provider for accessing active SOS alerts throughout the app
/// This is the main interface for reading alert state in UI components
final activeAlertsProvider = StateNotifierProvider<ActiveAlertsNotifier, List<Map<String, dynamic>>>((ref) {
  return ActiveAlertsNotifier();
});