import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/alerts_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for handling FCM notifications and navigation
/// Manages how the app responds to incoming push notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static GlobalKey<NavigatorState>? _navigatorKey;
  static WidgetRef? _ref;

  /// Initialize the notification service with navigation key and Riverpod ref
  /// Called from main.dart to set up navigation and state management access
  static void initialize(GlobalKey<NavigatorState> navigatorKey, WidgetRef ref) {
    _navigatorKey = navigatorKey;
    _ref = ref;
  }

  /// Handle notification tap when app is in foreground or background
  /// Navigates to appropriate screen based on notification data
  static Future<void> handleNotificationTap(RemoteMessage message) async {
    final data = message.data;
    
    // Check if this is an alerts-related notification
    if (data['screen'] == 'alerts' || data['type'] == 'new_sos') {
      // Navigate to alerts screen using named route
      _navigatorKey?.currentState?.pushNamed('/alerts');
    }
    
    // Handle the notification data (add to alerts if it's a new SOS)
    await _handleMessageData(data);
  }

  /// Process FCM message data and update app state accordingly
  /// Called for both foreground and background message handling
  static Future<void> _handleMessageData(Map<String, dynamic> data) async {
    // For background messages, we need to create a new ProviderContainer
    // since we don't have access to the widget tree
    ProviderContainer? container;
    WidgetRef? effectiveRef = _ref;
    
    if (_ref == null) {
      container = ProviderContainer();
    }
    
    final messageType = data['type'] as String?;
    
    switch (messageType) {
      case 'sos_alert':  // Updated to match backend message type
        // Parse SOS alert data from FCM payload
        // Safely parse nested JSON fields
        Map<String, dynamic> userInfo = {};
        Map<String, dynamic> location = {};
        
        try {
          if (data['userInfo'] != null) {
            userInfo = data['userInfo'] is String 
                ? jsonDecode(data['userInfo']) 
                : data['userInfo'] as Map<String, dynamic>;
          }
        } catch (e) {
          // Silent error handling
        }
        
        try {
          if (data['location'] != null) {
            location = data['location'] is String 
                ? jsonDecode(data['location']) 
                : data['location'] as Map<String, dynamic>;
          }
        } catch (e) {
          // Silent error handling
        }
        
        final sosAlert = {
          'sos_id': data['alertId'] ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}',
          'name': userInfo['name'] ?? 'Unknown User',
          'approx_loc': location['address'] ?? data['district'] ?? 'Unknown Location',
          'exact_lat': _parseDouble(location['latitude']),
          'exact_lng': _parseDouble(location['longitude']),
          'message': userInfo['message'] ?? 'Emergency assistance needed',
          'mobile_number': userInfo['mobile_number'] ?? '',
          'timestamp': _parseDouble(data['timestamp'])?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
        };
        
        // Add the new alert to our state management
        try {
          if (effectiveRef != null) {
            await effectiveRef.read(activeAlertsProvider.notifier).addAlert(sosAlert);
          } else {
            await _addAlertToStorage(sosAlert);
          }
        } catch (e) {
          await _addAlertToStorage(sosAlert);
        }
        
        // Clean up container if we created one
        if (container != null) {
          container.dispose();
        }
        break;
        
      case 'sos_resolved':
        // Remove resolved SOS from active alerts
        final sosId = data['sos_id'] as String?;
        if (sosId != null) {
          await _ref!.read(activeAlertsProvider.notifier).removeAlert(sosId);
        }
        break;
        
      case 'sos_update':
        // Update existing SOS with new information
        final sosId = data['sos_id'] as String?;
        if (sosId != null) {
          final updates = <String, dynamic>{};
          if (data.containsKey('message')) updates['message'] = data['message'];
          if (data.containsKey('approx_loc')) updates['approx_loc'] = data['approx_loc'];
          
          await _ref!.read(activeAlertsProvider.notifier).updateAlert(sosId, updates);
        }
        break;
        
      default:
        // Unknown message type
    }
  }

  /// Handle foreground messages (when app is open and visible)
  /// Shows in-app notifications and processes the data
  static Future<void> handleForegroundMessage(RemoteMessage message) async {
    // Process the message data
    await _handleMessageData(message.data);
  }

  /// Handle background messages (when app is minimized or closed)
  /// This is called by the top-level function registered in main.dart
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    // Process the background message data
    try {
      await _handleMessageData(message.data);
    } catch (e) {
      // Silent error handling
    }
  }

  /// Safely parse string/number to double for coordinates
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Direct SharedPreferences alert storage for background scenarios
  /// Used when we can't access the main provider container
  static Future<void> _addAlertToStorage(Map<String, dynamic> alert) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing alerts
      final alertsJson = prefs.getStringList('active_alerts') ?? [];
      
      // Add new alert to the beginning
      alertsJson.insert(0, jsonEncode(alert));
      
      // Save back to storage
      await prefs.setStringList('active_alerts', alertsJson);
    } catch (e) {
      // Silent error handling
    }
  }
}