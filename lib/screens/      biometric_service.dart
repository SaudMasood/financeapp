import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  // Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      bool canCheck = await auth.canCheckBiometrics;
      bool isSupported = await auth.isDeviceSupported();

      return canCheck && isSupported;
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Authenticate user
  Future<bool> authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Please verify your identity',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return authenticated;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Cancel authentication
  Future<void> cancelAuthentication() async {
    await auth.stopAuthentication();
  }
}