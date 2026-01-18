import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import 'main_navigation_screen.dart';

/// Profile creation screen for first-time setup
class ProfileCreateScreen extends StatefulWidget {
  const ProfileCreateScreen({super.key});

  @override
  State<ProfileCreateScreen> createState() => _ProfileCreateScreenState();
}

class _ProfileCreateScreenState extends State<ProfileCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.screenMargins),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppConstants.iconTopMargin),
              
              // App Logo/Icon
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
              const Text(
                'Rapid',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                  height: 1.1,
                ),
              ),
              
              const Text(
                'Response Team',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.neutralGrey,
                  height: 1.1,
                ),
              ),
              
              const SizedBox(height: AppConstants.brandBodySpacing),
              
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
              
              const SizedBox(height: AppConstants.fieldSpacing),
              
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
                  color: AppTheme.primaryBlack,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter Name',
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
                  color: AppTheme.primaryBlack,
                ),
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '+1 (000) 000-0000',
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
              
              const SizedBox(height: AppConstants.brandBodySpacing),
              
              // Privacy Notice
              const Text(
                'MANDATORY FOR ALERTS.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'YOUR PHONE NUMBER IS EXPOSED ONLY WHEN AN SOS ALERT IS ACTIVE. PRIVACY BY DESIGN.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Save & Proceed Button
              Container(
                width: double.infinity,
                height: AppConstants.primaryButtonHeight,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlack,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: () {
                    if (_nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your name'),
                          backgroundColor: AppTheme.errorColor,
                        ),
                      );
                      return;
                    }
                    
                    if (_mobileController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your mobile number'),
                          backgroundColor: AppTheme.errorColor,
                        ),
                      );
                      return;
                    }
                    
                    // TODO: Save profile data
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SAVE & PROCEED',
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
              
              // Footer
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'SECURE ACCESS',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'PRIVACY ENSURED',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}