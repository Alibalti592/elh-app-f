import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  static const _storage = FlutterSecureStorage();
  static const _pinKey = 'user_pin';

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
}
