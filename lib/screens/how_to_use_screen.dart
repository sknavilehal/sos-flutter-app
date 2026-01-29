import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../widgets/rrt_screen_layout.dart';
import '../widgets/onboarding_flow_bottom_bar.dart';

/// How to Use screen showing app usage instructions
class HowToUseScreen extends StatefulWidget {
  const HowToUseScreen({super.key});

  @override
  State<HowToUseScreen> createState() => _HowToUseScreenState();
}

class _HowToUseScreenState extends State<HowToUseScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      body: SafeArea(
        child: RrtScreenContent(
          showHeader: true,
          headerAlignment: CrossAxisAlignment.start,
          useScrollView: false,
          body: Column(
            children: [
              // Page Title
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'How to Use',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlack,
                    height: 1.2,
                  ),
                ),
              ),
              
              // Content (Scrollable)
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 28, right: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        _buildStep(
                          'Step 1',
                          'Accept Terms',
                          'You must accept the Terms & Conditions to use the app.',
                        ),
                        
                        _buildStep(
                          'Step 2',
                          'One-Time Profile Setup',
                          'Enter your Full name and mobile number\nUse accurate, genuine details to ensure community trust (Full name helps build trust)\nThis step is required only once.',
                        ),
                        
                        _buildStep(
                          'Step 3',
                          'Enable Location Access',
                          'Allow location access when prompted\nLocation access is mandatory to send an SOS and share your live location\nWithout location access, an SOS cannot be sent\nOnce enabled, the app is ready for use.',
                        ),
                        
                        _buildStep(
                          'Step 4',
                          'Sending an SOS',
                          'Tap the SOS button when you require help\nThe SOS is delivered only to registered volunteers who:\n• Have completed app setup, and\n• Are located within your district\nAn active internet connection is required for SOS delivery',
                        ),
                        
                        _buildStep(
                          'Step 5',
                          'What Happens During an Active SOS',
                          'Volunteers can see:\n• Your name,\n• Your live location, and\n• Your phone number\nThis information is visible only while the SOS is active\nA push notification is sent to volunteers when the SOS starts',
                        ),
                        
                        _buildStep(
                          'Step 6',
                          'Ending the SOS',
                          'You may tap Stop SOS at any time\nWhen stopped:\n• The SOS is immediately removed from all volunteer screens\n• Your information is no longer visible\nIf not stopped manually, the SOS automatically expires after 90 minutes\nA push notification is sent to volunteers when the SOS ends (manual stop or auto-expiry)',
                        ),
                        
                        _buildStep(
                          'Live Alerts Only',
                          null,
                          'The app displays only currently active SOS alerts\nNo SOS history, logs, or past alerts are stored or visible',
                          isLast: true,
                        ),
                        
                        const SizedBox(height: 100), // Extra space for button
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Close Button (Fixed at bottom)
      bottomNavigationBar: OnboardingFlowBottomBar(
        label: 'CLOSE',
        onTap: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSection(String title, String? description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlack,
            letterSpacing: 0.3,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.justify,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.neutralGrey,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep(String stepLabel, String? title, String description, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stepLabel,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentRed,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          if (title != null) ...[
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlack,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.neutralGrey,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
