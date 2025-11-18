import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  static const _storage = FlutterSecureStorage();
  static const _pinKey = 'user_pin';
  static const _unlockMethodKey = 'unlock_method'; // 'biometric' or 'pin'
  static const _biometricEnabledKey = 'biometric_enabled';

  /// Save a new PIN
  static Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  /// Retrieve the saved PIN
  static Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  /// Check if user has a PIN set
  static Future<bool> hasPin() async {
    final pin = await getPin();
    return pin != null && pin.isNotEmpty;
  }

  /// Verify entered PIN
  static Future<bool> verifyPin(String enteredPin) async {
    final savedPin = await getPin();
    return savedPin == enteredPin;
  }

  /// Reset / delete PIN
  static Future<void> clearPin() async {
    await _storage.delete(key: _pinKey);
  }

  /// Save preferred unlock method ('biometric' or 'pin')
  static Future<void> saveUnlockMethod(String method) async {
    await _storage.write(key: _unlockMethodKey, value: method);
  }

  static Future<String?> getUnlockMethod() async {
    return await _storage.read(key: _unlockMethodKey);
  }

  static Future<void> clearUnlockMethod() async {
    await _storage.delete(key: _unlockMethodKey);
  }

  /// Save whether biometric unlocking was enabled by the user
  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled ? '1' : '0');
  }

  static Future<bool> isBiometricEnabled() async {
    final v = await _storage.read(key: _biometricEnabledKey);
    return v == '1';
  }

  static Future<void> clearBiometricEnabled() async {
    await _storage.delete(key: _biometricEnabledKey);
  }
}
