import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Initialize Firebase
  // await Firebase.initializeApp();
  
  runApp(const ProviderScope(child: RRTApp()));
}

class RRTApp extends StatelessWidget {
  const RRTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      home: const OnboardingScreen(), // Start with onboarding
      debugShowCheckedModeBanner: false,
    );
  }
}
