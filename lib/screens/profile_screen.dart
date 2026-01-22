import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/services/profile_service.dart';

/// Profile screen showing user information
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }
  
  Future<void> _loadProfileData() async {
    final name = await ProfileService.getUserName();
    final mobile = await ProfileService.getUserMobile();
    
    if (mounted) {
      setState(() {
        _nameController.text = name ?? '';
        _mobileController.text = mobile ?? '';
      });
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.screenMargins),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const Column(
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
              
              const SizedBox(height: 12),
              
              // Flexible spacer to center form content
              const Expanded(
                child: Center(
                  child: SizedBox(),
                ),
              ),
              
              // Form content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  
                  const SizedBox(height: 24),
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
                  
                  const SizedBox(height: 24),
                  
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
                    maxLength: 10,
                    decoration: const InputDecoration(
                      counterText: '',
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
                  
                  const SizedBox(height: 24),
                  
                  // Update Profile Button
                  Container(
                    width: double.infinity,
                    height: AppConstants.primaryButtonHeight,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlack,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () async {
                        final name = _nameController.text.trim();
                        final mobile = _mobileController.text.trim();
                        
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your name'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                          return;
                        }
                        
                        if (mobile.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your mobile number'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                          return;
                        }
                        
                        if (!ProfileService.isValidIndianMobile(mobile)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid 10-digit mobile number'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                          return;
                        }
                        
                        try {
                          await ProfileService.saveProfile(
                            name: name,
                            mobile: mobile,
                          );
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully'),
                                backgroundColor: AppTheme.successColor,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to update profile. Please try again.'),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                          }
                        }
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
                ],
              ),
              
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
}