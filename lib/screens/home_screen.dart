import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/providers/location_provider.dart';
import '../services/sos_service.dart';
import '../core/config/api_config.dart';

/// Home screen with location display and SOS button
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isSendingSOS = false;
  
  @override
  void initState() {
    super.initState();
    // Location is now handled by LocationStateNotifier
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.screenMargins),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         AppConstants.screenMargins * 2,
            ),
            child: Column(
            children: [
              const SizedBox(height: AppConstants.iconTopMargin),
              
              // App Header
              Row(
                children: [
                  Container(
                    width: AppConstants.brandIconSize,
                    height: AppConstants.brandIconSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryBlack, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.pets,
                      size: 24,
                      color: AppTheme.primaryBlack,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppConstants.iconBrandSpacing),
              
              // App Title
              const Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rapid',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlack,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'Response Team',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w300,
                        color: AppTheme.neutralGrey,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppConstants.brandBodySpacing),
              
              // Location
              Consumer(
                builder: (context, ref, child) {
                  final locationState = ref.watch(locationStateProvider);
                  
                  return locationState.when(
                    loading: () => Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.neutralGrey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Detecting location...',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.neutralGrey,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            // Force refresh location
                            ref.read(locationStateProvider.notifier).refreshLocation();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                    error: (error, stack) => Row(
                      children: [
                        const Icon(
                          Icons.location_off,
                          color: AppTheme.accentRed,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Location unavailable',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.accentRed,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final locationNotifier = ref.read(locationStateProvider.notifier);
                            await locationNotifier.requestLocationPermission();
                          },
                          child: const Text('Enable'),
                        ),
                      ],
                    ),
                    data: (district) {
                      if (district == null) {
                        return Row(
                          children: [
                            const Icon(
                              Icons.location_off,
                              color: AppTheme.neutralGrey,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Location permission required',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.neutralGrey,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final locationNotifier = ref.read(locationStateProvider.notifier);
                                await locationNotifier.requestLocationPermission();
                              },
                              child: const Text('Allow'),
                            ),
                          ],
                        );
                      }
                      
                      return Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppTheme.primaryBlack,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              district.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.primaryBlack,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              size: 20,
                              color: AppTheme.neutralGrey,
                            ),
                            onPressed: () {
                              ref.read(locationStateProvider.notifier).refreshLocation();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Backend Status
              Consumer(
                builder: (context, ref, child) {
                  return FutureBuilder<bool>(
                    future: ref.read(sosServiceProvider).testConnection(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Row(
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 1.5),
                            ),
                            SizedBox(width: 8),
                            Text('Checking server...', style: TextStyle(fontSize: 12, color: AppTheme.neutralGrey)),
                          ],
                        );
                      }
                      
                      final isConnected = snapshot.data ?? false;
                      return Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isConnected ? Colors.green : AppTheme.accentRed,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isConnected ? 'Server connected' : 'Server offline',
                            style: TextStyle(
                              fontSize: 12,
                              color: isConnected ? Colors.green : AppTheme.accentRed,
                            ),
                          ),
                          if (!isConnected) ...[
                            const Spacer(),
                            TextButton(
                              onPressed: () => setState(() {}), // Rebuild to retry
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Retry', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ],
                      );
                    },
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // SOS Button Section
              const Text(
                'Emergency SOS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryBlack,
                  letterSpacing: -0.01,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // SOS Button
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isSendingSOS ? AppTheme.neutralGrey : AppTheme.accentRed,
                  boxShadow: [
                    BoxShadow(
                      color: (_isSendingSOS ? AppTheme.neutralGrey : AppTheme.accentRed).withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: _isSendingSOS ? null : _handleSOSPress,
                  child: Center(
                    child: _isSendingSOS 
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppTheme.pureWhite,
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Sending...',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.pureWhite,
                              ),
                            ),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'SOS',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.pureWhite,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tap for emergency',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.pureWhite,
                              ),
                            ),
                          ],
                        ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Emergency Contacts
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Emergency Contacts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Police
                  _buildEmergencyContact(
                    icon: Icons.local_police,
                    title: 'Police',
                    number: '100',
                    onTap: () {
                      // TODO: Call police
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Ambulance
                  _buildEmergencyContact(
                    icon: Icons.local_hospital,
                    title: 'Ambulance',
                    number: '108',
                    onTap: () {
                      // TODO: Call ambulance
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Fire Brigade
                  _buildEmergencyContact(
                    icon: Icons.local_fire_department,
                    title: 'Fire Brigade',
                    number: '101',
                    onTap: () {
                      // TODO: Call fire brigade
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
            ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle SOS button press
  Future<void> _handleSOSPress() async {
    final locationState = ref.read(locationStateProvider);
    final sosService = ref.read(sosServiceProvider);
    final locationService = ref.read(locationServiceProvider);
    
    // Check if location is available
    if (!locationState.hasValue || locationState.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Location required for SOS alert'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      
      // Try to get location
      ref.read(locationStateProvider.notifier).refreshLocation();
      return;
    }

    setState(() {
      _isSendingSOS = true;
    });

    try {
      final district = locationState.value!;
      
      // Get current location from location service
      final locationData = await locationService.getCurrentLocation();
      
      if (locationData == null) {
        throw Exception('Unable to get current location');
      }

      // Convert LocationData to Position for SOS service
      final currentPosition = Position(
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

      print('🆘 Sending SOS from $district');
      print('🆘 Backend URL: ${ApiConfig.sosEndpoint}');
      
      final response = await sosService.sendSOSAlert(
        district: district,
        location: currentPosition,
        userInfo: {
          'deviceId': 'mobile-device',
          'platform': 'flutter',
          'appVersion': '1.0.0',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ SOS Alert sent to ${district.toUpperCase()}!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
          
          // Show alert dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('🆘 Emergency Alert Sent'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alert sent to: ${district.toUpperCase()}'),
                  Text('Topic: ${response.topic}'),
                  const SizedBox(height: 12),
                  const Text(
                    'Emergency responders in your area have been notified.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${response.error ?? "Failed to send SOS"}'),
              backgroundColor: AppTheme.accentRed,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ SOS error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ SOS failed: ${e.toString()}'),
            backgroundColor: AppTheme.accentRed,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingSOS = false;
        });
      }
    }
  }

  Widget _buildEmergencyContact({
    required IconData icon,
    required String title,
    required String number,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryBlack,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryBlack,
                    ),
                  ),
                  Text(
                    number,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.neutralGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.phone,
              color: AppTheme.neutralGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}