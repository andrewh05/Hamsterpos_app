import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import 'splash_screen.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({Key? key}) : super(key: key);

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _serverIpController = TextEditingController();
  final _portController = TextEditingController(text: '3306');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  List<String> _databases = [];
  String? _selectedDatabase;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _serverIpController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _connectToServer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _databases = [];
      _selectedDatabase = null;
    });

    try {
      final host = _serverIpController.text.trim();
      final portStr = _portController.text.trim();
      final port = int.tryParse(portStr) ?? 3306;
      final user = _usernameController.text.trim();
      final password = _passwordController.text;

      if (host.isEmpty || user.isEmpty) {
        setState(() {
          _errorMessage = 'Please fill in all fields';
          _isLoading = false;
        });
        return;
      }
      // Quick reachability check to provide clearer feedback
      await DatabaseService.probeReachability(host: host, port: port);

      final databases = await DatabaseService.getAvailableDatabases(
        host: host,
        port: port,
        user: user,
        password: password,
      );

      setState(() {
        _databases = databases;
        _isLoading = false;
      });

      if (_databases.isEmpty) {
        setState(() {
          _errorMessage = 'No databases found';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDatabase() async {
    if (_selectedDatabase == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a database')),
      );
      return;
    }

    try {
      // Save configuration to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('server_ip', _serverIpController.text.trim());
      await prefs.setString('server_port', _portController.text.trim());
      await prefs.setString('mysql_user', _usernameController.text.trim());
      await prefs.setString('mysql_password', _passwordController.text);
      await prefs.setString('selected_database', _selectedDatabase!);
      await prefs.setBool('config_completed', true);

      // Close the connection
      await DatabaseService.closeConnection();

      // Navigate to splash screen
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving configuration: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Header
                const Text(
                  'Database Configuration',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Connect to your MySQL server',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 40),

                // Server IP
                TextField(
                  controller: _serverIpController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Server IP Address',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                    prefixIcon: const Icon(Icons.storage, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Port
                TextField(
                  controller: _portController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Port (default: 3306)',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                    prefixIcon: const Icon(Icons.numbers, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Username
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'MySQL Username',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'MySQL Password',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Error Message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Connect Button
                if (_databases.isEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _connectToServer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.white.withOpacity(0.5),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Color(0xFF6366F1)),
                              ),
                            )
                          : const Text(
                              'Connect',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                // Database Selection
                if (_databases.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Database',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedDatabase,
                          hint: Text(
                            'Choose a database',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          dropdownColor: const Color(0xFF4F46E5),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          items: _databases.map((String db) {
                            return DropdownMenuItem<String>(
                              value: db,
                              child: Text(db),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _selectedDatabase = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectDatabase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
