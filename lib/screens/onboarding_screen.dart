import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import 'terms_and_conditions_screen.dart';
import '../widgets/rrt_screen_layout.dart';
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
        child: RrtScreenContent(
          showHeader: true,
          headerAlignment: CrossAxisAlignment.start,
          headerTitleSize: 40,
          headerSubtitleSize: 40,
          useScrollView: false,
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          body: const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
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
              ],
            ),
          ),
        ),
      ),
      // Bottom button and footer (like Terms screen)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: const BoxDecoration(
          color: AppTheme.backgroundColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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