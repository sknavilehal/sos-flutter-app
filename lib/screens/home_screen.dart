import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/providers/location_provider.dart';
import '../core/services/profile_service.dart';
import '../services/sos_service.dart';
import '../services/district_subscription_service.dart';
import '../widgets/rrt_primary_button.dart';

/// Home screen with location display and SOS button
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep state alive when switching tabs
  
  bool _isSendingSOS = false;
  bool _isSOSActive = false;
  String? _activeSosId;
  String? _activeLocation;
  final TextEditingController _messageController = TextEditingController();
  bool _isStateLoaded = false;
  String? _currentDistrict; // Cached district name
  
  // Hold to send SOS functionality
  double _holdProgress = 0.0; // 0.0 to 1.0
  Timer? _holdTimer;
  
  // District subscription service
  final _districtService = DistrictSubscriptionService();
  
  // Cache futures to prevent rebuilding
  Future<bool>? _serverConnectionFuture;
  Future<bool>? _locationPermissionFuture;
  Future<String?>? _locationAddressFuture;
  
  // Server health check caching
  static DateTime? _lastServerCheckTime;
  static bool? _lastServerCheckResult;
  static const _serverCheckInterval = Duration(minutes: 5);
  Timer? _serverHealthTimer;
  
  @override
  void initState() {
    super.initState();
    _loadSOSState();
    _initializeFutures();
    _checkAndInitializeDistrictSubscription(); // Only if permission exists
    _startPeriodicServerHealthCheck();
  }
  
  /// Check if we have permission, then initialize district subscription
  void _checkAndInitializeDistrictSubscription() {
    Future.microtask(() async {
      // DEBUG MODE: Set arbitrary district for testing on emulator
      if (kDebugMode) {
        debugPrint('DEBUG MODE: Setting test district for emulator');
        if (mounted) {
          setState(() {
            _currentDistrict = 'udupi'; // Change this to any district you want to test
          });
        }
        return;
      }
      
      final locationService = ref.read(locationServiceProvider);
      
      // Only initialize if we have permission
      final hasPermission = await locationService.hasLocationPermission();
      if (!hasPermission) {
        debugPrint('Skipping district subscription - no location permission');
        return;
      }
      
      final district = await _districtService.initializeDistrictSubscription(locationService);
      if (district != null && mounted) {
        setState(() {
          _currentDistrict = district;
        });
      }
    });
  }
  
  /// Initialize cached futures to prevent rebuilds
  void _initializeFutures() {
    // Use cached server status if available and recent
    if (_lastServerCheckResult != null && 
        _lastServerCheckTime != null && 
        DateTime.now().difference(_lastServerCheckTime!) < _serverCheckInterval) {
      // Use cached result
      _serverConnectionFuture = Future.value(_lastServerCheckResult);
    } else {
      // Perform new check
      _serverConnectionFuture = _checkServerConnection();
    }
    
    final locationService = ref.read(locationServiceProvider);
    _locationPermissionFuture = locationService.hasLocationPermission();
  }
  
  /// Check server connection and cache the result
  Future<bool> _checkServerConnection() async {
    try {
      final result = await ref.read(sosServiceProvider).testConnection();
      _lastServerCheckResult = result;
      _lastServerCheckTime = DateTime.now();
      return result;
    } catch (e) {
      debugPrint('Server connection check failed: $e');
      _lastServerCheckResult = false;
      _lastServerCheckTime = DateTime.now();
      return false;
    }
  }
  
  /// Start periodic server health check every 5 minutes
  void _startPeriodicServerHealthCheck() {
    _serverHealthTimer = Timer.periodic(_serverCheckInterval, (timer) {
      if (mounted) {
        _checkServerConnection().then((result) {
          if (mounted) {
            setState(() {
              _serverConnectionFuture = Future.value(result);
            });
          }
        });
      }
    });
  }
  
  /// Refresh cached futures when needed
  void _refreshFutures() {
    setState(() {
      _locationAddressFuture = null; // Clear address cache to refresh location
      // Force new server check by clearing cache
      _lastServerCheckResult = null;
      _lastServerCheckTime = null;
      _initializeFutures();
    });
  }
  
  /// Get current district with caching logic
  /// Returns cached district if available, otherwise fetches from location service
  Future<String?> _getCurrentDistrict() async {
    // Return cached district if available
    if (_currentDistrict != null) {
      return _currentDistrict;
    }
    
    // Fallback: fetch district from location service
    try {
      final locationService = ref.read(locationServiceProvider);
      final district = await locationService.getCurrentDistrict();
      
      // Cache the result
      if (district != null && mounted) {
        setState(() {
          _currentDistrict = district;
        });
      }
      
      return district;
    } catch (e) {
      debugPrint('Failed to get current district: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _holdTimer?.cancel();
    _serverHealthTimer?.cancel();
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
        
      }
    } catch (e) {
      debugPrint('SOS state load failed: $e');
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
      debugPrint('SOS state save failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    // When SOS is active, use a layout with bottom button similar to profile screen
    if (_isStateLoaded && _isSOSActive) {
      return Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.screenMargins + 2, // left
                  8, // top - reduced from 24
                  AppConstants.screenMargins, // right
                  AppConstants.screenMargins, // bottom
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                            return Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Row(
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
                                    isConnected ? 'SERVER CONNECTED' : 'SERVER OFFLINE',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'JetBrainsMono',
                                      color: isConnected ? Colors.green : AppTheme.accentRed,
                                    ),
                                  ),
                                  if (!isConnected) ...[
                                    const Spacer(),
                                    TextButton(
                                      onPressed: _refreshFutures,
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text('Retry', style: TextStyle(fontSize: 12)),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
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
                                      final granted = await locationService.requestLocationPermission();
                                      if (granted) {
                                        _refreshFutures();
                                        _checkAndInitializeDistrictSubscription();
                                      }
                                    },
                                    child: const Text('Allow'),
                                  ),
                                ],
                              );
                            }
                            
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
                                          _locationAddressFuture = null;
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
                    
                    const SizedBox(height: 24),
                    
                    // Active SOS State Content
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
                        borderRadius: BorderRadius.circular(0),
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
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom Button - Positioned like profile screen's bottomNavigationBar
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: const BoxDecoration(
              color: AppTheme.backgroundColor,
            ),
            child: _isSendingSOS
              ? Container(
                  width: double.infinity,
                  height: AppConstants.primaryButtonHeight,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryBlack,
                  ),
                  child: const Row(
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
                        'STOPPING...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.pureWhite,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                )
              : RrtPrimaryButton(
                  label: 'STOP SOS',
                  height: AppConstants.primaryButtonHeight,
                  icon: Icons.stop_circle_outlined,
                  onTap: _handleStopSOS,
                ),
          ),
        ],
      );
    }
    
    // Default layout for non-active SOS states
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.screenMargins + 2, // left
          8, // top - reduced from 24
          AppConstants.screenMargins, // right
          AppConstants.screenMargins, // bottom
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                      return Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Row(
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
                              isConnected ? 'SERVER CONNECTED' : 'SERVER OFFLINE',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'JetBrainsMono',
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
                        ),
                      );
                    },
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
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
                                final granted = await locationService.requestLocationPermission();
                                if (granted) {
                                  // Permission granted - refresh UI and initialize district subscription
                                  _refreshFutures();
                                  _checkAndInitializeDistrictSubscription();
                                }
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
              
              const SizedBox(height: 24),
              
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
              ] else if (!_isSOSActive) ...[
                // Inactive SOS State - Redesigned Button
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // SOS Button with Progress Ring
                    GestureDetector(
                      onLongPressStart: (_) => _startHoldTimer(),
                      onLongPressEnd: (_) => _cancelHoldTimer(),
                      onLongPressCancel: () => _cancelHoldTimer(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Progress Ring
                          if (_holdProgress > 0)
                            SizedBox(
                              width: _SosButton.glowDiameter + 20,
                              height: _SosButton.glowDiameter + 20,
                              child: CircularProgressIndicator(
                                value: _holdProgress,
                                strokeWidth: 6,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            ),
                          
                          // Main SOS Button with Design Tokens
                          _SosButton(isSending: _isSendingSOS),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Hold instruction
                    Text(
                      _holdProgress > 0 
                        ? 'Keep holding... ${((1 - _holdProgress) * 3).ceil()}s'
                        : 'Hold for 3 seconds to send alert',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: _holdProgress > 0 ? AppTheme.accentRed : AppTheme.neutralGrey,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Emergency Message Input (Optional)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(0),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: 1,
                        maxLength: 100,
                        decoration: InputDecoration(
                          hintText: 'Optional Message',
                          hintStyle: GoogleFonts.inter(),
                          border: InputBorder.none,
                          counterStyle: GoogleFonts.inter(
                            fontSize: 12,
                          ),
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.primaryBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Bottom spacer
              const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Start hold timer when user presses down on SOS button
  void _startHoldTimer() {
    if (_isSendingSOS || _holdTimer != null) return;
    
    const totalDuration = Duration(milliseconds: 3000);
    const tickInterval = Duration(milliseconds: 50);
    final totalTicks = totalDuration.inMilliseconds ~/ tickInterval.inMilliseconds;
    int currentTick = 0;
    
    _holdTimer = Timer.periodic(tickInterval, (timer) {
      currentTick++;
      setState(() {
        _holdProgress = currentTick / totalTicks;
      });
      
      if (_holdProgress >= 1.0) {
        timer.cancel();
        _holdTimer = null;
        _holdProgress = 0.0;
        _handleSOSPress(); // Trigger SOS after 3 seconds
      }
    });
  }
  
  /// Cancel hold timer when user releases or cancels tap
  void _cancelHoldTimer() {
    _holdTimer?.cancel();
    _holdTimer = null;
    
    setState(() {
      _holdProgress = 0.0;
    });
  }

  /// Handle SOS button press
  Future<void> _handleSOSPress() async {
    final sosService = ref.read(sosServiceProvider);
    final locationService = ref.read(locationServiceProvider);
    
    setState(() {
      _isSendingSOS = true;
    });

    try {
      // Check location permission first
      final hasPermission = await locationService.hasLocationPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Location permission required. Please allow location access first.'),
              backgroundColor: AppTheme.accentRed,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }
      
      // Get current location from location service
      final locationData = await locationService.getCurrentLocation();
      
      if (locationData == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Unable to get current location. Please check your location settings.'),
              backgroundColor: AppTheme.accentRed,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
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

      // Generate unique SOS ID based on stable user ID
      final userId = await ProfileService.getUserId();
      final sosId = 'sos_${userId}';

      // Get user profile data for emergency contact info
      final userName = await ProfileService.getUserName() ?? 'Emergency Contact';
      final userMobile = await ProfileService.getUserMobile() ?? '';
      
      // Get current address for notification
      final currentAddress = await locationService.getCurrentAddress() ?? 'Location unavailable';
      
      // Get current district for backend routing
      final district = await _getCurrentDistrict();
      
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
          'district': district,
        },
      );

      if (response.success) {
        if (!mounted) return;
        // Activate SOS state
        setState(() {
          _isSOSActive = true;
          _activeSosId = sosId;
        });
        
        // Get current address for display
        final address = await locationService.getCurrentAddress();
        if (!mounted) return;
        setState(() {
          _activeLocation = address ?? 'Emergency Location';
        });
        
        // Save state to persistence
        await _saveSOSState();
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Emergency alert sent successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
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
        // Clean error message without exception prefix
        final errorMessage = e.toString().replaceFirst('Exception: ', '').replaceFirst('Error: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Emergency alert failed: $errorMessage'),
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
      // Check location permission first
      final hasPermission = await locationService.hasLocationPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Location permission required to stop alert.'),
              backgroundColor: AppTheme.accentRed,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }
      
      // Get current location for the stop request
      final locationData = await locationService.getCurrentLocation();
      
      if (locationData == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Unable to get current location. Please check your location settings.'),
              backgroundColor: AppTheme.accentRed,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
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

      // Get current district for backend routing
      final district = await _getCurrentDistrict();

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
          'district': district,
        },
      );

      if (response.success) {
        if (!mounted) return;
        // Deactivate SOS state
        setState(() {
          _isSOSActive = false;
          _activeSosId = null;
          _activeLocation = null;
        });
        
        // Clear saved state
        await _saveSOSState();
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Emergency alert stopped successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
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
        // Clean error message without exception prefix
        final errorMessage = e.toString().replaceFirst('Exception: ', '').replaceFirst('Error: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Stop request failed: $errorMessage'),
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

/// SOS Button with design tokens
class _SosButton extends StatelessWidget {
  final bool isSending;
  
  const _SosButton({this.isSending = false});

  // === DESIGN TOKENS (DO NOT CHANGE) ===
  static const double buttonDiameter = 196.0;
  static const double glowDiameter = 205.8;
  static const double borderWidth = 6.0;
  static const double fontSize = 44.1;

  static const Color redLight = Color(0xFFFF4D4D);
  static const Color redDark = Color(0xFFB30000);
  static const Color borderRed = Color(0xFFCC0000);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: glowDiameter,
      height: glowDiameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // === OUTER GLOW ===
          Container(
            width: glowDiameter,
            height: glowDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(255, 0, 0, 0.15),
                  blurRadius: 40,
                  spreadRadius: 6,
                ),
              ],
            ),
          ),

          // === MAIN BUTTON ===
          Container(
            width: buttonDiameter,
            height: buttonDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.3, -0.3), // ≈ 35% / 35%
                radius: 0.8,
                colors: [
                  redLight,
                  redDark,
                ],
              ),
              border: Border.all(
                color: borderRed,
                width: borderWidth,
              ),
              boxShadow: const [
                // Inner top highlight
                BoxShadow(
                  color: Color.fromRGBO(255, 255, 255, 0.45),
                  offset: Offset(0, 4),
                  blurRadius: 8,
                ),
                // Inner bottom shadow
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.4),
                  offset: Offset(0, -4),
                  blurRadius: 8,
                ),
                // Ambient glow
                BoxShadow(
                  color: Color.fromRGBO(179, 0, 0, 0.25),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Stack(
              children: [

                // === TEXT ===
                Center(
                  child: isSending
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sending...',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'SOS',
                        style: GoogleFonts.inter(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          letterSpacing: -0.5,
                          color: Colors.white,
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}