import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'login_screen.dart';
import 'connection_error_screen.dart';
import '../services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isCheckingConnection = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    // Test database connection after splash animation
    _checkDatabaseConnection();
  }

  Future<void> _checkDatabaseConnection() async {
    setState(() {
      _isCheckingConnection = true;
    });

    // Wait for splash animation (minimum 2 seconds)
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    try {
      print('📱 Checking database configuration...');
      // Check if database is configured
      final prefs = await SharedPreferences.getInstance();
      final host = prefs.getString('server_ip');
      final portStr = prefs.getString('server_port');
      final user = prefs.getString('mysql_user');
      final db = prefs.getString('selected_database');

      print('🔍 Config: host=$host, port=$portStr, user=$user, db=$db');

      if (host == null || portStr == null || user == null || db == null) {
        // Database not configured
        print('❌ Database not configured');
        _navigateToError('Database not configured. Please configure your database settings.');
        return;
      }

      final port = int.tryParse(portStr) ?? 3306;
      final password = prefs.getString('mysql_password') ?? '';

      print('🔌 Testing database connection...');
      // Test connection
      final isConnected = await DatabaseService.testConnection(
        host: host,
        port: port,
        user: user,
        password: password,
      );

      if (!mounted) return;

      if (isConnected) {
        // Connection successful - navigate to login
        print('✅ Connection successful! Navigating to login...');
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 1000),
          ),
        );
      } else {
        // Connection failed
        print('❌ Connection failed');
        _navigateToError('Unable to connect to database. Please check your network and database settings.');
      }
    } catch (e) {
      if (!mounted) return;
      print('❌ Error during connection check: $e');
      _navigateToError('Connection error: ${e.toString()}');
    }
  }

  void _navigateToError(String errorMessage) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ConnectionErrorScreen(
          errorMessage: errorMessage,
          onRetry: () {
            // Navigate back to splash to retry
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SplashScreen()),
            );
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;

          return Stack(
            children: [
              /// Base white background
              Container(color: Colors.white),

              /// Blue flowing layers (right side)
              Positioned.fill(
                child: CustomPaint(
                  painter: WavePainter(
                    shift: t,
                    colors: const [
                      Color(0xFFDCEEFF),
                      Color(0xFFC4E0FF),
                      Color(0xFFB2D6FF),
                    ],
                    alignRight: true,
                  ),
                ),
              ),

              /// Warm subtle glow (left side)
              Positioned.fill(
                child: CustomPaint(
                  painter: WavePainter(
                    shift: -t,
                    colors: const [
                      Color(0xFFFFE1C6),
                      Color(0xFFFFF2E6),
                      Colors.transparent,
                    ],
                    alignRight: false,
                  ),
                ),
              ),

              /// Your logo content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/logo.jpeg', // Using existing logo
                      width: 160,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Always think BIGGER',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Hamster POS 2015 - 2026 ©',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double shift;
  final List<Color> colors;
  final bool alignRight;

  WavePainter({
    required this.shift,
    required this.colors,
    required this.alignRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // We draw multiple waves layered on top of each other
    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i];
      final path = Path();
      
      final yOffset = i * 20.0;
      final waveHeight = 20.0 + (i * 10);
      
      if (alignRight) {
        // Draw mostly on the right side
        path.moveTo(size.width, 0); 
        path.lineTo(size.width, size.height);
        
        // Draw wave curve from bottom right to top right
        // We'll walk up the height
        for (double y = size.height; y >= 0; y -= 5) {
          // A nice organic wave function
          // x is calculated based on y
           final x = size.width - (size.width * 0.25) // Changed to 0.25 (middle ground)
              + math.sin((y / size.height * 4 * math.pi) + (shift * 2 * math.pi) + i) * waveHeight
              + (i * 30);
              
           // Taper off at the top/bottom so it doesn't look like a solid block
           final envelope = math.sin(y / size.height * math.pi);
           
           path.lineTo(x + (1-envelope) * 100, y);
        }
        path.close();
      } else {
        // Draw mostly on the left side
        path.moveTo(0, 0);
        path.lineTo(0, size.height);
        
        for (double y = size.height; y >= 0; y -= 5) {
           final x = (size.width * 0.2) // Changed to 0.2 (middle ground)
              + math.sin((y / size.height * 3 * math.pi) + (shift * 2 * math.pi) + i) * waveHeight
              - (i * 30);
              
           final envelope = math.sin(y / size.height * math.pi);
           path.lineTo(x - (1-envelope) * 50, y);
        }
        path.close();
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.shift != shift || oldDelegate.alignRight != alignRight;
  }
}
