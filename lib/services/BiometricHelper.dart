import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'PinService.dart';

class BiometricHelper {
  static final _auth = LocalAuthentication();

  static Future<bool> hasEnrolledBiometrics() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      final biometrics = await _auth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (e) {
      debugPrint('hasEnrolledBiometrics error: $e');
      return false;
    }
  }

  static Future<bool> authenticateWithFallback(BuildContext context) async {
    try {
      final isAvailable = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      final biometrics = await _auth.getAvailableBiometrics();

      debugPrint('canCheckBiometrics = $isAvailable');
      debugPrint('isDeviceSupported = $isSupported');
      debugPrint('availableBiometrics = $biometrics');

      if (isAvailable && isSupported) {
        final success = await _auth.authenticate(
          localizedReason: 'Veuillez vous authentifier pour continuer',
          biometricOnly: false,
        );
        debugPrint('authenticate() success = $success');
        if (success) return true;
      }

      // Fallback: PIN
      final pin = await _showPinDialog(context);
      if (pin == null || pin.isEmpty) return false;
      return await PinService.verifyPin(pin);
    } catch (e) {
      debugPrint('authenticateWithFallback error: $e');
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
          title: const Text('Entrez votre PIN'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: '4 chiffres',
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
