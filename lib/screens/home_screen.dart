import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/providers/location_provider.dart';
import '../core/services/profile_service.dart';
import '../services/sos_service.dart';
import '../services/district_subscription_service.dart';

/// Home screen with location display and SOS button
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isSendingSOS = false;
  bool _isSOSActive = false;
  String? _activeSosId;
  String? _activeLocation;
  final TextEditingController _messageController = TextEditingController();
  bool _isStateLoaded = false;
  
  // Hold to send SOS functionality
  bool _isHoldingButton = false;
  int _holdProgress = 0; // 0-3 seconds
  Timer? _holdTimer;
  
  // District subscription service
  final _districtService = DistrictSubscriptionService();
  
  // Cache futures to prevent rebuilding
  Future<bool>? _serverConnectionFuture;
  Future<bool>? _locationPermissionFuture;
  Future<String?>? _locationAddressFuture;
  
  @override
  void initState() {
    super.initState();
    _loadSOSState();
    _initializeFutures();
    _initializeDistrictSubscription();
  }
  
  /// Initialize district subscription for receiving SOS alerts
  void _initializeDistrictSubscription() {
    // Run district subscription in background
    Future.microtask(() async {
      final locationService = ref.read(locationServiceProvider);
      await _districtService.initializeDistrictSubscription(locationService);
    });
  }
  
  /// Initialize cached futures to prevent rebuilds
  void _initializeFutures() {
    _serverConnectionFuture = ref.read(sosServiceProvider).testConnection();
    
    final locationService = ref.read(locationServiceProvider);
    _locationPermissionFuture = locationService.hasLocationPermission();
  }
  
  /// Refresh cached futures when needed
  void _refreshFutures() {
    setState(() {
      _initializeFutures();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _holdTimer?.cancel();
    super.dispose();
  }

  /// Load SOS state from SharedPreferences
  Future<void> _loadSOSState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isActive = prefs.getBool('sos_active') ?? false;
      final sosId = prefs.getString('active_sos_id');
      final location = prefs.getString('active_location');
      
      if (mounted) {
        setState(() {
          _isSOSActive = isActive;
          _activeSosId = sosId;
          _activeLocation = location;
          _isStateLoaded = true;
        });
        
        print('SOS State loaded: active=$isActive, sosId=$sosId, location=$location');
      }
    } catch (e) {
      print('Error loading SOS state: $e');
      if (mounted) {
        setState(() {
          _isStateLoaded = true;
        });
      }
    }
  }

  /// Save SOS state to SharedPreferences
  Future<void> _saveSOSState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sos_active', _isSOSActive);
      if (_activeSosId != null) {
        await prefs.setString('active_sos_id', _activeSosId!);
      } else {
        await prefs.remove('active_sos_id');
      }
      if (_activeLocation != null) {
        await prefs.setString('active_location', _activeLocation!);
      } else {
        await prefs.remove('active_location');
      }
    } catch (e) {
      print('Error saving SOS state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom;
    final sosButtonSize = (availableHeight * 0.25).clamp(150.0, 200.0); // Responsive SOS button size
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.screenMargins),
          child: Column(
            children: [
              const SizedBox(height: 8),
              
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
              
              const SizedBox(height: 8),
              
              // App Title
              const Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rapid',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlack,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'Response Team',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: AppTheme.neutralGrey,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Backend Status
              Consumer(
                builder: (context, ref, child) {
                  return FutureBuilder<bool>(
                    future: _serverConnectionFuture,
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
                              onPressed: _refreshFutures, // Refresh server connection
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
              
              const SizedBox(height: 12),
              
              // Location Status
              Consumer(
                builder: (context, ref, child) {
                  final locationService = ref.read(locationServiceProvider);
                  
                  return FutureBuilder<bool>(
                    future: _locationPermissionFuture,
                    builder: (context, permissionSnapshot) {
                      if (permissionSnapshot.connectionState == ConnectionState.waiting) {
                        return const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.neutralGrey,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Checking location...',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.neutralGrey,
                              ),
                            ),
                          ],
                        );
                      }
                      
                      final hasPermission = permissionSnapshot.data ?? false;
                      
                      if (!hasPermission) {
                        return Row(
                          children: [
                            const Icon(
                              Icons.location_off,
                              color: AppTheme.accentRed,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Location permission required',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.accentRed,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await locationService.requestLocationPermission();
                                _refreshFutures();
                              },
                              child: const Text('Allow'),
                            ),
                          ],
                        );
                      }
                      
                      // Get current address if permission is granted
                      // Cache the address future to prevent rebuilds
                      _locationAddressFuture ??= locationService.getCurrentAddress();
                      
                      return FutureBuilder<String?>(
                        future: _locationAddressFuture,
                        builder: (context, addressSnapshot) {
                          if (addressSnapshot.connectionState == ConnectionState.waiting) {
                            return const Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.neutralGrey,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Getting location...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.neutralGrey,
                                  ),
                                ),
                              ],
                            );
                          }
                          
                          final address = addressSnapshot.data;
                          
                          return Row(
                            children: [
                              Icon(
                                address != null && address != 'Address unavailable' 
                                  ? Icons.location_on 
                                  : Icons.location_off,
                                color: address != null && address != 'Address unavailable'
                                  ? AppTheme.primaryBlack
                                  : AppTheme.accentRed,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  address ?? 'Location unavailable',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: address != null && address != 'Address unavailable'
                                      ? AppTheme.primaryBlack
                                      : AppTheme.accentRed,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  size: 20,
                                  color: AppTheme.neutralGrey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _locationAddressFuture = null; // Clear cache to refresh
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
              
              // Flexible spacer to center SOS section
              const Expanded(
                child: Center(
                  child: SizedBox(), // Empty spacer
                ),
              ),
              
              
              // SOS Button Section
              if (!_isStateLoaded) ...[
                // Loading state
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    const Text(
                      'Loading emergency controls...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.neutralGrey,
                      ),
                    ),
                  ],
                ),
              ] else if (_isSOSActive) ...[
                // Active SOS State
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Emergency SOS Active',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.accentRed,
                        letterSpacing: -0.01,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Location Display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppTheme.accentRed,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _activeLocation ?? 'Emergency Location',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryBlack,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'People in your district have been notified.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.neutralGrey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Stop SOS Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlack,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: _isSendingSOS ? null : _handleStopSOS,
                        child: Center(
                          child: _isSendingSOS
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: AppTheme.pureWhite,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Stopping...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.pureWhite,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'STOP SOS',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.pureWhite,
                                  letterSpacing: 1,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Inactive SOS State (Original)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // SOS Button - Enhanced 3D Glossy Design
                    Container(
                      width: sosButtonSize,
                      height: sosButtonSize,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // Main gradient background for 3D effect
                          gradient: _isSendingSOS 
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.neutralGrey.withValues(alpha: 0.8),
                                  AppTheme.neutralGrey,
                                  AppTheme.neutralGrey.withValues(alpha: 0.7),
                                ],
                                stops: const [0.0, 0.6, 1.0],
                              )
                            : _isHoldingButton
                              ? const RadialGradient(
                                  center: Alignment(0.3, 0.3), // Inverted for pressed effect
                                  radius: 1.2,
                                  colors: [
                                    Color(0xFFB71C1C), // Deep red shadow (now highlight)
                                    Color(0xFFCC2936), // Darker red for depth (now mid)
                                    Color(0xFFE63946), // Main red (now deeper)
                                    Color(0xFFFF6B6B), // Lighter red highlight (now deepest)
                                  ],
                                  stops: [0.0, 0.4, 0.8, 1.0],
                                )
                              : const RadialGradient(
                                  center: Alignment(-0.3, -0.3),
                                  radius: 1.2,
                                  colors: [
                                    Color(0xFFFF6B6B), // Lighter red highlight
                                    Color(0xFFE63946), // Main red
                                    Color(0xFFCC2936), // Darker red for depth
                                    Color(0xFFB71C1C), // Deep red shadow
                                  ],
                                  stops: [0.0, 0.4, 0.8, 1.0],
                                ),
                          // Add shadow that changes when pressed
                          boxShadow: _isHoldingButton 
                            ? [
                                // Pressed/inset shadow effect
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: -2,
                                  offset: const Offset(0, -2),
                                ),
                              ]
                            : [],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // Glossy highlight overlay - changes when pressed
                            gradient: _isHoldingButton
                              ? LinearGradient(
                                  begin: Alignment.bottomRight,
                                  end: Alignment.topLeft,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.1),
                                    Colors.black.withValues(alpha: 0.2),
                                    Colors.black.withValues(alpha: 0.1),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                )
                              : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.center,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.4),
                                    Colors.white.withValues(alpha: 0.1),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.3, 1.0],
                                ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: GestureDetector(
                              onTapDown: _isSendingSOS ? null : _startHoldTimer,
                              onTapUp: _isSendingSOS ? null : _cancelHoldTimer,
                              onTapCancel: _isSendingSOS ? null : _cancelHoldTimer,
                                child: Container(
                                width: sosButtonSize,
                                height: sosButtonSize,
                                // Apply transform for pressed effect
                                transform: _isHoldingButton 
                                  ? (Matrix4.identity()..translate(2.0, 2.0)) // Slightly inset when pressed
                                  : Matrix4.identity(),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _isHoldingButton 
                                      ? Colors.white.withValues(alpha: 0.1) 
                                      : Colors.white.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: _isSendingSOS 
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const CircularProgressIndicator(
                                            color: AppTheme.pureWhite,
                                            strokeWidth: 3,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Sending...',
                                            style: TextStyle(
                                              fontSize: sosButtonSize * 0.08, // Responsive font size
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.pureWhite,
                                              shadows: const [
                                                Shadow(
                                                  offset: Offset(0, 1),
                                                  blurRadius: 2,
                                                  color: Colors.black26,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'SOS',
                                            style: TextStyle(
                                              fontSize: sosButtonSize * 0.16, // Responsive font size
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.pureWhite,
                                              letterSpacing: 2,
                                              shadows: _isHoldingButton
                                                ? const [
                                                    Shadow(
                                                      offset: Offset(0, -1),
                                                      blurRadius: 3,
                                                      color: Colors.black45,
                                                    ),
                                                  ]
                                                : const [
                                                    Shadow(
                                                      offset: Offset(0, 2),
                                                      blurRadius: 4,
                                                      color: Colors.black26,
                                                    ),
                                                  ],
                                            ),
                                          ),
                                        ],
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Hold instruction
                    Text(
                      _isHoldingButton 
                        ? 'Keep holding...' 
                        : 'Hold for 3 seconds to send alert',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.neutralGrey,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Emergency Message Input (Optional)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: 1,
                        maxLength: 100,
                        decoration: const InputDecoration(
                          hintText: 'Optional Message',
                          border: InputBorder.none,
                          counterStyle: TextStyle(fontSize: 12),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Bottom spacer
              const Expanded(
                child: SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Start hold timer when user presses down on SOS button
  void _startHoldTimer(TapDownDetails details) {
    if (_isSendingSOS) return;
    
    setState(() {
      _isHoldingButton = true;
      _holdProgress = 0;
    });
    
    _holdTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _holdProgress++;
      });
      
      if (_holdProgress >= 3) {
        timer.cancel();
        _holdTimer = null;
        _isHoldingButton = false;
        _handleSOSPress(); // Trigger SOS after 3 seconds
      }
    });
  }
  
  /// Cancel hold timer when user releases or cancels tap
  void _cancelHoldTimer([TapUpDetails? details]) {
    _holdTimer?.cancel();
    _holdTimer = null;
    
    if (mounted) {
      setState(() {
        _isHoldingButton = false;
        _holdProgress = 0;
      });
    }
  }

  /// Handle SOS button press
  Future<void> _handleSOSPress() async {
    final sosService = ref.read(sosServiceProvider);
    final locationService = ref.read(locationServiceProvider);
    
    setState(() {
      _isSendingSOS = true;
    });

    try {
      // Get current location from location service
      final locationData = await locationService.getCurrentLocation();
      
      if (locationData == null) {
        throw Exception('Unable to get current location. Please enable location services and try again.');
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

      // Generate unique SOS ID
      final sosId = 'sos_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';

      // Get user profile data for emergency contact info
      final userName = await ProfileService.getUserName() ?? 'Emergency Contact';
      final userMobile = await ProfileService.getUserMobile() ?? '';
      
      // Get current address for notification
      final currentAddress = await locationService.getCurrentAddress() ?? 'Location unavailable';
      
      final response = await sosService.sendSOSAlert(
        sosId: sosId,
        sosType: 'sos_alert',
        location: currentPosition,
        userInfo: {
          'deviceId': 'mobile-device',
          'platform': 'flutter',
          'appVersion': '1.0.0',
          'name': userName,
          'mobile_number': userMobile,
          'timestamp': DateTime.now().toIso8601String(),
          'message': _messageController.text.trim().isEmpty 
                    ? 'Emergency assistance needed' 
                    : _messageController.text.trim(),
          'location': currentAddress,
        },
      );

      if (response.success) {
        if (mounted) {
          // Activate SOS state
          setState(() {
            _isSOSActive = true;
            _activeSosId = sosId;
          });
          
          // Get current address for display
          final address = await locationService.getCurrentAddress();
          setState(() {
            _activeLocation = address ?? 'Emergency Location';
          });
          
          // Save state to persistence
          await _saveSOSState();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Emergency alert sent successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${response.error ?? "Failed to send emergency alert"}'),
              backgroundColor: AppTheme.accentRed,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Emergency alert failed: ${e.toString()}'),
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

  /// Handle Stop SOS button press
  Future<void> _handleStopSOS() async {
    if (_activeSosId == null) return;

    final sosService = ref.read(sosServiceProvider);
    final locationService = ref.read(locationServiceProvider);
    
    setState(() {
      _isSendingSOS = true;
    });

    try {
      // Get current location for the stop request
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

      // Get user profile data for stop notification
      final userName = await ProfileService.getUserName() ?? 'Emergency Contact';
      final userMobile = await ProfileService.getUserMobile() ?? '';
      
      // Get current address for stop notification
      final currentAddress = await locationService.getCurrentAddress() ?? 'Location unavailable';

      // Send stop SOS request
      final response = await sosService.sendSOSAlert(
        sosId: _activeSosId!,
        sosType: 'stop',
        location: currentPosition,
        userInfo: {
          'deviceId': 'mobile-device',
          'platform': 'flutter',
          'appVersion': '1.0.0',
          'name': userName,
          'mobile_number': userMobile,
          'timestamp': DateTime.now().toIso8601String(),
          'location': currentAddress,
        },
      );

      if (response.success) {
        if (mounted) {
          // Deactivate SOS state
          setState(() {
            _isSOSActive = false;
            _activeSosId = null;
            _activeLocation = null;
          });
          
          // Clear saved state
          await _saveSOSState();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Emergency alert stopped successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${response.error ?? "Failed to stop emergency alert"}'),
              backgroundColor: AppTheme.accentRed,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Stop request failed: ${e.toString()}'),
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
}