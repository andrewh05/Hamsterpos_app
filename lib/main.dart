import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/config_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Check if configuration is already done
  final prefs = await SharedPreferences.getInstance();
  final isConfigCompleted = prefs.getBool('config_completed') ?? false;

  runApp(WaiterPOSApp(isConfigCompleted: isConfigCompleted));
}

class WaiterPOSApp extends StatelessWidget {
  final bool isConfigCompleted;

  const WaiterPOSApp({Key? key, required this.isConfigCompleted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waiter POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB2D6FF), // Soft Blue from waves
          primary: const Color(0xFFB2D6FF),
          secondary: const Color(0xFFFFE1C6), // Warm Orange from waves
          surface: Colors.white,
          background: const Color(0xFFF8FAFF), // Soft Cool White
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFF),
        fontFamily: 'SF Pro Display',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A1A),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFFB2D6FF), // Soft Blue
            foregroundColor: Colors.black87, // Dark text for contrast
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: false,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB2D6FF), width: 2), // Soft Blue focus
          ),
        ),
      ),
      home: isConfigCompleted ? const SplashScreen() : const ConfigScreen(),
    );
  }
}
