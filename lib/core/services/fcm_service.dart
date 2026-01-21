import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

/// FCM Service for handling push notification topic subscriptions
/// Message handling is managed by NotificationService to avoid conflicts
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  FirebaseMessaging? _firebaseMessaging;
  String? _currentTopic;
  String? _fcmToken;
  bool _isFirebaseAvailable = false;

  /// Initialize FCM service (topic management only)
  Future<void> initialize() async {
    // Check if Firebase is available
    try {
      final apps = Firebase.apps;
      
      if (apps.isNotEmpty) {
        _firebaseMessaging = FirebaseMessaging.instance;
        _isFirebaseAvailable = true;
        
        // Request notification permissions
        await _requestNotificationPermissions();
        
        // Get FCM token
        _fcmToken = await _firebaseMessaging!.getToken()
            .timeout(const Duration(seconds: 5));

        if (kDebugMode) {
          debugPrint('FCMService: Initialized successfully for topic management');
        }
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
    print('FCMService: subscribeToDistrictTopic called with: $district');
    
    if (!_isFirebaseAvailable || _firebaseMessaging == null) {
      print('FCMService: Firebase not available for topic subscription');
      if (kDebugMode) {
        debugPrint('Firebase not available - cannot subscribe to district topic: $district');
      }
      return;
    }
    
    try {
      final topicName = 'district-$district';
      print('FCMService: Topic name: $topicName');
      
      // Unsubscribe from previous topic if exists
      if (_currentTopic != null && _currentTopic != topicName) {
        print('FCMService: Unsubscribing from previous topic: $_currentTopic');
        try {
          await _firebaseMessaging!.unsubscribeFromTopic(_currentTopic!)
              .timeout(const Duration(seconds: 3));
          print('FCMService: Successfully unsubscribed from: $_currentTopic');
        } catch (e) {
          print('FCMService: Unsubscribe timeout/error (continuing): $e');
        }
      }
      
      // Subscribe to new topic with retry logic
      bool subscribed = false;
      int attempts = 0;
      const maxAttempts = 2;
      
      while (!subscribed && attempts < maxAttempts) {
        attempts++;
        print('FCMService: Subscribe attempt $attempts/$maxAttempts for: $topicName');
        
        try {
          await _firebaseMessaging!.subscribeToTopic(topicName)
              .timeout(const Duration(seconds: 4));
          
          _currentTopic = topicName;
          subscribed = true;
          print('FCMService: Successfully subscribed to: $topicName');
          
        } catch (e) {
          print('FCMService: Subscribe attempt $attempts failed: $e');
          if (attempts >= maxAttempts) {
            print('FCMService: All subscription attempts failed, giving up');
          }
          // Wait a bit before retry
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
      
      if (kDebugMode && subscribed) {
        debugPrint('Subscribed to topic: $topicName');
      }
    } catch (e) {
      print('FCMService: Error in subscribeToDistrictTopic: $e');
      print('FCMService: Error type: ${e.runtimeType}');
      debugPrint('Error subscribing to district topic: $e');
      // Don't rethrow - let the app continue
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
        print('FCMService: Unsubscribing from current topic: $_currentTopic');
        await _firebaseMessaging!.unsubscribeFromTopic(_currentTopic!);
        _currentTopic = null;
        print('FCMService: Successfully unsubscribed from topic');
      } catch (e) {
        print('FCMService: Error unsubscribing from topic: $e');
      }
    }
  }

  /// Request notification permissions
  Future<void> _requestNotificationPermissions() async {
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

  /// Get FCM token for this device
  String? get fcmToken => _fcmToken;

  /// Get current subscribed topic
  String? get currentTopic => _currentTopic;
}