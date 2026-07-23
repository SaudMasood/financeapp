import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../services/firebase_service.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  FirebaseService firebaseService = FirebaseService();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String errorMessage = '';
  bool isLoading = false;
  bool biometricAvailable = false;

  final LocalAuthentication localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    checkBiometricSupport();
  }

  Future<void> checkBiometricSupport() async {
    bool canCheck = false;
    try {
      canCheck = await localAuth.canCheckBiometrics;
    } catch (e) {
      canCheck = false;
    }

    setState(() {
      biometricAvailable = canCheck;
    });
  }

  Future<void> loginUser() async {
    setState(() {
      errorMessage = '';
    });

    if (emailController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your email';
      });
      return;
    }

    if (passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your password';
      });
      return;
    }

    if (passwordController.text.length < 6) {
      setState(() {
        errorMessage = 'Password must be at least 6 characters';
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    String result = await firebaseService.signIn(
      emailController.text.trim(),
      passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (result == 'success') {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      setState(() {
        errorMessage = result;
      });
    }
  }

  Future<void> loginWithBiometrics() async {
    setState(() {
      errorMessage = '';
    });

    if (biometricAvailable == false) {
      setState(() {
        errorMessage = 'Biometric login not available on this device';
      });
      return;
    }

    bool authenticated = false;
    try {
      authenticated = await localAuth.authenticate(
        localizedReason: 'Scan your fingerprint to login',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Biometric login failed';
      });
      return;
    }

    if (authenticated == true) {
      // Biometric login only works if the user already signed in with
      // Firebase before on this device (Firebase keeps the session alive).
      if (firebaseService.isLoggedIn()) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        setState(() {
          errorMessage = 'Please login with email and password first';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login to continue tracking your finances',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (errorMessage != '')
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : loginUser,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OR', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: loginWithBiometrics,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E88E5).withOpacity(0.1),
                          border: Border.all(color: const Color(0xFF1E88E5), width: 1.5),
                        ),
                        child: const Icon(
                          Icons.fingerprint,
                          size: 34,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Login with Fingerprint',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupScreen()),
                    );
                  },
                  child: const Text("Don't have an account? Sign up"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
