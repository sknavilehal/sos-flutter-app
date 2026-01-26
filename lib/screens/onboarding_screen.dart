import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import 'terms_and_conditions_screen.dart';
import '../widgets/rrt_branding.dart';
import '../widgets/rrt_footer_badges.dart';
import '../widgets/rrt_primary_button.dart';

/// Onboarding/Welcome screen
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         AppConstants.defaultPadding * 2,
            ),
            child: Column(
            children: [
              const SizedBox(height: 60),
              
              // App Branding
              const RrtBranding(
                scale: 1.0,
                showBorder: true,
                spacing: 60,
                alignment: CrossAxisAlignment.center,
              ),
              
              const SizedBox(height: AppConstants.brandBodySpacing),
              
              // Description
              const Text(
                'Built for animal welfare, feeders, and volunteers.\nFind help, and reach out when in need.',
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.primaryBlack,
                  height: 1.5,
                  letterSpacing: -0.01,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              
              const SizedBox(height: AppConstants.brandBodySpacing),
              
              // Get Started Button
              RrtPrimaryButton(
                label: 'GET STARTED',
                height: AppConstants.primaryButtonHeight,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Footer
              const RrtFooterBadges(),
              
              const SizedBox(height: 20),
            ],
            ),
          ),
        ),
      ),
    );
  }
}