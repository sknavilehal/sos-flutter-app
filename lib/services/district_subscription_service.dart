import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/api_config.dart';
import '../core/services/location_service.dart';

/// Service to handle district-based FCM subscriptions for emergency alerts
class DistrictSubscriptionService {
  static const String _lastDistrictKey = 'last_subscribed_district';
  static const String _lastSubscriptionTimeKey = 'last_subscription_time';
  
  /// Get district information from backend based on coordinates
  Future<String?> getDistrictFromLocation(double latitude, double longitude) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/get-district'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['district'] != null) {
          final district = data['district'] as String;
          return district;
        }
        return null;
      }
      debugPrint('District lookup failed: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('District lookup failed: $e');
      return null;
    }
  }
  
  /// Subscribe to FCM topic for a specific district
  Future<bool> subscribeToDistrict(String district) async {
    try {
      final topic = 'district-$district';
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      
      // Save subscription info
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastDistrictKey, district);
      await prefs.setInt(_lastSubscriptionTimeKey, DateTime.now().millisecondsSinceEpoch);
      
      return true;
    } catch (e) {
      debugPrint('District subscribe failed for $district: $e');
      return false;
    }
  }
  
  /// Unsubscribe from FCM topic for a specific district
  Future<bool> unsubscribeFromDistrict(String district) async {
    try {
      final topic = 'district-$district';
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      return true;
    } catch (e) {
      debugPrint('District unsubscribe failed for $district: $e');
      return false;
    }
  }
  
  /// Get the last subscribed district from preferences
  Future<String?> getLastSubscribedDistrict() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDistrict = prefs.getString(_lastDistrictKey);
      return lastDistrict;
    } catch (e) {
      debugPrint('Failed to read last district: $e');
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
      debugPrint('Failed to check subscription time: $e');
      return false;
    }
  }
  
  /// Main function to update district subscription based on current location
  Future<bool> updateDistrictSubscription(LocationService locationService) async {
    try {
      // Check if we have a recent subscription to avoid frequent updates
      if (await isSubscriptionRecent()) {
        return true;
      }
      
      // Get current location
      final locationData = await locationService.getCurrentLocation();
      if (locationData == null) {
        return false;
      }
      
      // Get district from backend
      final newDistrict = await getDistrictFromLocation(
        locationData.latitude, 
        locationData.longitude
      );
      
      if (newDistrict == null) {
        return false;
      }
      
      // Check if we need to change subscription
      final lastDistrict = await getLastSubscribedDistrict();
      
      if (lastDistrict == newDistrict) {
        // Update timestamp to mark as recent
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_lastSubscriptionTimeKey, DateTime.now().millisecondsSinceEpoch);
        return true;
      }
      
      // Unsubscribe from old district if exists
      if (lastDistrict != null) {
        await unsubscribeFromDistrict(lastDistrict);
      }
      
      // Subscribe to new district
      final subscribed = await subscribeToDistrict(newDistrict);
      
      return subscribed;
      
    } catch (e) {
      debugPrint('District subscription update failed: $e');
      return false;
    }
  }
  
  /// Initialize district subscription on app start
  Future<void> initializeDistrictSubscription(LocationService locationService) async {
    // Wait a bit to ensure location services are ready
    await Future.delayed(const Duration(seconds: 2));
    
    await updateDistrictSubscription(locationService);
  }
}