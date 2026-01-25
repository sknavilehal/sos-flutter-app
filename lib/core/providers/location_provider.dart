import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';
import '../services/geolocator_location_service.dart';

/// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  // Using full GeolocatorLocationService for comprehensive district coverage
  return GeolocatorLocationService();
});

/// Location state notifier for managing location state
/// Note: District subscription is handled by DistrictSubscriptionService in HomeScreen
class LocationStateNotifier extends StateNotifier<AsyncValue<String?>> {
  LocationStateNotifier(this._locationService) 
      : super(const AsyncValue.loading()) {
    _initialize();
  }

  final LocationService _locationService;
  String? _lastKnownDistrict;

  /// Initialize location services
  Future<void> _initialize() async {
    try {
      await _updateCurrentDistrict();
    } catch (e) {
      debugPrint('Location initialization failed: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Update current district
  Future<void> _updateCurrentDistrict() async {
    try {
      state = const AsyncValue.loading();
      
      // Add timeout to prevent indefinite hanging
      final district = await _locationService.getCurrentDistrict()
          .timeout(const Duration(seconds: 15));

      if (district != null) {
        _lastKnownDistrict = district;
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
  return LocationStateNotifier(locationService);
});