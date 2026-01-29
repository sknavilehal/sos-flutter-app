import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import 'rrt_branding.dart';

/// Reusable screen layout widget providing consistent structure across screens
/// 
/// Features:
/// - Optional header with Logo + Wordmark
/// - Flexible body content (scrollable or non-scrollable)
/// - Optional screen-specific footer
/// - Consistent padding and styling
/// 
/// Usage:
/// ```dart
/// RrtScreenLayout(
///   showHeader: true,
///   body: YourContentWidget(),
///   footer: OptionalFooterWidget(),
/// )
/// ```
class RrtScreenLayout extends StatelessWidget {
  /// Whether to show the header (Logo + Wordmark)
  final bool showHeader;
  
  /// Alignment for the header (left or center)
  final CrossAxisAlignment headerAlignment;
  
  /// Title size for the wordmark (default 32)
  final double headerTitleSize;
  
  /// Subtitle size for the wordmark (default 32)
  final double headerSubtitleSize;
  
  /// Whether to use SingleChildScrollView (true) or Column (false)
  /// Use true for simple scrollable content, false for custom scroll behavior (e.g., ListView)
  final bool useScrollView;
  
  /// The main body content of the screen
  final Widget body;
  
  /// Optional footer widget displayed at the bottom of the content area
  /// This appears ABOVE the bottom navigation bar (if present)
  final Widget? footer;
  
  /// Padding around the content (defaults to AppConstants.screenMargins)
  final EdgeInsets? padding;
  
  /// Background color (defaults to AppTheme.backgroundColor)
  final Color? backgroundColor;

  const RrtScreenLayout({
    super.key,
    this.showHeader = true,
    this.headerAlignment = CrossAxisAlignment.start,
    this.headerTitleSize = 32,
    this.headerSubtitleSize = 32,
    this.useScrollView = false,
    required this.body,
    this.footer,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppTheme.backgroundColor,
      body: SafeArea(
        child: RrtScreenContent(
          showHeader: showHeader,
          headerAlignment: headerAlignment,
          headerTitleSize: headerTitleSize,
          headerSubtitleSize: headerSubtitleSize,
          useScrollView: useScrollView,
          body: body,
          footer: footer,
          padding: padding,
        ),
      ),
    );
  }
}

/// Screen content widget without Scaffold wrapper
/// Used internally by RrtScreenLayout and can be used directly in MainNavigationScreen
class RrtScreenContent extends StatelessWidget {
  final bool showHeader;
  final CrossAxisAlignment headerAlignment;
  final double headerTitleSize;
  final double headerSubtitleSize;
  final bool useScrollView;
  final Widget body;
  final Widget? footer;
  final EdgeInsets? padding;

  const RrtScreenContent({
    super.key,
    this.showHeader = true,
    this.headerAlignment = CrossAxisAlignment.start,
    this.headerTitleSize = 32,
    this.headerSubtitleSize = 32,
    this.useScrollView = false,
    required this.body,
    this.footer,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.all(AppConstants.screenMargins);
    
    return useScrollView
        ? _buildScrollableLayout(effectivePadding)
        : _buildColumnLayout(effectivePadding);
  }

  /// Build layout with SingleChildScrollView (for simple scrollable content)
  Widget _buildScrollableLayout(EdgeInsets effectivePadding) {
    return SingleChildScrollView(
      child: Padding(
        padding: effectivePadding,
        child: Column(
          crossAxisAlignment: headerAlignment,
          children: [
            if (showHeader) ...[
              const SizedBox(height: 8),
              RrtHeaderBranding(
                alignment: headerAlignment,
                titleSize: headerTitleSize,
                subtitleSize: headerSubtitleSize,
              ),
              const SizedBox(height: 6),
            ],
            body,
            if (footer != null) ...[
              const SizedBox(height: 16),
              footer!,
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  /// Build layout with Column (for custom scroll behavior or non-scrollable content)
  Widget _buildColumnLayout(EdgeInsets effectivePadding) {
    return Column(
      crossAxisAlignment: headerAlignment,
      children: [
        if (showHeader)
          Padding(
            padding: effectivePadding,
            child: Column(
              crossAxisAlignment: headerAlignment,
              children: [
                const SizedBox(height: 8),
                RrtHeaderBranding(
                  alignment: headerAlignment,
                  titleSize: headerTitleSize,
                  subtitleSize: headerSubtitleSize,
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        Expanded(
          child: body,
        ),
        if (footer != null)
          Padding(
            padding: effectivePadding,
            child: Column(
              children: [
                const SizedBox(height: 16),
                footer!,
                const SizedBox(height: 16),
              ],
            ),
          ),
      ],
    );
  }

  // Header layout is centralized in RrtHeaderBranding.
}
