import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import 'terms_and_conditions_screen.dart';

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
              
              // App Logo/Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pets,
                  size: 40,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 60),
              
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
              
              // Description
              const Text(
                'For animal welfare, feeders, and volunteers. Find help, and reach out when in need.',
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.primaryBlack,
                  height: 1.5,
                  letterSpacing: -0.01,
                ),
                textAlign: TextAlign.left,
              ),
              
              const SizedBox(height: AppConstants.brandBodySpacing),
              
              // Get Started Button
              Container(
                width: double.infinity,
                height: AppConstants.primaryButtonHeight,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBlack,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'GET STARTED',
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
              
              const SizedBox(height: 20),
            ],
            ),
          ),
        ),
      ),
    );
  }
}