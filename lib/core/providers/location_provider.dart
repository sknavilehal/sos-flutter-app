import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';
import '../services/geolocator_location_service.dart';
import '../services/fcm_service.dart';

/// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  // Using full GeolocatorLocationService for comprehensive district coverage
  return GeolocatorLocationService();
});

/// Location state notifier for managing district changes
class LocationStateNotifier extends StateNotifier<AsyncValue<String?>> {
  LocationStateNotifier(this._locationService, this._fcmService) 
      : super(const AsyncValue.loading()) {
    _initialize();
  }

  final LocationService _locationService;
  final FCMService _fcmService;
  String? _lastKnownDistrict;

  /// Initialize location services (Firebase should already be initialized)
  Future<void> _initialize() async {
    try {
      try {
        await _fcmService.initialize()
            .timeout(const Duration(seconds: 10));
      } catch (fcmError) {
        debugPrint('FCM initialization failed: $fcmError');
      }
      await _updateCurrentDistrict();
    } catch (e) {
      debugPrint('Location initialization failed: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Update current district and manage FCM topic subscription
  Future<void> _updateCurrentDistrict() async {
    try {
      state = const AsyncValue.loading();
      
      // Add timeout to prevent indefinite hanging
      final district = await _locationService.getCurrentDistrict()
          .timeout(const Duration(seconds: 15));

      if (district != null) {
        // Subscribe to new district topic if changed (with timeout protection)
        if (_lastKnownDistrict != district) {
          try {
            await _fcmService.subscribeToDistrictTopic(district)
                .timeout(const Duration(seconds: 6));
          } catch (fcmError) {
            debugPrint('FCM topic subscription failed: $fcmError');
          }
          // Always update the district even if FCM fails - this is not critical
          _lastKnownDistrict = district;
        }
        state = AsyncValue.data(district);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      debugPrint('District update failed: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Refresh location and district
  Future<void> refreshLocation() async {
    await _updateCurrentDistrict();
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    final granted = await _locationService.requestLocationPermission();
    if (granted) {
      await _updateCurrentDistrict();
    }
    return granted;
  }

  /// Get current district without updating state
  String? get lastKnownDistrict => _lastKnownDistrict;

  /// Check if location services are ready
  Future<bool> isLocationReady() async {
    final hasPermission = await _locationService.hasLocationPermission();
    final serviceEnabled = await _locationService.isLocationServiceEnabled();
    return hasPermission && serviceEnabled;
  }
}

/// Location state provider
final locationStateProvider = StateNotifierProvider<LocationStateNotifier, AsyncValue<String?>>((ref) {
  final locationService = ref.read(locationServiceProvider);
  final fcmService = FCMService();
  return LocationStateNotifier(locationService, fcmService);
});