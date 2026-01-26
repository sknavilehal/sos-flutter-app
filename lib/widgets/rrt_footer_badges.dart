import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class RrtFooterBadges extends StatelessWidget {
  final MainAxisAlignment alignment;

  const RrtFooterBadges({
    super.key,
    this.alignment = MainAxisAlignment.spaceEvenly,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: const [
        Text(
          'SECURE ACCESS',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            letterSpacing: 1.0,
            fontFamily: 'JetBrainsMono',
          ),
        ),
        Text(
          'PRIVACY ENSURED',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            letterSpacing: 1.0,
            fontFamily: 'JetBrainsMono',
          ),
        ),
      ],
    );
  }
}
