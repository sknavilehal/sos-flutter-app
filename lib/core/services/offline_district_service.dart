import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// Service for offline district lookup using boundary polygons
class OfflineDistrictService {
  static OfflineDistrictService? _instance;
  Map<String, DistrictBoundary>? _districts;
  bool _isInitialized = false;

  OfflineDistrictService._();

  static OfflineDistrictService get instance {
    _instance ??= OfflineDistrictService._();
    return _instance!;
  }

  /// Initialize the service by loading district boundaries
  /// Call this once during app startup
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('District service already initialized');
      return;
    }

    try {
      debugPrint('Loading district boundaries...');
      final startTime = DateTime.now();
      
      final jsonString = await rootBundle.loadString('assets/data/dists11.geojson');
      final geoJson = jsonDecode(jsonString);
      
      _districts = {};
      
      for (final feature in geoJson['features']) {
        final districtName = feature['properties']['DISTRICT'] as String?;
        final stateName = feature['properties']['ST_NM'] as String?;
        
        if (districtName == null) continue;
        
        // Parse geometry
        final geometry = feature['geometry'];
        final coordinates = geometry['coordinates'];
        
        // Handle both Polygon and MultiPolygon
        List<List<LatLng>> polygons = [];
        
        if (geometry['type'] == 'Polygon') {
          polygons.add(_parsePolygonCoordinates(coordinates[0]));
        } else if (geometry['type'] == 'MultiPolygon') {
          for (final polygon in coordinates) {
            polygons.add(_parsePolygonCoordinates(polygon[0]));
          }
        }
        
        // Sanitize district name for FCM topic
        final sanitizedName = _sanitizeDistrictName(districtName);
        
        _districts![sanitizedName] = DistrictBoundary(
          name: districtName,
          sanitizedName: sanitizedName,
          stateName: stateName ?? '',
          polygons: polygons,
        );
      }
      
      _isInitialized = true;
      final loadTime = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint('✅ Loaded ${_districts!.length} districts in ${loadTime}ms');
      
    } catch (e) {
      debugPrint('❌ Failed to initialize district service: $e');
      rethrow;
    }
  }

  /// Parse coordinates from GeoJSON format [lng, lat] to LatLng
  List<LatLng> _parsePolygonCoordinates(List<dynamic> coords) {
    return coords.map((coord) {
      final lng = (coord[0] as num).toDouble();
      final lat = (coord[1] as num).toDouble();
      return LatLng(lat, lng);
    }).toList();
  }

  /// Get district name from coordinates using point-in-polygon check
  String? getDistrictFromCoordinates(double latitude, double longitude) {
    if (!_isInitialized || _districts == null) {
      debugPrint('District service not initialized');
      return null;
    }

    final startTime = DateTime.now();
    final point = LatLng(latitude, longitude);

    // Check each district's boundaries
    for (final district in _districts!.values) {
      if (district.containsPoint(point)) {
        final lookupTime = DateTime.now().difference(startTime).inMilliseconds;
        debugPrint('✅ District found: ${district.name} (${district.sanitizedName}) in ${lookupTime}ms');
        return district.sanitizedName;
      }
    }

    final lookupTime = DateTime.now().difference(startTime).inMilliseconds;
    if (kDebugMode) {
      debugPrint('❌ No district found for ($latitude, $longitude) - checked in ${lookupTime}ms');
    }
    return null;
  }

  /// Get full district info
  DistrictBoundary? getDistrictInfo(String sanitizedName) {
    return _districts?[sanitizedName];
  }

  /// Get all loaded districts (for debugging)
  List<String> getAllDistricts() {
    if (_districts == null) return [];
    return _districts!.values.map((d) => '${d.name} (${d.stateName})').toList()..sort();
  }

  /// Sanitize district name for FCM topic compatibility
  String _sanitizeDistrictName(String district) {
    return district
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9\-]'), '');
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Get total district count
  int get districtCount => _districts?.length ?? 0;
}

/// Simple bounding box class for LatLng coordinates
class LatLngBounds {
  final LatLng southWest;
  final LatLng northEast;

  LatLngBounds(this.southWest, this.northEast);

  bool contains(LatLng point) {
    return point.latitude >= southWest.latitude &&
           point.latitude <= northEast.latitude &&
           point.longitude >= southWest.longitude &&
           point.longitude <= northEast.longitude;
  }
}

/// Model for district boundary data
class DistrictBoundary {
  final String name;              // Original name: "Udupi"
  final String sanitizedName;     // FCM-safe name: "udupi"
  final String stateName;         // State name: "Karnataka"
  final List<List<LatLng>> polygons; // Boundary polygons
  
  // Cached bounding box for optimization
  late final LatLngBounds bounds;

  DistrictBoundary({
    required this.name,
    required this.sanitizedName,
    required this.stateName,
    required this.polygons,
  }) {
    bounds = _calculateBounds();
  }

  /// Calculate bounding box for quick rejection test
  LatLngBounds _calculateBounds() {
    double minLat = double.infinity;
    double maxLat = double.negativeInfinity;
    double minLng = double.infinity;
    double maxLng = double.negativeInfinity;

    for (final polygon in polygons) {
      for (final point in polygon) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  /// Check if a point is within this district's boundaries
  bool containsPoint(LatLng point) {
    // Quick rejection test using bounding box
    if (!bounds.contains(point)) {
      return false;
    }

    // Full polygon check for points inside bounding box using Ray Casting algorithm
    for (final polygonPoints in polygons) {
      if (_isPointInPolygon(point, polygonPoints)) {
        return true;
      }
    }
    
    return false;
  }

  /// Ray Casting algorithm for point-in-polygon check
  /// Returns true if point is inside the polygon
  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;

    bool inside = false;
    int j = polygon.length - 1;

    for (int i = 0; i < polygon.length; i++) {
      final xi = polygon[i].longitude;
      final yi = polygon[i].latitude;
      final xj = polygon[j].longitude;
      final yj = polygon[j].latitude;

      final intersect = ((yi > point.latitude) != (yj > point.latitude)) &&
          (point.longitude < (xj - xi) * (point.latitude - yi) / (yj - yi) + xi);

      if (intersect) inside = !inside;

      j = i;
    }

    return inside;
  }
}
