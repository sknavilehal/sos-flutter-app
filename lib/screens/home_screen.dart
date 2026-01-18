import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/providers/location_provider.dart';

/// Home screen with location display and SOS button
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
                    loading: () => const Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppTheme.neutralGrey,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Detecting location...',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.neutralGrey,
                          ),
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
                  color: AppTheme.accentRed,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentRed.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    // TODO: Handle SOS activation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('SOS activated!'),
                        backgroundColor: AppTheme.accentRed,
                      ),
                    );
                  },
                  child: const Center(
                    child: Column(
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
                          'Hold for emergency',
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