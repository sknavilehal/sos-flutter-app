import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/services/profile_service.dart';
import 'profile_create_screen.dart';
import '../widgets/rrt_branding.dart';
import '../widgets/rrt_primary_button.dart';

/// Terms and Conditions screen shown once on first app launch
class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _acceptTerms() async {
    // Mark terms as accepted
    await ProfileService.setTermsAccepted(true);
    
    if (mounted) {
      // Navigate to profile create screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileCreateScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                children: [
                  // App Branding
                  const RrtBranding(
                    scale: 0.8,
                    showBorder: true,
                    spacing: 32,
                    alignment: CrossAxisAlignment.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Page Title
                  const Text(
                    'Terms &\nConditions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlack,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            
            // Terms Content (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Introduction
                    _buildIntroText(
                      'By downloading, installing, or using the Rapid Response Team (RRT) mobile application ("App"), you agree to these Terms & Conditions ("Terms"). If you do not agree, please do not use the App.',
                    ),
                    const SizedBox(height: 24),
                    
                    // Section 1: Description of Service
                    _buildSection(
                      '1. Description of Service',
                      'Rapid Response Team (RRT) is a community-based emergency alert application that allows users to send SOS alerts to nearby users within the same district using location-based notifications.',
                    ),
                    _buildBulletList([
                      'Provides technology-only alerting',
                      'Does not provide emergency, medical, rescue, or law-enforcement services',
                      'Is free to use and non-commercial',
                    ]),
                    const SizedBox(height: 24),
                    
                    // Section 2: Eligibility
                    _buildSection(
                      '2. Eligibility',
                      'You may use this App only if:',
                    ),
                    _buildBulletList([
                      'You are 18 years of age or older',
                      'You provide your own valid mobile number',
                      'You consent to location access for district-based alerts',
                      'You agree not to impersonate any person or use another individual\'s phone number',
                    ]),
                    const SizedBox(height: 24),
                    
                    // Section 3: User Data & Permissions
                    _buildSection(
                      '3. User Data & Permissions',
                      'The App may collect and use:',
                    ),
                    _buildBulletList([
                      'Name and mobile number (entered by user)',
                      'Location data (to determine district only)',
                      'Device-related information for basic functionality',
                    ]),
                    const SizedBox(height: 12),
                    _buildBodyText(
                      'Data is used solely for App functionality and is not sold or shared for advertising purposes. Use of the App is also governed by the Privacy Policy.',
                    ),
                    const SizedBox(height: 24),
                    
                    // Section 4: Location-Based Alerts
                    _buildSection(
                      '4. Location-Based Alerts',
                      null,
                    ),
                    _buildBulletList([
                      'Location access is required to determine your district',
                      'SOS alerts are sent only to users within the same district',
                      'Accuracy depends on device GPS and network availability',
                      'Disabling location access may limit or prevent App functionality',
                    ]),
                    const SizedBox(height: 24),
                    
                    // Section 5: SOS Usage Rules
                    _buildSection(
                      '5. SOS Usage Rules',
                      'You agree to use the SOS feature only for genuine emergencies, including:',
                    ),
                    _buildBulletList([
                      'Threat to life or safety',
                      'Accidents or medical emergencies',
                      'Animal injury or cruelty',
                      'Situations requiring immediate animal welfare community assistance',
                    ]),
                    const SizedBox(height: 12),
                    _buildSubheading('🚫 Prohibited use includes:'),
                    _buildBulletList([
                      'False or prank alerts',
                      'Harassment or intimidation',
                      'Political, religious, or promotional activity',
                      'Any unlawful activity',
                    ]),
                    const SizedBox(height: 12),
                    _buildBodyText(
                      'Misuse may result in account/device blocking and reporting where required by law.',
                    ),
                    const SizedBox(height: 24),
                    
                    // Section 6: Volunteer-Based Response
                    _buildSection(
                      '6. Volunteer-Based Response',
                      null,
                    ),
                    _buildBulletList([
                      'All users act as volunteers',
                      'Responding to an SOS is voluntary',
                      'RRT does not guarantee response, timing, or outcome',
                      'Users must act responsibly, lawfully, and prioritize personal safety',
                    ]),
                    const SizedBox(height: 24),
                    
                    // Section 7: No Emergency Service Guarantee
                    _buildSection(
                      '7. No Emergency Service Guarantee',
                      'RRT does not replace:',
                    ),
                    _buildBulletList([
                      'Police',
                      'Ambulance services',
                      'Fire services',
                      'Government or animal welfare authorities',
                    ]),
                    const SizedBox(height: 12),
                    _buildBodyText(
                      'Users are advised to contact official emergency services when required.',
                    ),
                    const SizedBox(height: 24),
                    
                    // Section 8: No Communication Features
                    _buildSection(
                      '8. No Communication Features',
                      'The App:',
                    ),
                    _buildBulletList([
                      'Does not provide in-app chat, calling, or messaging',
                      'SOS alerts are one-way notifications only',
                    ]),
                    const SizedBox(height: 24),
                    
                    // Section 9: Content & Misuse
                    _buildSection(
                      '9. Content & Misuse',
                      'If content uploads (e.g., photos) are enabled in future versions:',
                    ),
                    _buildBulletList([
                      'Content must be lawful, accurate, and relevant',
                      'Graphic, misleading, or abusive content is prohibited',
                      'RRT reserves the right to remove content and restrict access',
                    ]),
                    const SizedBox(height: 24),
                    
                    // Section 10: Suspension & Termination
                    _buildSection(
                      '10. Suspension & Termination',
                      'RRT may suspend or terminate access without notice if:',
                    ),
                    _buildBulletList([
                      'These Terms are violated',
                      'Misuse or abuse is detected',
                      'Legal or safety risks arise',
                    ]),
                    const SizedBox(height: 24),
                    
                    // Section 11: Limitation of Liability
                    _buildSection(
                      '11. Limitation of Liability',
                      'To the maximum extent permitted by law:',
                    ),
                    _buildBulletList([
                      'RRT is not liable for injuries, losses, damages, delays, or failures arising from use of the App',
                      'Use of the App is at your own risk',
                    ]),
                    const SizedBox(height: 24),
                    
                    // Section 12: Changes to Terms
                    _buildSection(
                      '12. Changes to Terms',
                      'These Terms may be updated periodically. Continued use of the App indicates acceptance of the revised Terms.',
                    ),
                    const SizedBox(height: 24),
                    
                    // Section 13: Governing Law
                    _buildSection(
                      '13. Governing Law',
                      'These Terms are governed by the laws of India. Courts in India shall have exclusive jurisdiction.',
                    ),
                    const SizedBox(height: 32),
                    
                    const Text(
                      'Last Updated: 22/01/2026',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AppTheme.neutralGrey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 100), // Extra space for button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Accept Button (Fixed at bottom)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Accept Button
              RrtPrimaryButton(
                label: 'ACCEPT',
                height: 56,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                iconSpacing: 16,
                onTap: _acceptTerms,
              ),
              const SizedBox(height: 16),
              
              // Footer Text
              const Text(
                'SECURE ACCESS  •  PRIVACY ENSURED',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AppTheme.neutralGrey,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        color: AppTheme.primaryBlack,
        height: 1.6,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSection(String title, String? description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlack,
            letterSpacing: 0.3,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppTheme.neutralGrey,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubheading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryBlack,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildBodyText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        color: AppTheme.neutralGrey,
        height: 1.6,
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6, right: 8),
                child: Icon(
                  Icons.circle,
                  size: 6,
                  color: AppTheme.accentRed,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppTheme.neutralGrey,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
