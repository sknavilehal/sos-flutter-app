import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/providers/location_provider.dart';
import '../core/config/api_config.dart';
import '../core/services/location_service.dart';

/// Service to handle district-based FCM subscriptions for emergency alerts
class DistrictSubscriptionService {
  static const String _lastDistrictKey = 'last_subscribed_district';
  static const String _lastSubscriptionTimeKey = 'last_subscription_time';
  
  /// Get district information from backend based on coordinates
  Future<String?> getDistrictFromLocation(double latitude, double longitude) async {
    try {
      debugPrint('🗺️ Getting district for coordinates: ($latitude, $longitude)');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/get-district'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      debugPrint('District API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['district'] != null) {
          final district = data['district'] as String;
          debugPrint('✅ District determined: $district');
          return district;
        }
      }
      
      debugPrint('❌ Failed to get district: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('❌ District lookup error: $e');
      return null;
    }
  }
  
  /// Subscribe to FCM topic for a specific district
  Future<bool> subscribeToDistrict(String district) async {
    try {
      final topic = 'district-$district';
      debugPrint('📱 Subscribing to FCM topic: $topic');
      
      debugPrint('🔄 Calling FirebaseMessaging.subscribeToTopic...');
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      debugPrint('✅ FirebaseMessaging.subscribeToTopic completed successfully');
      
      // Save subscription info
      debugPrint('💾 Saving subscription info to SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastDistrictKey, district);
      await prefs.setInt(_lastSubscriptionTimeKey, DateTime.now().millisecondsSinceEpoch);
      debugPrint('💾 Subscription info saved successfully');
      
      print('✅ Successfully subscribed to district: $district');
      return true;
    } catch (e) {
      print('❌ Failed to subscribe to district $district: $e');
      return false;
    }
  }
  
  /// Unsubscribe from FCM topic for a specific district
  Future<bool> unsubscribeFromDistrict(String district) async {
    try {
      final topic = 'district-$district';
      print('📱 Unsubscribing from FCM topic: $topic');
      
      debugPrint('🔄 Calling FirebaseMessaging.unsubscribeFromTopic...');
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      debugPrint('✅ FirebaseMessaging.unsubscribeFromTopic completed successfully');
      
      print('✅ Successfully unsubscribed from district: $district');
      return true;
    } catch (e) {
      print('❌ Failed to unsubscribe from district $district: $e');
      return false;
    }
  }
  
  /// Get the last subscribed district from preferences
  Future<String?> getLastSubscribedDistrict() async {
    try {
      debugPrint('📂 Getting last subscribed district from SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final lastDistrict = prefs.getString(_lastDistrictKey);
      debugPrint('📂 Last subscribed district: ${lastDistrict ?? "none"}');
      return lastDistrict;
    } catch (e) {
      print('❌ Failed to get last subscribed district: $e');
      return null;
    }
  }
  
  /// Check if subscription is recent (within last hour)
  Future<bool> isSubscriptionRecent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastTime = prefs.getInt(_lastSubscriptionTimeKey);
      if (lastTime == null) return false;
      
      final now = DateTime.now().millisecondsSinceEpoch;
      const oneHourInMs = 60 * 60 * 1000;
      
      return (now - lastTime) < oneHourInMs;
    } catch (e) {
      debugPrint('❌ Failed to check subscription time: $e');
      return false;
    }
  }
  
  /// Main function to update district subscription based on current location
  Future<bool> updateDistrictSubscription(LocationService locationService) async {
    try {
      debugPrint('🔄 Updating district subscription...');
      
      // Check if we have a recent subscription to avoid frequent updates
      if (await isSubscriptionRecent()) {
        debugPrint('📍 District subscription is recent, skipping update');
        return true;
      }
      
      // Get current location
      debugPrint('📍 Getting current location for district subscription...');
      final locationData = await locationService.getCurrentLocation();
      if (locationData == null) {
        debugPrint('❌ Cannot get current location for district subscription');
        return false;
      }
      debugPrint('📍 Location obtained: (${locationData.latitude}, ${locationData.longitude})');
      
      // Get district from backend
      final newDistrict = await getDistrictFromLocation(
        locationData.latitude, 
        locationData.longitude
      );
      
      if (newDistrict == null) {
        debugPrint('❌ Cannot determine district from location');
        return false;
      }
      
      // Check if we need to change subscription
      debugPrint('🔍 Checking if subscription needs to be changed...');
      final lastDistrict = await getLastSubscribedDistrict();
      debugPrint('🔍 Comparison: Last="${lastDistrict ?? "none"}", New="$newDistrict"');
      
      if (lastDistrict == newDistrict) {
        debugPrint('📍 Already subscribed to correct district: $newDistrict');
        // Update timestamp to mark as recent
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_lastSubscriptionTimeKey, DateTime.now().millisecondsSinceEpoch);
        debugPrint('⏰ Updated subscription timestamp');
        return true;
      }
      
      // Unsubscribe from old district if exists
      if (lastDistrict != null) {
        debugPrint('🔄 Unsubscribing from old district: $lastDistrict');
        await unsubscribeFromDistrict(lastDistrict);
      }
      
      // Subscribe to new district
      final subscribed = await subscribeToDistrict(newDistrict);
      
      if (subscribed) {
        debugPrint('✅ District subscription updated successfully: $newDistrict');
        return true;
      } else {
        debugPrint('❌ Failed to subscribe to new district: $newDistrict');
        return false;
      }
      
    } catch (e) {
      debugPrint('❌ District subscription update error: $e');
      return false;
    }
  }
  
  /// Initialize district subscription on app start
  Future<void> initializeDistrictSubscription(LocationService locationService) async {
    debugPrint('🚀 Initializing district subscription...');
    
    // Wait a bit to ensure location services are ready
    await Future.delayed(const Duration(seconds: 2));
    
    final success = await updateDistrictSubscription(locationService);
    
    if (success) {
      debugPrint('✅ District subscription initialized successfully');
    } else {
      debugPrint('⚠️ District subscription initialization failed, will retry later');
    }
  }
}