import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class RrtLogo extends StatelessWidget {
  final double size;
  final double iconSize;
  final double borderWidth;
  final double borderRadius;
  final Color borderColor;
  final Color iconColor;
  final IconData icon;
  final bool showBorder;

  const RrtLogo({
    super.key,
    this.size = 48,
    this.iconSize = 24,
    this.borderWidth = 1,
    this.borderRadius = 0,
    this.borderColor = AppTheme.primaryBlack,
    this.iconColor = AppTheme.primaryBlack,
    this.icon = Icons.pets,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showBorder) {
      return SizedBox(
        width: size,
        height: size,
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: iconColor,
      ),
    );
  }
}

class RrtWordmark extends StatelessWidget {
  final String title;
  final String subtitle;
  final double titleSize;
  final double subtitleSize;
  final Color titleColor;
  final Color subtitleColor;
  final FontWeight titleWeight;
  final FontWeight subtitleWeight;
  final double height;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;

  const RrtWordmark({
    super.key,
    this.title = 'Rapid',
    this.subtitle = 'Response Team',
    this.titleSize = 32,
    this.subtitleSize = 32,
    this.titleColor = AppTheme.primaryBlack,
    this.subtitleColor = AppTheme.neutralGrey,
    this.titleWeight = FontWeight.bold,
    this.subtitleWeight = FontWeight.bold,
    this.height = 1.1,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          title,
          textAlign: textAlign,
          style: GoogleFonts.inter(
            fontSize: titleSize,
            fontWeight: titleWeight,
            color: titleColor,
            height: height,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: textAlign,
          style: GoogleFonts.inter(
            fontSize: subtitleSize,
            fontWeight: subtitleWeight,
            color: subtitleColor,
            height: height,
          ),
        ),
      ],
    );
  }
}

/// Combined branding widget with logo and wordmark
class RrtBranding extends StatelessWidget {
  final double scale;
  final bool showBorder;
  final double spacing;
  final CrossAxisAlignment alignment;

  const RrtBranding({
    super.key,
    this.scale = 1.0,
    this.showBorder = true,
    this.spacing = 32,
    this.alignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: alignment,
      children: [
        // Logo
        RrtLogo(
          size: 80 * scale,
          iconSize: showBorder ? 40 * scale : 80 * scale,
          borderWidth: showBorder ? 2 : 0,
          borderRadius: 0,
          showBorder: showBorder,
        ),
        SizedBox(height: spacing * scale),
        
        // Wordmark
        RrtWordmark(
          titleSize: 40 * scale,
          subtitleSize: 40 * scale,
          crossAxisAlignment: alignment,
          textAlign: alignment == CrossAxisAlignment.center 
              ? TextAlign.center 
              : TextAlign.left,
        ),
      ],
    );
  }
}
