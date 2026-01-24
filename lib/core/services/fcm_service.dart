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

      }
    } catch (e) {
      debugPrint('FCM initialization failed: $e');
    }
  }

  /// Subscribe to district topic
  Future<void> subscribeToDistrictTopic(String district) async {
    if (!_isFirebaseAvailable || _firebaseMessaging == null) {
      return;
    }
    
    try {
      final topicName = 'district-$district';
      
      // Unsubscribe from previous topic if exists
      if (_currentTopic != null && _currentTopic != topicName) {
        try {
          await _firebaseMessaging!.unsubscribeFromTopic(_currentTopic!)
              .timeout(const Duration(seconds: 3));
        } catch (e) {
          debugPrint('FCM unsubscribe failed: $e');
        }
      }
      
      // Subscribe to new topic with retry logic
      bool subscribed = false;
      int attempts = 0;
      const maxAttempts = 2;
      
      while (!subscribed && attempts < maxAttempts) {
        attempts++;
        
        try {
          await _firebaseMessaging!.subscribeToTopic(topicName)
              .timeout(const Duration(seconds: 4));
          
          _currentTopic = topicName;
          subscribed = true;
          
        } catch (e) {
          // Wait a bit before retry
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
      
      if (!subscribed) {
        debugPrint('FCM subscribe failed for topic: $topicName');
      }
    } catch (e) {
      debugPrint('FCM subscribe failed: $e');
      // Don't rethrow - let the app continue
    }
  }

  /// Unsubscribe from current district topic
  Future<void> unsubscribeFromCurrentTopic() async {
    if (!_isFirebaseAvailable || _firebaseMessaging == null) {
      return;
    }

    if (_currentTopic != null) {
      try {
        await _firebaseMessaging!.unsubscribeFromTopic(_currentTopic!);
        _currentTopic = null;
      } catch (e) {
        debugPrint('FCM unsubscribe failed: $e');
      }
    }
  }

  /// Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    await _firebaseMessaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  /// Get FCM token for this device
  String? get fcmToken => _fcmToken;

  /// Get current subscribed topic
  String? get currentTopic => _currentTopic;
}