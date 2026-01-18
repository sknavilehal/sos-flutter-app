import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';
import '../services/geolocator_location_service.dart';
import '../services/fcm_service.dart';

/// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return GeolocatorLocationService();
});

/// FCM service provider
final fcmServiceProvider = Provider<FCMService>((ref) {
  return FCMService();
});

/// Current location provider
final currentLocationProvider = FutureProvider<LocationData?>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return locationService.getCurrentLocation();
});

/// Current district provider
final currentDistrictProvider = FutureProvider<String?>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return locationService.getCurrentDistrict();
});

/// Location permission status provider
final locationPermissionProvider = FutureProvider<bool>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return locationService.hasLocationPermission();
});

/// Location service enabled status provider
final locationServiceEnabledProvider = FutureProvider<bool>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return locationService.isLocationServiceEnabled();
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
      // Initialize FCM service (Firebase is already initialized in main.dart)
      await _fcmService.initialize();
      
      await _updateCurrentDistrict();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Update current district and manage FCM topic subscription
  Future<void> _updateCurrentDistrict() async {
    try {
      state = const AsyncValue.loading();
      
      final district = await _locationService.getCurrentDistrict();
      
      if (district != null) {
        // Subscribe to new district topic if changed
        if (_lastKnownDistrict != district) {
          await _fcmService.subscribeToDistrictTopic(district);
          _lastKnownDistrict = district;
        }
        
        state = AsyncValue.data(district);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
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