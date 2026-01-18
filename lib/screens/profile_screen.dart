import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

/// Profile screen showing user information
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Arjun Singh');
  final TextEditingController _mobileController = TextEditingController(text: '+91 98765 43210');
  final TextEditingController _addressController = TextEditingController(text: '12th Main, Indiranagar');
  final String _currentDistrict = 'East Bangalore';
  
  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.screenMargins),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  'Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryBlack,
                    letterSpacing: -0.01,
                  ),
                ),
                
                const SizedBox(height: AppConstants.brandBodySpacing),
                
                // Name Field
                const Text(
                  'NAME',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutralGrey,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryBlack, width: 1),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryBlack, width: 1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryBlack, width: 1),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                
                const SizedBox(height: AppConstants.fieldSpacing),
                
                // Mobile Number Field
                const Text(
                  'MOBILE NUMBER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutralGrey,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _mobileController,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryBlack, width: 1),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryBlack, width: 1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryBlack, width: 1),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                
                const SizedBox(height: AppConstants.fieldSpacing),
                
                // Address Field
                const Text(
                  'ADDRESS (AUTO-POPULATED)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutralGrey,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _addressController,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppTheme.neutralGrey,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryBlack, width: 1),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryBlack, width: 1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryBlack, width: 1),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                
                const SizedBox(height: AppConstants.fieldSpacing),
                
                // District Field (Read-only)
                const Text(
                  'DISTRICT (AUTO-POPULATED)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutralGrey,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppTheme.primaryBlack, width: 1),
                    ),
                  ),
                  child: Text(
                    _currentDistrict,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppTheme.neutralGrey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                
                const SizedBox(height: AppConstants.brandBodySpacing),
                
                // Update Profile Button
                Container(
                  width: double.infinity,
                  height: AppConstants.primaryButtonHeight,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlack,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () {
                      // TODO: Save updated profile data
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully'),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'UPDATE PROFILE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Additional Options
                _buildOptionItem(
                  icon: Icons.location_on,
                  title: 'Location Permissions',
                  subtitle: 'Manage location access',
                  onTap: () {
                    // TODO: Handle location permissions
                  },
                ),
                
                const SizedBox(height: 16),
                
                _buildOptionItem(
                  icon: Icons.notifications,
                  title: 'Notification Settings',
                  subtitle: 'Manage alert notifications',
                  onTap: () {
                    // TODO: Handle notification settings
                  },
                ),
                
                const SizedBox(height: 16),
                
                _buildOptionItem(
                  icon: Icons.info,
                  title: 'About RRT',
                  subtitle: 'App version and information',
                  onTap: () {
                    // TODO: Show about dialog
                  },
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.textSecondary,
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
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}