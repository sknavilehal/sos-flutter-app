import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/providers/alerts_provider.dart';
import '../core/providers/location_provider.dart';
import '../widgets/rrt_branding.dart';

/// Alerts screen showing nearby SOS situations
/// Watches activeAlertsProvider to display real-time emergency alerts
class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  /// Get user's current position for distance calculations
  /// Returns Position object or null if unavailable
  Future<Position?> _getUserPosition(dynamic locationService) async {
    try {
      // Get current location from location service
      final locationData = await locationService.getCurrentLocation();
      
      if (locationData == null) {
        return null;
      }
      
      // Convert LocationData to Position for distance calculations
      return Position(
        latitude: locationData.latitude,
        longitude: locationData.longitude,
        timestamp: locationData.timestamp,
        accuracy: 0.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    } catch (e) {
      debugPrint('Failed to get user position: $e');
      return null;
    }
  }
  
  /// Calculate distance between user and alert location
  /// Returns distance in kilometers, or null if calculation fails
  double? _calculateDistance(double? alertLat, double? alertLng, Position? userPosition) {
    if (alertLat == null || alertLng == null || userPosition == null) {
      return null;
    }
    
    try {
      // Use Geolocator's distance calculation (returns meters)
      final distanceInMeters = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        alertLat,
        alertLng,
      );
      
      // Convert to kilometers and round to 1 decimal place
      return double.parse((distanceInMeters / 1000).toStringAsFixed(1));
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch both alerts and location providers for real-time updates
    final alerts = ref.watch(activeAlertsProvider);
    final locationService = ref.watch(locationServiceProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header
            Container(
              padding: const EdgeInsets.all(AppConstants.screenMargins),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  
                  // App Header
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: RrtLogo(),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // App Title
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: RrtWordmark(
                      titleSize: 32,
                      subtitleSize: 32,
                    ),
                  ),
                  

                  const SizedBox(height: 12),
                ],
              ),
            ),
            
            // Alerts content - shows real alerts from provider
            // Automatic cleanup runs in background every 5 minutes
            Expanded(
              child: FutureBuilder<Position?>(
                future: _getUserPosition(locationService),
                builder: (context, positionSnapshot) {
                  final userPosition = positionSnapshot.data;
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenMargins),
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {
                      // Real alerts
                      final alert = alerts[index];
                      
                      // Calculate distance for this alert
                      final distance = _calculateDistance(
                        alert['exact_lat'] as double?,
                        alert['exact_lng'] as double?,
                        userPosition,
                      );
                      
                      return _buildAlertCard(alert, distance);
                    },
                  );
                },
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(AppConstants.screenMargins),
              child: const Text(
                'CONTACT DETAILS ARE VISIBLE ONLY WHILE THIS\nALERT IS ACTIVE.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert, double? distance) {
    // Calculate time ago from timestamp
    final timestamp = alert['timestamp'] as int? ?? 0;
    final alertTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final timeAgo = _formatTimeAgo(DateTime.now().difference(alertTime));
    
    // Format distance display
    final distanceText = distance != null ? '${distance}km away' : 'Distance unknown';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and Distance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentRed,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '$distanceText • $timeAgo',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Sender Name
          Text(
            'Emergency: ${alert['name'] ?? 'Unknown User'}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Location and Message
          Text(
            '📍 ${alert['approx_loc'] ?? 'Unknown Location'}',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.neutralGrey,
              height: 1.4,
            ),
          ),
          
          if (alert['message'] != null && alert['message'].isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '💬 ${alert['message']}',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.primaryBlack,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlack,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: InkWell(
                    onTap: () => _showCallDialog(alert),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone,
                          color: AppTheme.pureWhite,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'CALL',
                            style: TextStyle(
                              color: AppTheme.pureWhite,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.05,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlack,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: InkWell(
                    onTap: () => _getDirections(
                      alert['exact_lat'] as double?,
                      alert['exact_lng'] as double?,
                      alert['approx_loc'] as String?,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions,
                          color: AppTheme.pureWhite,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'DIRECTIONS',
                            style: TextStyle(
                              color: AppTheme.pureWhite,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.05,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Format duration into human-readable "time ago" string
  String _formatTimeAgo(Duration duration) {
    if (duration.inMinutes < 1) {
      return 'Just now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else {
      return '${duration.inDays}d ago';
    }
  }

  /// Show call dialog with phone number (privacy-aware)
  /// Phone numbers are only shown for active alerts
  void _showCallDialog(Map<String, dynamic> alert) {
    final phoneNumber = alert['mobile_number'] as String?;
    final name = alert['name'] as String? ?? 'Unknown User';
    
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number not available'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call $name?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency contact information:',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              phoneNumber,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlack,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This number is visible only while this emergency is active.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _makePhoneCall(phoneNumber);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(phoneUri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open phone dialer'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    }
  }

  void _getDirections(double? latitude, double? longitude, String? fallbackLocation) async {
    try {
      Uri mapsUri;
      
      // Prefer exact coordinates if available
      if (latitude != null && longitude != null) {
        // Use exact coordinates for Google Maps
        mapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
      } else if (fallbackLocation != null && fallbackLocation.isNotEmpty) {
        // Fall back to location name search
        final String encodedLocation = Uri.encodeComponent(fallbackLocation);
        mapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedLocation');
      } else {
        throw Exception('No location data available');
      }
      
      // Launch external maps app
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open maps application'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    }
  }
}