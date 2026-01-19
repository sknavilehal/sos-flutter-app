import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/services/profile_service.dart';
import 'onboarding_screen.dart';
import 'main_navigation_screen.dart';

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
          // No profile, show onboarding
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        }
      }
    } catch (e) {
      // If there's an error reading profile, show onboarding
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
              // App Logo
              Icon(
                Icons.pets,
                size: 80,
                color: AppTheme.primaryBlack,
              ),
              SizedBox(height: 24),
              
              // App Title
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