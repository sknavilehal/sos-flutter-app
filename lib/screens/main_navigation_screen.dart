import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/providers/alerts_provider.dart';
import '../widgets/rrt_screen_layout.dart';
import 'home_screen.dart';
import 'alerts_screen.dart';
import 'profile_screen.dart';
import 'help_screen.dart';

/// Main navigation screen with bottom navigation bar
/// Uses shared RrtScreenContent layout for consistent header across all tabs
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    // Register lifecycle observer to detect when app returns to foreground
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    // Unregister lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // When app returns to foreground (resumed), reload alerts from storage
    // This ensures alerts added while app was in background are displayed
    if (state == AppLifecycleState.resumed) {
      // Use Future.microtask to ensure the refresh happens after the current frame
      Future.microtask(() async {
        try {
          await ref.read(activeAlertsProvider.notifier).refreshFromStorage();
        } catch (e) {
          debugPrint('Error refreshing alerts from storage: $e');
        }
      });
    }
  }
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const AlertsScreen(),
    const ProfileScreen(),
    const HelpScreen(),
  ];

  /// Get screen-specific footer for the current tab
  /// AlertsScreen has a privacy notice, others have no footer
  Widget? _getFooterForCurrentTab() {
    switch (_currentIndex) {
      case 1: // Alerts screen
        return const Center(
          child: Text(
            'CONTACT DETAILS ARE VISIBLE ONLY WHILE AN ALERT IS ACTIVE.',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        );
      default:
        return null; // No footer for Home and Profile screens
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        bottom: false, // Don't apply safe area to bottom - let nav bar handle it
        child: RrtScreenContent(
          showHeader: true,
          headerAlignment: CrossAxisAlignment.start,
          useScrollView: false, // Each screen manages its own scroll behavior
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          footer: _getFooterForCurrentTab(),
        ),
      ),
      // Use Scaffold's bottomNavigationBar property for proper positioning
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: AppTheme.textSecondary,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          iconSize: 22,
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'ALERTS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'PROFILE',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.support),
              label: 'HELP',
            ),
          ],
        ),
      ),
    );
  }
}