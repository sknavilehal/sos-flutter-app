import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

/// Help screen with app usage instructions and support options
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  bool _isHowToUseExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenMargins),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          
          // How to Use Section
          _buildExpandableSection(
            title: 'How to Use',
            icon: Icons.info_outline,
            isExpanded: _isHowToUseExpanded,
            onTap: () {
              setState(() {
                _isHowToUseExpanded = !_isHowToUseExpanded;
              });
            },
            content: _buildHowToUseContent(),
          ),
          
          const SizedBox(height: 16),
          
          // Report Issue Button (non-functional as requested)
          _buildReportIssueButton(),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget content,
  }) {
    return Container(
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(0),
      //   border: Border.all(color: Colors.grey.shade200, width: 1),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withValues(alpha: 0.05),
      //       blurRadius: 10,
      //       offset: const Offset(0, 2),
      //     ),
      //   ],
      // ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: AppTheme.primaryBlack,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 24,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          
          // Expandable Content
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: content,
            ),
        ],
      ),
    );
  }

  Widget _buildHowToUseContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        
        _buildStep(
          number: '1',
          title: 'Agree to Terms',
          description: 'Read and agree to the Terms & Conditions to proceed.',
        ),
        
        _buildStep(
          number: '2',
          title: 'One-Time Profile Setup',
          description: '• Enter your name and mobile number.\n• Please use genuine details to maintain trust within the community.',
        ),
        
        _buildStep(
          number: '3',
          title: 'Ready to Use',
          description: '• Enable location access when prompted - this is mandatory to share your location during an SOS.\n• No repeated logins required.\n• Once your profile is set, the app is ready to use.',
        ),
        
        _buildStep(
          number: '4',
          title: 'Send an SOS',
          description: '• Tap the SOS button when you need help.\n• The alert is sent to registered volunteers within your district.\n• An active internet connection is required.',
        ),
        
        _buildStep(
          number: '5',
          title: 'While SOS Is Active',
          description: '• Volunteers can see who initiated the SOS and their location.\n• Phone number and location are visible only while the SOS is active.\n• Push notifications are sent when the SOS starts.',
        ),
        
        _buildStep(
          number: '6',
          title: 'Stop or Auto-Expire',
          description: '• Tap Stop SOS at any time — the alert disappears immediately for everyone.\n• If not stopped, the SOS automatically expires after 90 minutes.\n• A stop notification is also sent.',
        ),
        
        _buildStep(
          number: '7',
          title: 'Live Alerts Only',
          description: '• Only active SOS alerts are shown.\n• No past alerts or history are visible.',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number Circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlack,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.pureWhite,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlack,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportIssueButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: AppTheme.primaryBlack, width: 2),
      ),
      child: InkWell(
        onTap: () {
          // Functionality not implemented yet as per requirements
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report Issue feature coming soon'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bug_report_outlined,
              size: 20,
              color: AppTheme.primaryBlack,
            ),
            const SizedBox(width: 8),
            Text(
              'REPORT ISSUE',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlack,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
