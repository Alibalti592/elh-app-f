import 'package:flutter/material.dart';
import 'package:elh/services/BiometricHelper.dart';
import 'package:elh/services/PinService.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _controller = TextEditingController();
  bool _creatingPin = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _checkIfHasPin();
  }

  Future<void> _checkIfHasPin() async {
    final hasPin = await PinService.hasPin();
    setState(() {
      _creatingPin = !hasPin; // if no PIN yet, switch to create mode
      _message = hasPin ? 'Enter your PIN' : 'Create your 4-digit PIN';
    });
  }

  Future<void> _handleUnlock() async {
    final input = _controller.text.trim();
    if (input.length != 4) return;

    if (_creatingPin) {
      await PinService.savePin(input);
      setState(() {
        _creatingPin = false;
        _message = 'PIN created! Please authenticate';
        _controller.clear();
      });
      return;
    }

    final correct = await PinService.verifyPin(input);
    if (correct) {
      widget.onUnlocked();
    } else {
      setState(() => _message = 'Incorrect PIN. Try again.');
      _controller.clear();
    }
  }

  Future<void> _useBiometric() async {
    final success = await BiometricHelper.authenticateWithFallback(context);
    if (success) widget.onUnlocked();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EB), // match intro screen background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              const Text(
                'Muslim Connect',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A5A3E), // match branding
                ),
              ),
              const SizedBox(height: 20),

              // Fingerprint icon
              Icon(Icons.fingerprint, size: 100, color: Color(0xFF7A9A7A)),
              const SizedBox(height: 20),

              // Message
              Text(
                _message ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF4A5A3E),
                ),
              ),
              const SizedBox(height: 20),

              // PIN input field
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: '••••',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  counterText: '',
                ),
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Unlock button
              ElevatedButton(
                onPressed: _handleUnlock,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A9A7A),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _creatingPin ? 'Save PIN' : 'Unlock',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),

              const SizedBox(height: 10),
              TextButton(
                onPressed: _useBiometric,
                child: const Text(
                  'Use Fingerprint / Face ID',
                  style: TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                    color: Color(0xFF4A5A3E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
