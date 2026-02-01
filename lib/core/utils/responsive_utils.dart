import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Utility class for responsive design
class ResponsiveUtils {
  ResponsiveUtils._();

  /// Check if the current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;
  }

  /// Check if the current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.mobileBreakpoint &&
        width < AppConstants.desktopBreakpoint;
  }

  /// Check if the current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.desktopBreakpoint;
  }

  /// Get the number of columns for grid layout
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < AppConstants.mobileBreakpoint) return 1;
    if (width < AppConstants.tabletBreakpoint) return 2;
    if (width < AppConstants.desktopBreakpoint) return 3;
    return 4;
  }

  /// Get appropriate padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(8);
    }
    if (isTablet(context)) {
      return const EdgeInsets.all(16);
    }
    return const EdgeInsets.all(24);
  }

  /// Get appropriate card width for current screen
  static double getCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = getGridColumns(context);
    final padding = getScreenPadding(context).horizontal;
    final spacing = (columns - 1) * 16.0;
    return (width - padding - spacing) / columns;
  }
}

/// Responsive layout widget
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppConstants.desktopBreakpoint) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= AppConstants.mobileBreakpoint) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}
