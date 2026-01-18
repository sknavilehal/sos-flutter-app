import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

/// Alerts screen showing nearby SOS situations
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  // Mock data for nearby alerts
  final List<Map<String, dynamic>> _alerts = [
    {
      'id': '1',
      'senderName': 'Rajesh',
      'location': '12th Main, Indiranagar • East Bangalore',
      'distance': '4kms away',
      'timeAgo': 'Started 4 mins ago',
      'status': 'ACTIVE',
      'phoneNumber': '+91 98765 43210',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: AppConstants.iconTopMargin),
                  
                  // App Header
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
                  
                  const SizedBox(height: AppConstants.iconBrandSpacing),
                  
                  // App Title
                  const Column(
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
                  
                  const SizedBox(height: AppConstants.brandBodySpacing),
                  
                  // Section Title
                  const Text(
                    'Nearby situations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryBlack,
                      letterSpacing: -0.01,
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.fieldSpacing),
                ],
              ),
            ),
            
            // Alerts content
            Expanded(
              child: _alerts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No active alerts in your area',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'You\'ll be notified when someone needs help nearby',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenMargins),
                      itemCount: _alerts.length,
                      itemBuilder: (context, index) {
                        return _buildAlertCard(_alerts[index]);
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

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentRed,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  alert['status'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${alert['distance']} • ${alert['timeAgo']}',
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
            'Raised by: ${alert['senderName']}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Location
          Text(
            'Location: ${alert['location']}',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.neutralGrey,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlack,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () => _makePhoneCall(alert['phoneNumber']),
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () => _getDirections(alert['location']),
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

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(phoneUri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open phone dialer'),
          ),
        );
      }
    }
  }

  void _getDirections(String location) async {
    final String encodedLocation = Uri.encodeComponent(location);
    final Uri mapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedLocation');
    
    try {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open maps'),
          ),
        );
      }
    }
  }
}