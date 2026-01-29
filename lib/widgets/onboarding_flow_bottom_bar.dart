import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import 'rrt_footer_badges.dart';
import 'rrt_primary_button.dart';

class OnboardingFlowBottomBar extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double buttonHeight;
  final EdgeInsets? padding;
  final Color backgroundColor;

  const OnboardingFlowBottomBar({
    super.key,
    required this.label,
    required this.onTap,
    this.buttonHeight = AppConstants.primaryButtonHeight,
    this.padding,
    this.backgroundColor = AppTheme.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ?? const EdgeInsets.all(AppConstants.defaultPadding);

    return Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RrtPrimaryButton(
            label: label,
            height: buttonHeight,
            onTap: onTap,
          ),
          const SizedBox(height: 20),
          const RrtFooterBadges(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
