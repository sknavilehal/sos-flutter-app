import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

class RrtPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double height;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final double iconSize;
  final double iconSpacing;
  final FontWeight fontWeight;
  final double letterSpacing;
  final TextStyle? textStyle;

  const RrtPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.height = AppConstants.primaryButtonHeight,
    this.backgroundColor = AppTheme.primaryBlack,
    this.foregroundColor = Colors.white,
    this.icon = Icons.arrow_forward,
    this.iconSize = 20,
    this.iconSpacing = 8,
    this.fontWeight = FontWeight.w500,
    this.letterSpacing = 1.2,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextStyle = textStyle ??
        TextStyle(
          color: foregroundColor,
          fontSize: 16,
          fontWeight: fontWeight,
          letterSpacing: letterSpacing,
        );

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: backgroundColor,
        child: InkWell(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: effectiveTextStyle,
              ),
              SizedBox(width: iconSpacing),
              Icon(
                icon,
                color: foregroundColor,
                size: iconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
