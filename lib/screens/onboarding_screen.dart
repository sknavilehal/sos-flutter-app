import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import 'terms_and_conditions_screen.dart';
import '../widgets/rrt_screen_layout.dart';
import '../widgets/onboarding_flow_bottom_bar.dart';

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
          useScrollView: false,
          body: const Padding(
            padding: EdgeInsets.only(
              left: AppConstants.defaultPadding + 2,
              right: AppConstants.defaultPadding,
              top: 0,
              bottom: 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tagline
                Text(
                  'WHERE EMPATHY MEETS ACTION',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppTheme.primaryBlack,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.25 * 14, // 0.25em
                    height: 1.0,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 55),
                // Mission Line 1
                Text(
                  'Built for animal welfare workers, volunteers and feeders.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    color: AppTheme.primaryBlack,
                    height: 1.1,
                    letterSpacing: -0.04 * 28, // -0.04em
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 24),
                // Mission Line 2
                Text(
                  'Find help, and reach out when in need.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    color: AppTheme.primaryBlack,
                    height: 1.1,
                    letterSpacing: -0.04 * 28, // -0.04em
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ),
      // Bottom button and footer (like Terms screen)
      bottomNavigationBar: OnboardingFlowBottomBar(
        label: 'GET STARTED',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()),
          );
        },
      ),
    );
  }
}