/// Abstract location service interface for extensibility
abstract class LocationService {
  /// Get current location coordinates
  Future<LocationData?> getCurrentLocation();
  
  /// Get district name from coordinates
  Future<String?> getDistrictFromCoordinates(double latitude, double longitude);
  
  /// Get current district directly
  Future<String?> getCurrentDistrict();
  
  /// Get human-readable address from coordinates
  Future<String?> getCurrentAddress();
  
  /// Get address from coordinates
  Future<String?> getAddressFromCoordinates(double latitude, double longitude);
  
  /// Check if location permissions are granted
  Future<bool> hasLocationPermission();
  
  /// Request location permissions
  Future<bool> requestLocationPermission();
  
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled();
}

/// Location data model
class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, address: $address)';
  }
}