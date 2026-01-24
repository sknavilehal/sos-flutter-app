import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/alerts_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/user_id_service.dart';

/// Service for handling FCM notifications and navigation
/// Manages how the app responds to incoming push notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static GlobalKey<NavigatorState>? _navigatorKey;
  static WidgetRef? _ref;
  static bool _initialized = false;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// Initialize the notification service with navigation key and Riverpod ref
  /// Called from main.dart to set up navigation and state management access
  static Future<void> initialize(GlobalKey<NavigatorState> navigatorKey, WidgetRef ref) async {
    debugPrint('🔔 NotificationService: Initializing...');
    _navigatorKey = navigatorKey;
    _ref = ref;
    
    if (!_initialized) {
      await _initializeLocalNotifications();
      _setupMessageHandlers();
      _initialized = true;
      debugPrint('🔔 NotificationService: Initialization complete');
    }
  }
  
  /// Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    debugPrint('🔔 NotificationService: Setting up local notifications...');
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    debugPrint('🔔 NotificationService: Local notifications initialized');
  }
  
  /// Setup FCM message handlers
  static void _setupMessageHandlers() {
    debugPrint('🔔 NotificationService: Setting up FCM message handlers...');
    
    try {
      // Handle messages when app is in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('🔔 NotificationService: Received foreground message: ${message.messageId}');
        _handleForegroundMessageWithNotification(message);
      });
      
      // Handle messages when app is in background but not terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('🔔 NotificationService: App opened from background message: ${message.messageId}');
        handleNotificationTap(message);
      });
      
      // ✅ Handle messages when app is opened from terminated state
      handleTerminatedMessage();
      
      debugPrint('🔔 NotificationService: FCM message handlers set up successfully');
    } catch (e) {
      debugPrint('🔔 NotificationService: Error setting up message handlers: $e');
    }
  }

  /// Handle foreground messages with local notification display
  static Future<void> _handleForegroundMessageWithNotification(RemoteMessage message) async {
    debugPrint('🔔 NotificationService: Processing foreground message...');
    debugPrint('🔔 NotificationService: Message data: ${message.data}');
    debugPrint('🔔 NotificationService: Message title: ${message.notification?.title}');
    debugPrint('🔔 NotificationService: Message body: ${message.notification?.body}');
    
    // ✅ Client-side filtering: Check if this is a self-sent SOS alert
    final messageSenderId = message.data['sender_id'];
    if (messageSenderId != null) {
      final currentUserId = await UserIdService.getUserId();
      
      if (messageSenderId == currentUserId) {
        debugPrint('🚫 NotificationService: Completely filtering out self-sent SOS alert (sender: $messageSenderId)');
        debugPrint('🚫 NotificationService: Self-alert wRill NOT be added to alerts screen or shown as notification');
        // Process the message data first
        
        return;
      }
    }
    
    // Process the message data first
    await handleForegroundMessage(message);
    
    // Show local notification
    await _showLocalNotification(message);
  }
  
  /// Show local notification for foreground messages
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    debugPrint('🔔 NotificationService: Showing local notification...');
    
    const androidDetails = AndroidNotificationDetails(
      'sos_alerts',
      'SOS Alerts',
      channelDescription: 'Emergency SOS alert notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      final title = message.notification?.title ?? 'SOS Alert';
      final body = message.notification?.body ?? message.data['message'] ?? 'Emergency alert in your area';
      
      debugPrint('🔔 NotificationService: Notification title: $title');
      debugPrint('🔔 NotificationService: Notification body: $body');
      
      await _localNotifications.show(
        message.hashCode,
        title,
        body,
        notificationDetails,
        payload: message.data.toString(),
      );
      
      debugPrint('🔔 NotificationService: Local notification displayed successfully');
    } catch (e) {
      debugPrint('🔔 NotificationService: Error showing local notification: $e');
    }
  }
  
  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 NotificationService: Notification tapped: ${response.payload}');
    
    // Navigate to alerts screen
    _navigatorKey?.currentState?.pushNamed('/alerts');
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
    // For background messages, we need to use storage fallback
    WidgetRef? effectiveRef = _ref;
    
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
          if (effectiveRef != null && _ref != null) {
            // Use main ref if available
            await effectiveRef.read(activeAlertsProvider.notifier).addAlert(sosAlert);
          } else {
            // Fallback to storage for background scenarios
            await _addAlertToStorage(sosAlert);
          }
        } catch (e) {
          // Always fallback to storage if state management fails
          await _addAlertToStorage(sosAlert);
        }
        
        break;
        
      case 'sos_resolved':
        // Remove resolved SOS from active alerts
        final sosId = data['sos_id'] as String?;
        if (sosId != null) {
          try {
            if (_ref != null) {
              await _ref!.read(activeAlertsProvider.notifier).removeAlert(sosId);
            } else {
              await _removeAlertFromStorage(sosId);
            }
          } catch (e) {
            await _removeAlertFromStorage(sosId);
          }
        }
        break;
        
      case 'sos_update':
        // Update existing SOS with new information
        final sosId = data['sos_id'] as String?;
        if (sosId != null) {
          try {
            if (_ref != null) {
              final updates = <String, dynamic>{};
              if (data.containsKey('message')) updates['message'] = data['message'];
              if (data.containsKey('approx_loc')) updates['approx_loc'] = data['approx_loc'];
              
              await _ref!.read(activeAlertsProvider.notifier).updateAlert(sosId, updates);
            }
          } catch (e) {
            // Silent error handling for background scenarios
          }
        }
        break;
        
      default:
        // Unknown message type
    }
    
  }

  /// Handle foreground messages (when app is open and visible)
  /// Shows in-app notifications and processes the data
  static Future<void> handleForegroundMessage(RemoteMessage message) async {
    debugPrint('🔔 NotificationService: handleForegroundMessage called');
    debugPrint('🔔 NotificationService: Processing message data...');
    
    // Process the message data
    await _handleMessageData(message.data);
    
    debugPrint('🔔 NotificationService: Foreground message processing complete');
  }

  /// Handle background messages (when app is minimized or closed)
  /// This is called by the top-level function registered in main.dart
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('🔔 NotificationService: handleBackgroundMessage called');
    debugPrint('🔔 NotificationService: Background message data: ${message.data}');
    
    // Process the background message data
    try {
      await _handleMessageData(message.data);
      debugPrint('🔔 NotificationService: Background message processing complete');
    } catch (e) {
      debugPrint('🔔 NotificationService: Error processing background message: $e');
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

  /// Handle messages when app is opened from terminated state
  static Future<void> handleTerminatedMessage() async {
    try {
      final message = await FirebaseMessaging.instance.getInitialMessage();
      if (message != null) {
        debugPrint('🔔 NotificationService: App opened from terminated state with message: ${message.messageId}');
        
        // Check for sender filtering
        final messageSenderId = message.data['sender_id'];
        if (messageSenderId != null) {
          final currentUserId = await UserIdService.getUserId();
          
          if (messageSenderId == currentUserId) {
            debugPrint('🚫 NotificationService: Filtering out self-sent alert from terminated state');
            return;
          }
        }
        
        await handleNotificationTap(message);
      }
    } catch (e) {
      debugPrint('🔔 NotificationService: Error handling terminated message: $e');
    }
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

  /// Remove alert from SharedPreferences storage for background scenarios
  static Future<void> _removeAlertFromStorage(String sosId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing alerts
      final alertsJson = prefs.getStringList('active_alerts') ?? [];
      
      // Remove alert with matching SOS ID
      alertsJson.removeWhere((alertString) {
        try {
          final alert = jsonDecode(alertString);
          return alert['sos_id'] == sosId;
        } catch (e) {
          return false;
        }
      });
      
      // Save back to storage
      await prefs.setStringList('active_alerts', alertsJson);
    } catch (e) {
      // Silent error handling
    }
  }
}