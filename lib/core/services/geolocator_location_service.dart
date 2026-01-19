import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'location_service.dart';

/// Geolocator-based implementation of LocationService
class GeolocatorLocationService implements LocationService {
  
  @override
  Future<LocationData?> getCurrentLocation() async {
    try {
      debugPrint('Getting current location...');
      
      // Check permissions and services
      if (!await hasLocationPermission()) {
        debugPrint('No location permission, requesting...');
        final permissionGranted = await requestLocationPermission();
        if (!permissionGranted) {
          debugPrint('Location permission denied');
          return null;
        }
        debugPrint('Location permission granted');
      }

      if (!await isLocationServiceEnabled()) {
        debugPrint('Location service not enabled');
        return null;
      }

      debugPrint('Getting position with geolocator...');
      // Get current position with updated settings
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      debugPrint('Position received: ${position.latitude}, ${position.longitude}');
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
    debugPrint('District discovery moved to backend - this method is deprecated');
    return null;
  }

  @override
  Future<String?> getCurrentDistrict() async {
    debugPrint('District discovery moved to backend - this method is deprecated');
    return null;
  }

  @override
  Future<String?> getCurrentAddress() async {
    try {
      debugPrint('Getting current address...');
      final location = await getCurrentLocation();
      if (location == null) {
        debugPrint('No location available for address lookup');
        return null;
      }
      
      return await getAddressFromCoordinates(location.latitude, location.longitude);
    } catch (e) {
      debugPrint('Error getting current address: $e');
      return null;
    }
  }

  @override
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      debugPrint('Getting address from coordinates: $latitude, $longitude');
      
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
        debugPrint('Address found: $address');
        return address.isNotEmpty ? address : 'Unknown location';
      }
      
      return 'Unknown location';
    } catch (e) {
      debugPrint('Error getting address from coordinates: $e');
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