import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/notification_service.dart';
import 'core/services/offline_district_service.dart';
import 'core/services/profile_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/alerts_screen.dart';

/// Top-level function for handling background FCM messages
/// Required to be outside any class for Firebase to access it
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  
  // ✅ Background sender filtering: Check if this is a self-sent SOS alert
  final messageSenderId = message.data['sender_id'];
  if (messageSenderId != null) {
    try {
      // Use SharedPreferences directly since we can't use ProfileService in background
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('user_id');
      
      if (currentUserId != null && messageSenderId == currentUserId) {
        // Filter out self-sent SOS alerts in background
        return;
      }
    } catch (e) {
      // Continue processing if we can't determine user ID
    }
  }
  
  await NotificationService.handleBackgroundMessage(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock app to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Disable debug overflow indicators
  debugPaintSizeEnabled = false;
  
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
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      navigatorKey: navigatorKey, // Attach global navigator key
      home: FutureBuilder<Widget>(
        future: _initializeAndCheckProfile(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          // Return the appropriate screen based on profile status
          return snapshot.data ?? const OnboardingScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
      // Define named routes for navigation from notifications
      routes: {
        '/alerts': (context) => const AlertsScreen(),
      },
    );
  }
  
  /// Initialize async services and check profile status
  Future<Widget> _initializeAndCheckProfile(WidgetRef ref) async {
    // Initialize both services in parallel to avoid blocking
    // Notification service (critical) and District service (non-critical) run simultaneously
    await Future.wait([
      // District service: Loads district boundaries (2-10 seconds)
      // Non-critical - can fail without breaking app functionality
      OfflineDistrictService.instance.initialize()
        .catchError((e) {
          debugPrint('District service initialization failed: $e');
          // Return null to satisfy Future.wait
          return null;
        }),
      
      // Notification service: Sets up FCM handlers and permissions (< 1 second)
      // Critical - must initialize quickly for push notifications to work
      NotificationService.initialize(navigatorKey, ref),
    ]);
    
    // Check if profile exists to determine initial screen
    try {
      final name = await ProfileService.getUserName();
      final mobile = await ProfileService.getUserMobile();
      
      if (name != null && name.isNotEmpty && mobile != null && mobile.isNotEmpty) {
        // Profile exists, go to main app
        return const MainNavigationScreen();
      } else {
        // No profile, start with onboarding
        return const OnboardingScreen();
      }
    } catch (e) {
      // If there's an error, show onboarding to be safe
      return const OnboardingScreen();
    }
  }
}
