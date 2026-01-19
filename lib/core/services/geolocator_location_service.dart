import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
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
    try {
      // Check if this is a simulator location (San Francisco area) first
      if (latitude >= 37.7 && latitude <= 37.8 && longitude >= -122.5 && longitude <= -122.3) {
        debugPrint('GeolocatorLocationService: Detected iOS Simulator location, using test district');
        return 'bengaluru_urban'; // Return test district for simulator
      }
      
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
    debugPrint('Getting current district...');
    final location = await getCurrentLocation();
    if (location == null) {
      debugPrint('No location available for district detection');
      return null;
    }
    
    debugPrint('Location available: ${location.latitude}, ${location.longitude}');
    final district = await getDistrictFromCoordinates(location.latitude, location.longitude);
    debugPrint('District detected: $district');
    return district;
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

  /// Offline district mapping for Indian cities and districts
  /// Maps coordinates to administrative districts
  String _getDistrictFromCoordinatesOffline(double latitude, double longitude) {
    // Define comprehensive district boundaries across India
    final districtBounds = [
      // Karnataka Districts
      {
        'name': 'bengaluru_urban',
        'bounds': {'north': 13.15, 'south': 12.85, 'east': 77.75, 'west': 77.45}
      },
      {
        'name': 'mysuru',
        'bounds': {'north': 12.5, 'south': 12.0, 'east': 76.8, 'west': 76.5}
      },
      {
        'name': 'mangaluru',
        'bounds': {'north': 13.0, 'south': 12.7, 'east': 75.0, 'west': 74.7}
      },
      {
        'name': 'hubli_dharwad',
        'bounds': {'north': 15.5, 'south': 15.2, 'east': 75.3, 'west': 75.0}
      },
      
      // Maharashtra Districts
      {
        'name': 'mumbai',
        'bounds': {'north': 19.30, 'south': 18.90, 'east': 72.95, 'west': 72.75}
      },
      {
        'name': 'pune',
        'bounds': {'north': 18.65, 'south': 18.45, 'east': 73.95, 'west': 73.75}
      },
      {
        'name': 'nagpur',
        'bounds': {'north': 21.25, 'south': 21.05, 'east': 79.15, 'west': 78.95}
      },
      {
        'name': 'nashik',
        'bounds': {'north': 20.1, 'south': 19.9, 'east': 73.9, 'west': 73.7}
      },
      
      // Delhi NCR
      {
        'name': 'new_delhi',
        'bounds': {'north': 28.88, 'south': 28.40, 'east': 77.35, 'west': 76.84}
      },
      {
        'name': 'gurgaon',
        'bounds': {'north': 28.52, 'south': 28.38, 'east': 77.12, 'west': 76.95}
      },
      {
        'name': 'noida',
        'bounds': {'north': 28.65, 'south': 28.45, 'east': 77.45, 'west': 77.25}
      },
      {
        'name': 'faridabad',
        'bounds': {'north': 28.45, 'south': 28.25, 'east': 77.35, 'west': 77.15}
      },
      
      // Tamil Nadu Districts
      {
        'name': 'chennai',
        'bounds': {'north': 13.23, 'south': 12.83, 'east': 80.35, 'west': 80.10}
      },
      {
        'name': 'coimbatore',
        'bounds': {'north': 11.1, 'south': 10.9, 'east': 77.1, 'west': 76.9}
      },
      {
        'name': 'madurai',
        'bounds': {'north': 9.95, 'south': 9.85, 'east': 78.15, 'west': 78.05}
      },
      {
        'name': 'tiruchirappalli',
        'bounds': {'north': 10.85, 'south': 10.75, 'east': 78.75, 'west': 78.65}
      },
      
      // West Bengal Districts
      {
        'name': 'kolkata',
        'bounds': {'north': 22.65, 'south': 22.45, 'east': 88.45, 'west': 88.25}
      },
      {
        'name': 'howrah',
        'bounds': {'north': 22.65, 'south': 22.45, 'east': 88.35, 'west': 88.15}
      },
      {
        'name': 'siliguri',
        'bounds': {'north': 26.75, 'south': 26.65, 'east': 88.45, 'west': 88.35}
      },
      
      // Telangana Districts
      {
        'name': 'hyderabad',
        'bounds': {'north': 17.55, 'south': 17.25, 'east': 78.65, 'west': 78.25}
      },
      {
        'name': 'warangal',
        'bounds': {'north': 18.05, 'south': 17.95, 'east': 79.65, 'west': 79.55}
      },
      
      // Rajasthan Districts
      {
        'name': 'jaipur',
        'bounds': {'north': 26.95, 'south': 26.85, 'east': 75.85, 'west': 75.75}
      },
      {
        'name': 'jodhpur',
        'bounds': {'north': 26.35, 'south': 26.25, 'east': 73.05, 'west': 72.95}
      },
      {
        'name': 'udaipur',
        'bounds': {'north': 24.65, 'south': 24.55, 'east': 73.75, 'west': 73.65}
      },
      
      // Gujarat Districts
      {
        'name': 'ahmedabad',
        'bounds': {'north': 23.15, 'south': 22.95, 'east': 72.75, 'west': 72.45}
      },
      {
        'name': 'surat',
        'bounds': {'north': 21.25, 'south': 21.15, 'east': 72.85, 'west': 72.75}
      },
      {
        'name': 'vadodara',
        'bounds': {'north': 22.35, 'south': 22.25, 'east': 73.25, 'west': 73.15}
      },
      
      // Uttar Pradesh Districts
      {
        'name': 'lucknow',
        'bounds': {'north': 26.95, 'south': 26.75, 'east': 81.05, 'west': 80.85}
      },
      {
        'name': 'kanpur',
        'bounds': {'north': 26.55, 'south': 26.35, 'east': 80.45, 'west': 80.25}
      },
      {
        'name': 'agra',
        'bounds': {'north': 27.25, 'south': 27.05, 'east': 78.15, 'west': 77.95}
      },
      {
        'name': 'varanasi',
        'bounds': {'north': 25.35, 'south': 25.25, 'east': 83.05, 'west': 82.95}
      },
      
      // Punjab Districts
      {
        'name': 'chandigarh',
        'bounds': {'north': 30.75, 'south': 30.70, 'east': 76.80, 'west': 76.75}
      },
      {
        'name': 'ludhiana',
        'bounds': {'north': 30.95, 'south': 30.85, 'east': 75.95, 'west': 75.85}
      },
      {
        'name': 'amritsar',
        'bounds': {'north': 31.65, 'south': 31.55, 'east': 74.95, 'west': 74.85}
      },
      
      // Bihar Districts
      {
        'name': 'patna',
        'bounds': {'north': 25.65, 'south': 25.55, 'east': 85.25, 'west': 85.05}
      },
      {
        'name': 'gaya',
        'bounds': {'north': 24.85, 'south': 24.75, 'east': 85.05, 'west': 84.95}
      },
      
      // Odisha Districts
      {
        'name': 'bhubaneswar',
        'bounds': {'north': 20.35, 'south': 20.15, 'east': 85.95, 'west': 85.75}
      },
      {
        'name': 'cuttack',
        'bounds': {'north': 20.55, 'south': 20.45, 'east': 85.95, 'west': 85.85}
      },
      
      // Andhra Pradesh Districts
      {
        'name': 'visakhapatnam',
        'bounds': {'north': 17.85, 'south': 17.65, 'east': 83.35, 'west': 83.15}
      },
      {
        'name': 'vijayawada',
        'bounds': {'north': 16.55, 'south': 16.45, 'east': 80.65, 'west': 80.55}
      },
      
      // Kerala Districts
      {
        'name': 'thiruvananthapuram',
        'bounds': {'north': 8.65, 'south': 8.45, 'east': 76.95, 'west': 76.75}
      },
      {
        'name': 'kochi',
        'bounds': {'north': 10.05, 'south': 9.85, 'east': 76.35, 'west': 76.15}
      },
      {
        'name': 'kozhikode',
        'bounds': {'north': 11.35, 'south': 11.15, 'east': 75.85, 'west': 75.65}
      },
      
      // Haryana Districts
      {
        'name': 'faridabad',
        'bounds': {'north': 28.45, 'south': 28.25, 'east': 77.35, 'west': 77.15}
      },
      {
        'name': 'gurgaon',
        'bounds': {'north': 28.52, 'south': 28.38, 'east': 77.12, 'west': 76.95}
      },
      
      // Jharkhand Districts
      {
        'name': 'ranchi',
        'bounds': {'north': 23.45, 'south': 23.25, 'east': 85.45, 'west': 85.25}
      },
      {
        'name': 'dhanbad',
        'bounds': {'north': 23.85, 'south': 23.75, 'east': 86.55, 'west': 86.45}
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

    // If not in any specific district, return broader regional mapping
    return _getRegionalDistrict(latitude, longitude);
  }

  /// Get regional district mapping for areas not covered by specific districts
  String _getRegionalDistrict(double latitude, double longitude) {
    // Karnataka regions
    if (latitude >= 11.5 && latitude <= 18.5 && longitude >= 74.0 && longitude <= 78.5) {
      if (latitude >= 15.0 && longitude >= 75.0 && longitude <= 76.5) return 'belagavi';
      if (latitude >= 14.0 && longitude >= 75.5 && longitude <= 77.0) return 'davangere';
      if (latitude >= 13.0 && longitude >= 76.0 && longitude <= 77.5) return 'hassan';
      if (latitude >= 12.5 && longitude >= 74.5 && longitude <= 75.5) return 'dakshina_kannada';
      if (latitude >= 14.5 && longitude >= 76.0 && longitude <= 77.0) return 'chitradurga';
      return 'bengaluru_rural';
    }
    
    // Maharashtra regions
    if (latitude >= 15.5 && latitude <= 22.0 && longitude >= 72.5 && longitude <= 80.5) {
      if (latitude >= 20.0 && longitude >= 78.0 && longitude <= 79.5) return 'nagpur';
      if (latitude >= 19.0 && longitude >= 73.5 && longitude <= 75.0) return 'ahmednagar';
      if (latitude >= 17.5 && longitude >= 74.0 && longitude <= 76.0) return 'solapur';
      if (latitude >= 16.0 && longitude >= 73.5 && longitude <= 75.0) return 'kolhapur';
      return 'mumbai_suburban';
    }
    
    // Tamil Nadu regions
    if (latitude >= 8.0 && latitude <= 13.5 && longitude >= 76.5 && longitude <= 80.5) {
      if (latitude >= 11.0 && longitude >= 77.0 && longitude <= 78.0) return 'salem';
      if (latitude >= 10.0 && longitude >= 78.0 && longitude <= 79.0) return 'thanjavur';
      if (latitude >= 9.0 && longitude >= 77.5 && longitude <= 78.5) return 'dindigul';
      if (latitude >= 8.5 && longitude >= 77.0 && longitude <= 78.0) return 'tirunelveli';
      return 'kanchipuram';
    }
    
    // West Bengal regions
    if (latitude >= 21.5 && latitude <= 27.5 && longitude >= 87.0 && longitude <= 89.0) {
      if (latitude >= 26.0) return 'darjeeling';
      if (latitude >= 24.0 && longitude >= 88.0) return 'murshidabad';
      if (latitude >= 23.0) return 'birbhum';
      return 'north_24_parganas';
    }
    
    // Uttar Pradesh regions
    if (latitude >= 23.5 && latitude <= 30.5 && longitude >= 77.0 && longitude <= 84.5) {
      if (latitude >= 28.0 && longitude >= 77.0 && longitude <= 78.5) return 'meerut';
      if (latitude >= 26.5 && longitude >= 80.0 && longitude <= 81.5) return 'lucknow';
      if (latitude >= 25.0 && longitude >= 82.0 && longitude <= 83.5) return 'varanasi';
      if (latitude >= 27.0 && longitude >= 78.0 && longitude <= 79.0) return 'aligarh';
      return 'allahabad';
    }
    
    // Rajasthan regions
    if (latitude >= 23.0 && latitude <= 30.0 && longitude >= 69.0 && longitude <= 78.0) {
      if (latitude >= 27.0 && longitude >= 75.0 && longitude <= 77.0) return 'jaipur';
      if (latitude >= 26.0 && longitude >= 72.0 && longitude <= 74.0) return 'jodhpur';
      if (latitude >= 24.0 && longitude >= 73.0 && longitude <= 75.0) return 'udaipur';
      if (latitude >= 28.0 && longitude >= 74.0 && longitude <= 76.0) return 'bikaner';
      return 'ajmer';
    }
    
    // Gujarat regions
    if (latitude >= 20.0 && latitude <= 24.5 && longitude >= 68.0 && longitude <= 74.5) {
      if (latitude >= 23.0 && longitude >= 72.0 && longitude <= 73.0) return 'ahmedabad';
      if (latitude >= 21.0 && longitude >= 72.5 && longitude <= 73.0) return 'surat';
      if (latitude >= 22.0 && longitude >= 73.0 && longitude <= 73.5) return 'vadodara';
      if (latitude >= 22.5 && longitude >= 70.0 && longitude <= 71.0) return 'rajkot';
      return 'gandhinagar';
    }
    
    // Telangana regions
    if (latitude >= 16.0 && latitude <= 19.5 && longitude >= 77.5 && longitude <= 81.0) {
      if (latitude >= 18.0 && longitude >= 79.0 && longitude <= 80.0) return 'warangal';
      if (latitude >= 16.5 && longitude >= 78.5 && longitude <= 79.5) return 'nalgonda';
      return 'rangareddy';
    }
    
    // Andhra Pradesh regions
    if (latitude >= 13.0 && latitude <= 19.5 && longitude >= 76.5 && longitude <= 84.5) {
      if (latitude >= 17.5 && longitude >= 83.0 && longitude <= 84.0) return 'visakhapatnam';
      if (latitude >= 16.0 && longitude >= 80.0 && longitude <= 81.0) return 'krishna';
      if (latitude >= 14.0 && longitude >= 79.0 && longitude <= 80.0) return 'kurnool';
      return 'guntur';
    }
    
    // Kerala regions
    if (latitude >= 8.0 && latitude <= 12.5 && longitude >= 74.5 && longitude <= 77.5) {
      if (latitude >= 11.0) return 'kasaragod';
      if (latitude >= 10.0) return 'ernakulam';
      if (latitude >= 9.0) return 'alappuzha';
      return 'thiruvananthapuram';
    }
    
    // Punjab regions
    if (latitude >= 29.5 && latitude <= 32.5 && longitude >= 73.5 && longitude <= 76.5) {
      if (longitude >= 75.5) return 'ludhiana';
      if (latitude >= 31.5) return 'amritsar';
      return 'patiala';
    }
    
    // Haryana regions
    if (latitude >= 27.5 && latitude <= 30.5 && longitude >= 74.5 && longitude <= 77.5) {
      if (latitude >= 28.5 && longitude >= 76.5) return 'gurgaon';
      if (latitude >= 28.0 && longitude >= 77.0) return 'faridabad';
      return 'rohtak';
    }
    
    // Bihar regions
    if (latitude >= 24.0 && latitude <= 27.5 && longitude >= 83.5 && longitude <= 88.5) {
      if (latitude >= 25.5 && longitude >= 85.0) return 'patna';
      if (latitude >= 24.5 && longitude >= 84.5) return 'gaya';
      return 'muzaffarpur';
    }
    
    // Odisha regions
    if (latitude >= 17.5 && latitude <= 22.5 && longitude >= 81.5 && longitude <= 87.5) {
      if (latitude >= 20.0 && longitude >= 85.5) return 'khordha';
      if (latitude >= 19.0) return 'cuttack';
      return 'ganjam';
    }
    
    // Jharkhand regions
    if (latitude >= 21.5 && latitude <= 25.0 && longitude >= 83.5 && longitude <= 87.5) {
      if (latitude >= 23.0 && longitude >= 85.0) return 'ranchi';
      if (latitude >= 23.5 && longitude >= 86.0) return 'dhanbad';
      return 'bokaro';
    }
    
    // Madhya Pradesh regions
    if (latitude >= 21.0 && latitude <= 26.5 && longitude >= 74.0 && longitude <= 82.5) {
      if (latitude >= 23.0 && longitude >= 77.0 && longitude <= 78.0) return 'bhopal';
      if (latitude >= 22.5 && longitude >= 75.5 && longitude <= 76.5) return 'indore';
      if (latitude >= 24.0 && longitude >= 78.0 && longitude <= 79.0) return 'jabalpur';
      return 'gwalior';
    }
    
    // Chhattisgarh regions
    if (latitude >= 17.0 && latitude <= 24.0 && longitude >= 80.0 && longitude <= 84.5) {
      if (latitude >= 21.0 && longitude >= 81.0 && longitude <= 82.0) return 'raipur';
      if (latitude >= 20.0 && longitude >= 83.0 && longitude <= 84.0) return 'bastar';
      return 'bilaspur';
    }
    
    // Assam regions
    if (latitude >= 24.0 && latitude <= 28.0 && longitude >= 89.5 && longitude <= 96.0) {
      if (latitude >= 26.0 && longitude >= 91.5 && longitude <= 92.0) return 'kamrup';
      return 'dibrugarh';
    }
    
    // Himachal Pradesh regions
    if (latitude >= 30.0 && latitude <= 33.5 && longitude >= 75.5 && longitude <= 79.0) {
      if (latitude >= 31.0 && longitude >= 77.0) return 'shimla';
      return 'kangra';
    }
    
    // Uttarakhand regions
    if (latitude >= 29.0 && latitude <= 31.5 && longitude >= 77.5 && longitude <= 81.0) {
      if (latitude >= 30.0 && longitude >= 78.0) return 'dehradun';
      return 'haridwar';
    }
    
    // Jammu & Kashmir regions
    if (latitude >= 32.0 && latitude <= 37.0 && longitude >= 73.0 && longitude <= 80.5) {
      if (latitude >= 34.0) return 'srinagar';
      return 'jammu';
    }
    
    return 'unknown'; // Fallback for unmapped regions
  }
}