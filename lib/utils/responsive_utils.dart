import 'package:flutter/material.dart';

/// Responsive utilities for handling different screen sizes
/// Mobile: width < 600px
/// Tablet: 600px ≤ width < 1024px
/// Desktop/iPad Pro: width ≥ 1024px
class ResponsiveUtils {
  /// Check if the current device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Check if the current device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  /// Check if the current device is desktop/large tablet
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  /// Get responsive value based on screen size
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    double mobile = 16.0,
    double? tablet,
    double? desktop,
  }) {
    final value = getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return EdgeInsets.all(value);
  }

  /// Get responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(
    BuildContext context, {
    double mobile = 16.0,
    double? tablet,
    double? desktop,
  }) {
    final value = getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return EdgeInsets.symmetric(horizontal: value);
  }

  /// Get responsive vertical padding
  static EdgeInsets getResponsiveVerticalPadding(
    BuildContext context, {
    double mobile = 16.0,
    double? tablet,
    double? desktop,
  }) {
    final value = getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return EdgeInsets.symmetric(vertical: value);
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive grid columns
  static int getGridColumns(
    BuildContext context, {
    int mobile = 2,
    int? tablet,
    int? desktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(
    BuildContext context, {
    double mobile = 8.0,
    double? tablet,
    double? desktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get max content width for centering on large screens
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 800.0; // Max width for desktop/large tablets
    } else if (isTablet(context)) {
      return 600.0; // Max width for tablets
    } else {
      return double.infinity; // Full width for mobile
    }
  }

  /// Get responsive button height
  static double getButtonHeight(
    BuildContext context, {
    double mobile = 48.0,
    double? tablet,
    double? desktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive border radius
  static double getBorderRadius(
    BuildContext context, {
    double mobile = 12.0,
    double? tablet,
    double? desktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}

/// Widget that centers content with max width on larger screens
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveUtils.getMaxContentWidth(context),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Responsive grid view builder
class ResponsiveGridView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final int mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double spacing;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;

  const ResponsiveGridView({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.mobileColumns = 2,
    this.tabletColumns,
    this.desktopColumns,
    this.spacing = 16.0,
    this.padding,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.getGridColumns(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    return GridView.builder(
      padding: padding,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1.0,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
