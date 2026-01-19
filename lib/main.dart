import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/fcm_service.dart';
import 'core/services/notification_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/alerts_screen.dart';

/// Top-level function for handling background FCM messages
/// Required to be outside any class for Firebase to access it
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.handleBackgroundMessage(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (gracefully handle configuration errors)
  try {
    await Firebase.initializeApp();
    
    // Set up background message handler only if Firebase is initialized
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    // Firebase configuration not found - app will run without Firebase features
    // Silent error handling - Firebase not configured
    // Error details suppressed for cleaner logs
  }
  
  runApp(const ProviderScope(child: RRTApp()));
}

/// Global navigator key for handling navigation from FCM notifications
/// This allows navigation from anywhere in the app, including background contexts
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class RRTApp extends ConsumerWidget {
  const RRTApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize notification service with navigator key and Riverpod ref
    // This enables FCM notifications to navigate and update state
    NotificationService.initialize(navigatorKey, ref);
    
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      navigatorKey: navigatorKey, // Attach global navigator key
      home: const OnboardingScreen(), // Start with onboarding
      debugShowCheckedModeBanner: false,
      // Define named routes for navigation from notifications
      routes: {
        '/alerts': (context) => const AlertsScreen(),
      },
    );
  }
}
