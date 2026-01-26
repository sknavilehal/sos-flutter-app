# District Lookup Testing Guide

## ✅ Implementation Complete

The offline district boundary lookup has been successfully implemented using polygon-based geospatial calculations.

## What Was Implemented

### 1. **Offline District Service** (`lib/core/services/offline_district_service.dart`)
- Loads India district boundaries from GeoJSON (Census 2011 data)
- Performs point-in-polygon checks to determine district from coordinates
- Platform-consistent results (same district for iOS and Android)
- Optimized with bounding box pre-filtering
- Returns sanitized district names for FCM topic subscription

### 2. **Updated Location Service** (`lib/core/services/geolocator_location_service.dart`)
- Now uses offline district lookup instead of native geocoding
- Guarantees accurate district-level granularity
- No API calls required

### 3. **Standalone Test App** (`lib/test_district_lookup.dart`)
- Interactive testing interface
- Pre-configured test locations across India
- Manual coordinate input
- Automated test suite
- Performance metrics

### 4. **Main App Integration** (`lib/main.dart`)
- District service initializes on app startup
- Runs in background during splash screen
- Graceful fallback if initialization fails

## How to Test

### Option 1: Run the Standalone Test App

```bash
# From the project root
flutter run lib/test_district_lookup.dart
```

This will launch a dedicated testing interface with:
- Manual coordinate input fields
- Quick test buttons for major cities
- "Run All Tests" button for automated testing
- Detailed results display

### Option 2: Test with Your Main App

```bash
# Run the main app
flutter run
```

The district service will initialize automatically on startup. Check the console logs for:
```
Loading district boundaries...
✅ Loaded 640 districts in XXXXms
```

Then trigger district lookup through your normal app flow (location-based features).

## Test Coordinates

### Pre-configured Test Locations

| City | Latitude | Longitude | Expected District |
|------|----------|-----------|-------------------|
| Udupi | 13.3409 | 74.7421 | udupi |
| Bangalore | 12.9716 | 77.5946 | bengaluru-urban |
| Mumbai | 19.0760 | 72.8777 | mumbai |
| Delhi | 28.6139 | 77.2090 | new-delhi |
| Chennai | 13.0827 | 80.2707 | chennai |
| Kolkata | 22.5726 | 88.3639 | kolkata |
| Hyderabad | 17.3850 | 78.4867 | hyderabad |
| Pune | 18.5204 | 73.8567 | pune |
| Mangalore | 12.9141 | 74.8560 | dakshina-kannada |
| Mysore | 12.2958 | 76.6394 | mysuru |

### Custom Coordinates

You can test any location in India:
1. Open the test app
2. Enter latitude and longitude
3. Click "Lookup District"
4. View the results including:
   - District name (original)
   - State name
   - Sanitized name (for FCM topics)
   - FCM topic format

## Performance

### Expected Performance Metrics

- **Initialization**: 2-10 seconds (one-time on app startup)
- **Lookup Time**: 50-200ms per lookup
- **Memory**: ~100-200MB additional (GeoJSON data)
- **App Size Increase**: ~27MB (GeoJSON file)

### Optimization Techniques Used

1. **Bounding Box Pre-filtering**: Quick rejection for points outside district bounds
2. **Lazy Loading**: Districts loaded once and cached in memory
3. **Early Exit**: Returns immediately when district is found

## Troubleshooting

### Issue: Service Not Initialized

**Error**: `District service not initialized`

**Solution**: Ensure the service is initialized before use:
```dart
await OfflineDistrictService.instance.initialize();
```

### Issue: No District Found

**Error**: `No district found for coordinates`

**Possible Causes**:
1. Coordinates are outside India
2. Coordinates are in ocean/water bodies
3. Coordinates are in disputed territories
4. Boundary data doesn't cover the area

**Debug**: Check console for lookup time - should be < 500ms

### Issue: Slow Lookups

**Symptom**: Lookups taking > 1 second

**Solutions**:
1. Check if initialization completed successfully
2. Verify GeoJSON file is correctly loaded
3. Consider simplifying the GeoJSON if performance is critical

## Integration with District Subscription

The district service is already integrated with your FCM subscription system:

1. User opens app → District service initializes
2. User location detected → `getDistrictFromCoordinates()` called
3. District name returned (sanitized) → Used for FCM topic subscription
4. User subscribes to `district-{name}` topic
5. Platform-consistent: All users in same district subscribe to same topic

## Files Modified/Created

### Created
- `lib/core/services/offline_district_service.dart` - Main service
- `lib/test_district_lookup.dart` - Standalone test app
- `DISTRICT_LOOKUP_TESTING.md` - This file

### Modified
- `pubspec.yaml` - Added dependencies (latlong2, polygon)
- `lib/main.dart` - Added service initialization
- `lib/core/services/geolocator_location_service.dart` - Updated to use offline service

## Key Benefits

✅ **Platform Consistent**: iOS and Android get identical results  
✅ **Accurate**: Uses official Census 2011 district boundaries  
✅ **Offline**: No API calls, works without network  
✅ **Free**: No API costs or rate limiting  
✅ **Reliable**: No dependency on external services  
✅ **Standardized**: District names are normalized for FCM topics  

## Next Steps

1. **Test thoroughly** with the standalone test app
2. **Verify performance** on actual devices (not just emulator)
3. **Monitor initialization time** on slower devices
4. **Consider simplifying GeoJSON** if 27MB is too large (can reduce to ~5MB)
5. **Add error handling** for edge cases in your production code

## Optional: Simplify GeoJSON (Future Optimization)

If the 27MB file size is an issue:

```bash
# Install mapshaper
npm install -g mapshaper

# Simplify the file
cd assets/data
mapshaper dists11.geojson -simplify 5% -o dists11_simplified.geojson

# Replace the original file
mv dists11_simplified.geojson dists11.geojson
```

This can reduce the file to ~3-5MB with minimal accuracy loss.

---

## Support

For issues or questions about the district lookup implementation, check:
1. Console logs during initialization
2. Lookup times in debug output
3. The test app for verification
