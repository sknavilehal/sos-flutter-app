import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';

/// Geolocator-based implementation of LocationService
class GeolocatorLocationService implements LocationService {
  
  @override
  Future<LocationData?> getCurrentLocation() async {
    try {
      // Check permissions and services
      if (!await hasLocationPermission()) {
        final permissionGranted = await requestLocationPermission();
        if (!permissionGranted) return null;
      }

      if (!await isLocationServiceEnabled()) {
        return null;
      }

      // Get current position with updated settings
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  @override
  Future<String?> getDistrictFromCoordinates(double latitude, double longitude) async {
    try {
      // Use simplified district mapping based on major Indian cities
      // In production, integrate with proper geocoding service
      return _getDistrictFromCoordinatesOffline(latitude, longitude);
    } catch (e) {
      debugPrint('Error getting district from coordinates: $e');
      return 'unknown';
    }
  }

  @override
  Future<String?> getCurrentDistrict() async {
    final location = await getCurrentLocation();
    if (location == null) return null;
    
    return getDistrictFromCoordinates(location.latitude, location.longitude);
  }

  @override
  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Offline district mapping for major Indian cities (MVP)
  /// Maps coordinates to administrative districts
  String _getDistrictFromCoordinatesOffline(double latitude, double longitude) {
    // Define major city boundaries (simplified for MVP)
    final districtBounds = [
      {
        'name': 'bengaluru',
        'bounds': {'north': 13.15, 'south': 12.85, 'east': 77.75, 'west': 77.45}
      },
      {
        'name': 'mumbai',
        'bounds': {'north': 19.30, 'south': 18.90, 'east': 72.95, 'west': 72.75}
      },
      {
        'name': 'delhi',
        'bounds': {'north': 28.88, 'south': 28.40, 'east': 77.35, 'west': 76.84}
      },
      {
        'name': 'chennai',
        'bounds': {'north': 13.23, 'south': 12.83, 'east': 80.35, 'west': 80.10}
      },
      {
        'name': 'kolkata',
        'bounds': {'north': 22.65, 'south': 22.45, 'east': 88.45, 'west': 88.25}
      },
      {
        'name': 'hyderabad',
        'bounds': {'north': 17.55, 'south': 17.25, 'east': 78.65, 'west': 78.25}
      },
      {
        'name': 'pune',
        'bounds': {'north': 18.65, 'south': 18.45, 'east': 73.95, 'west': 73.75}
      },
    ];

    for (final district in districtBounds) {
      final bounds = district['bounds'] as Map<String, double>;
      
      if (latitude <= bounds['north']! &&
          latitude >= bounds['south']! &&
          longitude <= bounds['east']! &&
          longitude >= bounds['west']!) {
        return district['name'] as String;
      }
    }

    // If not in any major city, return state-based district
    return _getStateFromCoordinates(latitude, longitude);
  }

  /// Get state-based district for areas outside major cities
  String _getStateFromCoordinates(double latitude, double longitude) {
    // Simplified state boundaries (for demonstration)
    if (latitude >= 12.0 && latitude <= 18.5 && longitude >= 74.0 && longitude <= 78.5) {
      return 'karnataka';
    } else if (latitude >= 18.5 && latitude <= 20.5 && longitude >= 72.5 && longitude <= 73.5) {
      return 'maharashtra';
    } else if (latitude >= 28.0 && latitude <= 30.0 && longitude >= 76.5 && longitude <= 77.5) {
      return 'delhi';
    } else if (latitude >= 12.5 && latitude <= 14.0 && longitude >= 79.5 && longitude <= 80.5) {
      return 'tamilnadu';
    } else if (latitude >= 22.0 && latitude <= 24.0 && longitude >= 87.5 && longitude <= 88.5) {
      return 'westbengal';
    } else if (latitude >= 17.0 && latitude <= 18.5 && longitude >= 78.0 && longitude <= 79.5) {
      return 'telangana';
    }
    
    return 'india'; // Default fallback
  }
}