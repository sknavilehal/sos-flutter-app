import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/services/profile_service.dart';
import 'onboarding_screen.dart';
import 'main_navigation_screen.dart';
import '../widgets/rrt_branding.dart';

/// Splash screen that checks profile status and routes accordingly
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkProfileAndNavigate();
  }

  Future<void> _checkProfileAndNavigate() async {
    // Add a brief delay for splash effect
    await Future.delayed(const Duration(milliseconds: 1500));
    
    try {
      // Check if profile already exists
      final name = await ProfileService.getUserName();
      final mobile = await ProfileService.getUserMobile();
      
      if (mounted) {
        if (name != null && name.isNotEmpty && mobile != null && mobile.isNotEmpty) {
          // Profile exists, go to main app
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          );
        } else {
          // No profile, start with onboarding
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        }
      }
    } catch (e) {
      // If there's an error, show onboarding to be safe
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Branding
              RrtBranding(
                scale: 1.0,
                showBorder: true,
                spacing: 24,
                alignment: CrossAxisAlignment.center,
              ),
              
              SizedBox(height: 40),
              
              // Loading indicator
              CircularProgressIndicator(
                color: AppTheme.primaryBlack,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}