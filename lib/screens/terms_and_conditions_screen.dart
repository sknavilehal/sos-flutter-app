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
                  // App Logo
                  const RrtLogo(
                    size: 64,
                    iconSize: 32,
                    borderWidth: 2,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 32),
                  
                  // App Title
                  const RrtWordmark(
                    titleSize: 32,
                    subtitleSize: 32,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Page Title
                  const Text(
                    'Terms &\nConditions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                    _buildSection(
                      '1. ACCEPTANCE OF TERMS',
                      'BY ACCESSING OR USING THE RAPID RESPONSE TEAM MOBILE APPLICATION, YOU AGREE TO BE BOUND BY THESE TERMS AND CONDITIONS AND OUR PRIVACY POLICY.',
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSection(
                      '2. EMERGENCY SERVICES',
                      'THE APP IS DESIGNED TO FACILITATE EMERGENCY COORDINATION. RAPID RESPONSE TEAM IS NOT A REPLACEMENT FOR LOCAL LAW ENFORCEMENT OR PRIMARY MEDICAL SERVICES.',
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSection(
                      '3. DATA PRIVACY & SOS',
                      'Location access is required to determine your district. SOS alerts are sent only to users within the same district. Data is used solely for App functionality and is not sold or shared for advertising purposes.',
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSection(
                      '4. SOS USAGE RULES',
                      'You agree to use the SOS feature only for genuine emergencies, including threat to life or safety, accidents or medical emergencies, animal injury or cruelty, and situations requiring immediate animal welfare community assistance.\n\n🚫 Prohibited use includes false or prank alerts, harassment or intimidation, political, religious, or promotional activity, and any unlawful activity.',
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSection(
                      '5. VOLUNTEER-BASED RESPONSE',
                      'All users act as volunteers. Responding to an SOS is voluntary. RRT does not guarantee response, timing, or outcome. Users must act responsibly, lawfully, and prioritize personal safety.',
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSection(
                      '6. NO EMERGENCY SERVICE GUARANTEE',
                      'RRT does not replace Police, Ambulance services, Fire services, or Government/animal welfare authorities. Users are advised to contact official emergency services when required.',
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSection(
                      '7. LIMITATION OF LIABILITY',
                      'To the maximum extent permitted by law, RRT is not liable for injuries, losses, damages, delays, or failures arising from use of the App. Use of the App is at your own risk.',
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSection(
                      '8. GOVERNING LAW',
                      'These Terms are governed by the laws of India. Courts in India shall have exclusive jurisdiction.',
                    ),
                    const SizedBox(height: 32),
                    
                    const Text(
                      'Last Updated: 22/01/2026',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.neutralGrey,
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
              color: Colors.black.withOpacity(0.1),
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

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlack,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.neutralGrey,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
