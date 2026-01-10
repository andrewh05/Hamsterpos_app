import 'package:flutter/material.dart';
import 'table_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String enteredPin = '';
  final String correctPin = '1234'; // Default PIN
  bool isError = false;

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

  void _checkPin() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (enteredPin == correctPin) {
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
          setState(() {
            enteredPin = '';
            isError = false;
          });
        });
      }
    });
  }

  Widget _buildNumberButton(String number) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(16),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
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
        borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(16),
          child: Container(
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 28,
              color: color ?? const Color(0xFF6366F1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinDot(int index) {
    bool isFilled = index < enteredPin.length;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isError
            ? const Color(0xFFEF4444)
            : isFilled
                ? const Color(0xFF6366F1)
                : Colors.transparent,
        border: Border.all(
          color: isError
              ? const Color(0xFFEF4444)
              : isFilled
                  ? const Color(0xFF6366F1)
                  : const Color(0xFFD1D5DB),
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Title Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/logo.jpeg',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Hamster POS',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter your PIN to continue',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 48),
                    // PIN Dots Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPinDot(0),
                        const SizedBox(width: 16),
                        _buildPinDot(1),
                        const SizedBox(width: 16),
                        _buildPinDot(2),
                        const SizedBox(width: 16),
                        _buildPinDot(3),
                      ],
                    ),
                    if (isError) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Incorrect PIN',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFFEF4444),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    // Number Pad
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
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
                    const SizedBox(height: 24),
                    // Hint text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF6366F1),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Default PIN: 1234',
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xFF6366F1),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
