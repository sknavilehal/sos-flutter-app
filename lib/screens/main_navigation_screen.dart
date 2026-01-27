import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../widgets/rrt_screen_layout.dart';
import '../widgets/rrt_footer_badges.dart';
import 'home_screen.dart';
import 'alerts_screen.dart';
import 'profile_screen.dart';

/// Main navigation screen with bottom navigation bar
/// Uses shared RrtScreenContent layout for consistent header across all tabs
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const AlertsScreen(),
    const ProfileScreen(),
  ];

  /// Get screen-specific footer for the current tab
  /// AlertsScreen has a privacy notice, others have no footer
  Widget? _getFooterForCurrentTab() {
    switch (_currentIndex) {
      case 1: // Alerts screen
        return const Center(
          child: Text(
            'CONTACT DETAILS ARE VISIBLE ONLY WHILE THIS\nALERT IS ACTIVE.',
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
        child: Column(
          children: [
            // Main content area with shared header and tab-specific body
            Expanded(
              child: RrtScreenContent(
                showHeader: true,
                headerAlignment: CrossAxisAlignment.start,
                useScrollView: false, // Each screen manages its own scroll behavior
                body: _screens[_currentIndex],
                footer: _getFooterForCurrentTab(),
              ),
            ),
            
            // Bottom Navigation Bar
            Container(
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
                selectedLabelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 12,
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
                ],
              ),
            ),
            
            // Global footer badges (below navigation bar)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenMargins,
                vertical: 12,
              ),
              color: AppTheme.backgroundColor,
              child: const RrtFooterBadges(),
            ),
          ],
        ),
      ),
    );
  }
}