import 'package:flutter/material.dart';
import '../services/biometric_service.dart';
import '../services/firebase_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final BiometricService biometricService = BiometricService();
  bool isAuthenticating = false;
  String statusMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => tryAuthenticate());
  }

  Future<void> tryAuthenticate() async {
    setState(() {
      isAuthenticating = true;
      statusMessage = '';
    });

    bool ok = await biometricService.authenticate();

    setState(() {
      isAuthenticating = false;
    });

    if (ok) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      setState(() {
        statusMessage = 'Authentication failed or cancelled';
      });
    }
  }

  void useEmailPasswordInstead() async {
    await FirebaseService().signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E88E5),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fingerprint, color: Colors.white, size: 90),
              const SizedBox(height: 20),
              const Text(
                'App Locked',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Authenticate to continue',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 30),
              if (isAuthenticating)
                const CircularProgressIndicator(color: Colors.white)
              else ...[
                if (statusMessage != '')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(statusMessage, style: const TextStyle(color: Colors.white)),
                  ),
                ElevatedButton.icon(
                  onPressed: tryAuthenticate,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Try Again'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: useEmailPasswordInstead,
                  child: const Text(
                    'Use email & password instead',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}