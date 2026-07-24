import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import '../main.dart';
import '../services/firebase_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  FirebaseService firebaseService = FirebaseService();
  final LocalAuthentication localAuth = LocalAuthentication();

  String userEmail = '';
  String userName = '';
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  bool biometricEnabled = false;
  String biometricStatusMessage = '';

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = firebaseService.getCurrentUser()?.email ?? 'user@example.com';
      userName = firebaseService.getCurrentUser()?.displayName ?? '';
      notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      darkModeEnabled = prefs.getBool('darkModeEnabled') ?? false;
      biometricEnabled = prefs.getBool('biometricEnabled') ?? false;
    });
  }

  Future<void> toggleNotifications(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    setState(() {
      notificationsEnabled = value;
    });
  }

  Future<void> toggleDarkMode(bool value) async {
    await MyApp.of(context)?.changeTheme(value);

    setState(() {
      darkModeEnabled = value;
    });
  }

  Future<void> toggleBiometric(bool value) async {
    setState(() {
      biometricStatusMessage = '';
    });

    if (value == false) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometricEnabled', false);
      setState(() {
        biometricEnabled = false;
      });
      return;
    }

    bool deviceSupported = false;
    try {
      deviceSupported = await localAuth.isDeviceSupported();
    } catch (e) {
      deviceSupported = false;
    }

    if (deviceSupported == false) {
      setState(() {
        biometricStatusMessage = 'This device does not support biometric login';
      });
      return;
    }

    List<BiometricType> availableTypes = [];
    try {
      availableTypes = await localAuth.getAvailableBiometrics();
    } catch (e) {
      availableTypes = [];
    }

    if (availableTypes.isEmpty) {
      setState(() {
        biometricStatusMessage = 'No fingerprint or face is set up on this device yet. '
            'Add one in your phone Settings first, then try again here';
      });
      return;
    }

    bool confirmed = false;
    try {
      confirmed = await localAuth.authenticate(
        localizedReason: 'Scan your fingerprint to enable biometric login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == 'NotEnrolled') {
        setState(() {
          biometricStatusMessage = 'No fingerprint enrolled on this device yet';
        });
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        setState(() {
          biometricStatusMessage = 'Too many attempts. Try again later';
        });
      } else {
        setState(() {
          biometricStatusMessage = e.message ?? 'Fingerprint setup failed';
        });
      }
      return;
    } catch (e) {
      setState(() {
        biometricStatusMessage = 'Something went wrong. Please try again';
      });
      return;
    }

    if (confirmed == false) {
      setState(() {
        biometricStatusMessage = 'Fingerprint was not confirmed. Try again';
      });
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometricEnabled', true);

    setState(() {
      biometricEnabled = true;
      biometricStatusMessage = 'Fingerprint login enabled';
    });
  }

  Future<void> logoutUser() async {
    await firebaseService.signOut();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 35,
                backgroundColor: const Color(0xFF1E88E5),
                child: const Icon(Icons.person, color: Colors.white, size: 35),
              ),
              const SizedBox(height: 10),
              if (userName != '')
                Text(userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(userEmail, style: TextStyle(fontSize: userName == '' ? 16 : 13, color: Colors.grey.shade600)),
              const SizedBox(height: 20),
              const Divider(),
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Get reminders about your budgets'),
                value: notificationsEnabled,
                onChanged: toggleNotifications,
              ),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Restart app to fully apply theme'),
                value: darkModeEnabled,
                onChanged: toggleDarkMode,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.fingerprint),
                title: const Text('Fingerprint Login'),
                subtitle: const Text('Use your fingerprint to log in next time'),
                value: biometricEnabled,
                onChanged: toggleBiometric,
              ),
              if (biometricStatusMessage != '')
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                  child: Text(
                    biometricStatusMessage,
                    style: TextStyle(
                      fontSize: 12,
                      color: biometricEnabled ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.cloud_outlined),
                title: const Text('Cloud Backup'),
                subtitle: const Text('Your data is backed up to Firebase when online'),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About This App'),
                subtitle: const Text('Personal Finance Tracker v1.0'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: logoutUser,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Logout', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}