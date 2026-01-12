import 'package:flutter/material.dart';
import 'database_settings_screen.dart';
import '../utils/responsive_utils.dart';

class ConnectionErrorScreen extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ConnectionErrorScreen({
    Key? key,
    required this.errorMessage,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: ResponsiveContainer(
          padding: ResponsiveUtils.getResponsivePadding(
            context,
            mobile: 32.0,
            tablet: 48.0,
            desktop: 64.0,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error Icon
                Container(
                  padding: ResponsiveUtils.getResponsivePadding(
                    context,
                    mobile: 24.0,
                    tablet: 32.0,
                    desktop: 40.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_off_rounded,
                    size: ResponsiveUtils.getResponsiveIconSize(
                      context,
                      mobile: 80.0,
                      tablet: 100.0,
                      desktop: 120.0,
                    ),
                    color: const Color(0xFFEF4444),
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 32.0,
                    tablet: 40.0,
                    desktop: 48.0,
                  ),
                ),

                // Error Title
                Text(
                  'Connection Failed',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 28.0,
                      tablet: 34.0,
                      desktop: 40.0,
                    ),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 16.0,
                    tablet: 20.0,
                    desktop: 24.0,
                  ),
                ),

                // Error Message
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 16.0,
                      tablet: 18.0,
                      desktop: 20.0,
                    ),
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 48.0,
                    tablet: 56.0,
                    desktop: 64.0,
                  ),
                ),

                // Retry Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtils.getButtonHeight(
                          context,
                          mobile: 16.0,
                          tablet: 20.0,
                          desktop: 24.0,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getBorderRadius(context),
                        ),
                      ),
                    ),
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        mobile: 20.0,
                        tablet: 24.0,
                      ),
                    ),
                    label: Text(
                      'Retry Connection',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 16.0,
                          tablet: 18.0,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 16.0,
                    tablet: 20.0,
                  ),
                ),

                // Settings Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DatabaseSettingsScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      side: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtils.getButtonHeight(
                          context,
                          mobile: 16.0,
                          tablet: 20.0,
                          desktop: 24.0,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getBorderRadius(context),
                        ),
                      ),
                    ),
                    icon: Icon(
                      Icons.settings_rounded,
                      size: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        mobile: 20.0,
                        tablet: 24.0,
                      ),
                    ),
                    label: Text(
                      'Database Settings',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 16.0,
                          tablet: 18.0,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
