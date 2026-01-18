import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

/// FCM Service for handling push notifications and topic subscriptions
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  FirebaseMessaging? _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  String? _currentTopic;
  String? _fcmToken;
  bool _isFirebaseAvailable = false;

  /// Initialize FCM service
  Future<void> initialize() async {
    // Check if Firebase is available
    try {
      final apps = Firebase.apps;
      if (apps.isNotEmpty) {
        _firebaseMessaging = FirebaseMessaging.instance;
        _isFirebaseAvailable = true;
        
        // Request notification permissions
        await _requestNotificationPermissions();
        
        // Initialize local notifications
        await _initializeLocalNotifications();
        
        // Get FCM token
        _fcmToken = await _firebaseMessaging!.getToken();
        if (kDebugMode) {
          debugPrint('FCM Token: $_fcmToken');
        }

        // Set up message handlers
        _setupMessageHandlers();
      } else {
        if (kDebugMode) {
          debugPrint('Firebase not available - FCM features disabled');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize FCM: $e');
      }
    }
  }

  /// Subscribe to district topic
  Future<void> subscribeToDistrictTopic(String district) async {
    if (!_isFirebaseAvailable || _firebaseMessaging == null) {
      if (kDebugMode) {
        debugPrint('Firebase not available - cannot subscribe to district topic: $district');
      }
      return;
    }
    
    try {
      final topicName = 'district-$district';
      
      // Unsubscribe from previous topic if exists
      if (_currentTopic != null && _currentTopic != topicName) {
        await _firebaseMessaging!.unsubscribeFromTopic(_currentTopic!);
        if (kDebugMode) {
          print('Unsubscribed from topic: $_currentTopic');
        }
      }
      
      // Subscribe to new topic
      await _firebaseMessaging!.subscribeToTopic(topicName);
      _currentTopic = topicName;
      
      if (kDebugMode) {
        debugPrint('Subscribed to topic: $topicName');
      }
    } catch (e) {
      debugPrint('Error subscribing to district topic: $e');
    }
  }

  /// Unsubscribe from current district topic
  Future<void> unsubscribeFromCurrentTopic() async {
    if (!_isFirebaseAvailable || _firebaseMessaging == null) {
      if (kDebugMode) {
        debugPrint('Firebase not available - cannot unsubscribe from topic');
      }
      return;
    }
    
    if (_currentTopic != null) {
      try {
        await _firebaseMessaging!.unsubscribeFromTopic(_currentTopic!);
        if (kDebugMode) {
          debugPrint('Unsubscribed from topic: $_currentTopic');
        }
        _currentTopic = null;
      } catch (e) {
        debugPrint('Error unsubscribing from topic: $e');
      }
    }
  }

  /// Get current FCM token
  String? get fcmToken => _fcmToken;
  
  /// Get current subscribed topic
  String? get currentTopic => _currentTopic;

  /// Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    if (!_isFirebaseAvailable || _firebaseMessaging == null) {
      return;
    }
    
    final settings = await _firebaseMessaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      debugPrint('Notification permission status: ${settings.authorizationStatus}');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
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
  }

  /// Setup message handlers for different states
  void _setupMessageHandlers() {
    if (!_isFirebaseAvailable || _firebaseMessaging == null) {
      return;
    }
    
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle messages when app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    
    // Handle messages when app is opened from terminated state
    _handleTerminatedMessage();
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('Foreground message received: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    // Show local notification for foreground messages
    await _showLocalNotification(message);
  }

  /// Handle background messages
  void _handleBackgroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Background message tapped: ${message.messageId}');
    }
    
    // Navigate to alerts screen or specific alert
    _navigateToAlert(message.data);
  }

  /// Handle messages when app is opened from terminated state
  void _handleTerminatedMessage() {
    if (!_isFirebaseAvailable || _firebaseMessaging == null) {
      return;
    }
    
    _firebaseMessaging!.getInitialMessage().then((message) {
      if (message != null) {
        if (kDebugMode) {
          print('Terminated message opened: ${message.messageId}');
        }
        _navigateToAlert(message.data);
      }
    });
  }

  /// Show local notification for foreground messages
  Future<void> _showLocalNotification(RemoteMessage message) async {
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

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'SOS Alert',
      message.notification?.body ?? 'Emergency alert in your area',
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
    
    // Navigate to alerts screen
    // This will be implemented when we integrate with navigation
  }

  /// Navigate to specific alert
  void _navigateToAlert(Map<String, dynamic> data) {
    // TODO: Implement navigation to alert details
    // This will be integrated with the navigation system
    if (kDebugMode) {
      print('Navigate to alert: $data');
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Background message received: ${message.messageId}');
  }
  
  // Handle background message
  // Note: Keep this function minimal as it runs in a separate isolate
}