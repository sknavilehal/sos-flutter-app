import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/services/profile_service.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/rrt_branding.dart';
import '../widgets/rrt_primary_button.dart';

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
              const Row(
                children: [
                  RrtLogo(),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // App Title
              const RrtWordmark(
                titleSize: 32,
                subtitleSize: 32,
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
                    'Your Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryBlack,
                      letterSpacing: -0.01,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  // Name Field
                  LabeledTextField(
                    label: 'NAME',
                    controller: _nameController,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Mobile Number Field
                  LabeledTextField(
                    label: 'MOBILE NUMBER',
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    counterText: '',
                    textStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Update Profile Button
                  RrtPrimaryButton(
                    label: 'UPDATE PROFILE',
                    height: AppConstants.primaryButtonHeight,
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