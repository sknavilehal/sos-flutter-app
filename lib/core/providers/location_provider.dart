import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';
import '../services/geolocator_location_service.dart';
import '../services/fcm_service.dart';

/// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  // Using full GeolocatorLocationService for comprehensive district coverage
  return GeolocatorLocationService();
});

/// FCM service provider
final fcmServiceProvider = Provider<FCMService>((ref) {
  return FCMService();
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
      print('LocationStateNotifier: Initializing...');
      
      // Try to initialize FCM with timeout and detailed debugging
      try {
        print('LocationStateNotifier: Starting FCM initialization...');
        await _fcmService.initialize()
            .timeout(const Duration(seconds: 10));
        print('LocationStateNotifier: FCM initialized successfully');
      } catch (fcmError) {
        // Log FCM error but continue with location
        print('FCM initialization failed or timed out: $fcmError');
        print('Stack trace: ${StackTrace.current}');
      }
      
      print('LocationStateNotifier: Proceeding to location update...');
      await _updateCurrentDistrict();
    } catch (e) {
      print('Location initialization failed: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Update current district and manage FCM topic subscription
  Future<void> _updateCurrentDistrict() async {
    try {
      print('LocationStateNotifier: Updating district...');
      state = const AsyncValue.loading();
      
      // Add timeout to prevent indefinite hanging
      final district = await _locationService.getCurrentDistrict()
          .timeout(const Duration(seconds: 15));
      
      print('LocationStateNotifier: Received district: $district');
      
      if (district != null) {
        // Subscribe to new district topic if changed (with timeout protection)
        if (_lastKnownDistrict != district) {
          try {
            print('LocationStateNotifier: Starting FCM topic subscription for: $district');
            final stopwatch = Stopwatch()..start();
            
            await _fcmService.subscribeToDistrictTopic(district)
                .timeout(const Duration(seconds: 6));
            
            stopwatch.stop();
            _lastKnownDistrict = district;
            print('LocationStateNotifier: FCM subscription completed in ${stopwatch.elapsedMilliseconds}ms');
          } catch (fcmError) {
            print('LocationStateNotifier: FCM topic subscription failed: $fcmError');
            
            if (fcmError.toString().contains('TimeoutException')) {
              print('LocationStateNotifier: FCM subscription timed out - this is common in simulators');
              print('LocationStateNotifier: App will continue without FCM topic subscription');
            } else {
              print('LocationStateNotifier: FCM error type: ${fcmError.runtimeType}');
            }
            
            // Always update the district even if FCM fails - this is not critical
            _lastKnownDistrict = district;
            print('LocationStateNotifier: Proceeding without FCM subscription');
          }
        } else {
          print('LocationStateNotifier: District unchanged ($district), skipping FCM subscription');
        }
        
        print('LocationStateNotifier: Setting state to data: $district');
        state = AsyncValue.data(district);
      } else {
        print('LocationStateNotifier: District is null, setting state to null');
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      print('Error updating district: $e');
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