import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/services/profile_service.dart';
import 'main_navigation_screen.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/rrt_screen_layout.dart';
import '../widgets/rrt_footer_badges.dart';
import '../widgets/rrt_primary_button.dart';

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
        child: RrtScreenContent(
          showHeader: true,
          headerAlignment: CrossAxisAlignment.start,
          headerTitleSize: 40,
          headerSubtitleSize: 40,
          useScrollView: false,
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppConstants.defaultPadding + 4,
                right: AppConstants.defaultPadding,
                top: 0,
                bottom: 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Section Title
              const Text(
                'Your Profile',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBlack,
                  letterSpacing: -0.01,
                ),
              ),
              
              const SizedBox(height: AppConstants.fieldSpacing),
              
              // Name Field
              LabeledTextField(
                label: 'NAME',
                controller: _nameController,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                ],
                textStyle: const TextStyle(
                  fontSize: 20,
                  color: AppTheme.primaryBlack,
                ),
              ),
              
              const SizedBox(height: AppConstants.fieldSpacing),
              
              // Mobile Number Field
              LabeledTextField(
                label: 'MOBILE NUMBER',
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                counterText: '',
                textStyle: const TextStyle(
                  fontSize: 20,
                  color: AppTheme.primaryBlack,
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
                'YOUR PHONE NUMBER IS EXPOSED ONLY WHEN AN SOS ALERT IS ACTIVE.',
                style: TextStyle(
                  fontSize: 8,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
      // Bottom button and footer
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppConstants.screenMargins),
        decoration: const BoxDecoration(
          color: AppTheme.backgroundColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Save & Proceed Button
            RrtPrimaryButton(
              label: 'SAVE & PROCEED',
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to save profile. Please try again.'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                }
              },
            ),
            
            const SizedBox(height: 20),
            
            // Footer badges
            const RrtFooterBadges(),
            
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}