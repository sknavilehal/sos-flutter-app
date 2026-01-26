import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'location_service.dart';
import 'offline_district_service.dart';

/// Geolocator-based implementation of LocationService
class GeolocatorLocationService implements LocationService {
  final OfflineDistrictService _districtService = OfflineDistrictService.instance;
  
  @override
  Future<LocationData?> getCurrentLocation() async {
    try {
      // Check permissions and services
      if (!await hasLocationPermission()) {
        final permissionGranted = await requestLocationPermission();
        if (!permissionGranted) {
          return null;
        }
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
      debugPrint('Failed to get current location: $e');
      return null;
    }
  }

  @override
  Future<String?> getDistrictFromCoordinates(double latitude, double longitude) async {
    try {
      // Use offline district lookup with polygon boundaries
      final district = _districtService.getDistrictFromCoordinates(latitude, longitude);
      return district;
    } catch (e) {
      debugPrint('Failed to get district from coordinates: $e');
      return null;
    }
  }

  @override
  Future<String?> getCurrentDistrict() async {
    try {
      final location = await getCurrentLocation();
      if (location == null) {
        return null;
      }
      
      return await getDistrictFromCoordinates(location.latitude, location.longitude);
    } catch (e) {
      debugPrint('Failed to get current district: $e');
      return null;
    }
  }

  @override
  Future<String?> getCurrentAddress() async {
    try {
      final location = await getCurrentLocation();
      if (location == null) {
        return null;
      }
      
      return await getAddressFromCoordinates(location.latitude, location.longitude);
    } catch (e) {
      debugPrint('Failed to get current address: $e');
      return null;
    }
  }

  @override
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        
        // Build a readable address
        final addressComponents = <String>[];
        
        if (place.name != null && place.name!.isNotEmpty) {
          addressComponents.add(place.name!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressComponents.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressComponents.add(place.locality!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressComponents.add(place.administrativeArea!);
        }
        
        final address = addressComponents.join(', ');
        return address.isNotEmpty ? address : 'Unknown location';
      }
      
      return 'Unknown location';
    } catch (e) {
      debugPrint('Failed to resolve address: $e');
      return 'Address unavailable';
    }
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
}