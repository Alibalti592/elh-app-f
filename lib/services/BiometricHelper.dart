import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricHelper {
  static final _auth = LocalAuthentication();

  static Future<bool> authenticateWithFallback(BuildContext context) async {
    try {
      final isAvailable = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();

      if (isAvailable && isSupported) {
        final success = await _auth.authenticate(
          localizedReason: 'Please authenticate to continue',
          biometricOnly: true,
        );
        if (success) return true;
      }

      // 🔒 Fallback: show PIN screen if biometrics fail
      final pin = await _showPinDialog(context);
      return pin ==
          '1234'; // Replace with secure logic from your DB or secure storage
    } catch (e) {
      return false;
    }
  }

  static Future<String?> _showPinDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter PIN'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: '4-digit PIN',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
