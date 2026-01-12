import 'package:flutter/material.dart';
import 'table_selection_screen.dart';
import '../services/database_service.dart';
import '../utils/responsive_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String enteredPin = '';
  bool isError = false;
  bool isValidating = false;

  void onNumberPressed(String number) {
    if (enteredPin.length < 4) {
      setState(() {
        enteredPin += number;
        isError = false;
      });

      if (enteredPin.length == 4) {
        _checkPin();
      }
    }
  }

  void onBackspacePressed() {
    if (enteredPin.isNotEmpty) {
      setState(() {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
        isError = false;
      });
    }
  }

  void _checkPin() async {
    setState(() {
      isValidating = true;
    });

    try {
      // Validate PIN against database
      final isValid = await DatabaseService.validateUserPin(enteredPin);
      
      if (!mounted) return;
      
      setState(() {
        isValidating = false;
      });

      if (isValid) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TableSelectionScreen(),
          ),
        );
      } else {
        setState(() {
          isError = true;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              enteredPin = '';
              isError = false;
            });
          }
        });
      }
    } catch (e) {
      // Handle database errors
      if (!mounted) return;
      
      setState(() {
        isValidating = false;
        isError = true;
      });
      
      print('Login error: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Database error: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            enteredPin = '';
            isError = false;
          });
        }
      });
    }
  }

  Widget _buildNumberButton(String number) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getBorderRadius(
            context,
            mobile: 16.0,
            tablet: 20.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onNumberPressed(number),
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getBorderRadius(
              context,
              mobile: 16.0,
              tablet: 20.0,
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              number,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 28.0,
                  tablet: 34.0,
                  desktop: 40.0,
                ),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getBorderRadius(
            context,
            mobile: 16.0,
            tablet: 20.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getBorderRadius(
              context,
              mobile: 16.0,
              tablet: 20.0,
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: ResponsiveUtils.getResponsiveIconSize(
                context,
                mobile: 28.0,
                tablet: 34.0,
                desktop: 40.0,
              ),
              color: color ?? Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinDot(int index) {
    bool isFilled = index < enteredPin.length;
    final primaryColor = Theme.of(context).primaryColor;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isError
            ? const Color(0xFFEF4444)
            : isFilled
                ? primaryColor
                : Colors.transparent,
        border: Border.all(
          color: isError
              ? const Color(0xFFEF4444)
              : isFilled
                  ? primaryColor
                  : const Color(0xFFD1D5DB),
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTabletOrLarger = ResponsiveUtils.isTablet(context) || ResponsiveUtils.isDesktop(context);
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: isTabletOrLarger ? _buildTabletLayout(colorScheme) : _buildMobileLayout(colorScheme),
      ),
    );
  }

  // Mobile layout - vertical stacking
  Widget _buildMobileLayout(ColorScheme colorScheme) {
    return ResponsiveContainer(
      padding: ResponsiveUtils.getResponsivePadding(
        context,
        mobile: 24.0,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogoSection(colorScheme),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 48.0)),
                  _buildPinSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Tablet/iPad layout - side by side
  Widget _buildTabletLayout(ColorScheme colorScheme) {
    return Padding(
      padding: ResponsiveUtils.getResponsivePadding(
        context,
        tablet: 40.0,
        desktop: 48.0,
      ),
      child: Row(
        children: [
          // Left side - Logo and branding
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/logo.jpeg',
                        width: ResponsiveUtils.getResponsiveValue(
                          context,
                          mobile: 100.0,
                          tablet: 120.0,
                          desktop: 150.0,
                        ),
                        height: ResponsiveUtils.getResponsiveValue(
                          context,
                          mobile: 100.0,
                          tablet: 120.0,
                          desktop: 150.0,
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Hamster POS',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 40.0,
                          tablet: 48.0,
                          desktop: 56.0,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '2015 - 2016 ©',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 16.0,
                          tablet: 18.0,
                          desktop: 20.0,
                        ),
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, tablet: 40.0, desktop: 48.0)),
          // Right side - PIN entry
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: _buildPinSection(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Logo section widget
  Widget _buildLogoSection(ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          padding: ResponsiveUtils.getResponsivePadding(
            context,
            mobile: 24.0,
          ),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset(
            'assets/logo.jpeg',
            width: 80.0,
            height: 80.0,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Hamster POS',
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter your PIN to continue',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // PIN entry section widget
  Widget _buildPinSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Enter PIN',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              mobile: 24.0,
              tablet: 28.0,
              desktop: 32.0,
            ),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            mobile: 32.0,
            tablet: 40.0,
          ),
        ),
        // PIN Dots Display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPinDot(0),
            SizedBox(
              width: ResponsiveUtils.getResponsiveSpacing(
                context,
                mobile: 16.0,
                tablet: 20.0,
              ),
            ),
            _buildPinDot(1),
            SizedBox(
              width: ResponsiveUtils.getResponsiveSpacing(
                context,
                mobile: 16.0,
                tablet: 20.0,
              ),
            ),
            _buildPinDot(2),
            SizedBox(
              width: ResponsiveUtils.getResponsiveSpacing(
                context,
                mobile: 16.0,
                tablet: 20.0,
              ),
            ),
            _buildPinDot(3),
          ],
        ),
        if (isError) ...[
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(
              context,
              mobile: 16.0,
              tablet: 20.0,
            ),
          ),
          Text(
            'Incorrect PIN',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 14.0,
                tablet: 16.0,
              ),
              color: const Color(0xFFEF4444),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            mobile: 32.0,
            tablet: 40.0,
            desktop: 48.0,
          ),
        ),
        // Number Pad
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(
            context,
            mobile: 16.0,
            tablet: 20.0,
            desktop: 24.0,
          ),
          mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(
            context,
            mobile: 16.0,
            tablet: 20.0,
            desktop: 24.0,
          ),
          childAspectRatio: 1.2,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildNumberButton('1'),
            _buildNumberButton('2'),
            _buildNumberButton('3'),
            _buildNumberButton('4'),
            _buildNumberButton('5'),
            _buildNumberButton('6'),
            _buildNumberButton('7'),
            _buildNumberButton('8'),
            _buildNumberButton('9'),
            Container(), // Empty space
            _buildNumberButton('0'),
            _buildActionButton(
              icon: Icons.backspace_outlined,
              onTap: onBackspacePressed,
            ),
          ],
        ),
      ],
    );
  }
}
