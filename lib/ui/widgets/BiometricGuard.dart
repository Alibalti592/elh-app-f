import 'package:flutter/material.dart';
import 'LockScreen.dart';

class BiometricGuard extends StatefulWidget {
  final Widget child;
  const BiometricGuard({super.key, required this.child});

  @override
  State<BiometricGuard> createState() => _BiometricGuardState();
}

class _BiometricGuardState extends State<BiometricGuard>
    with WidgetsBindingObserver {
  DateTime? _backgroundTime;
  bool _locked = true; // 🔒 Always start locked

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 🔒 Ensure lock when app first starts (cold start)
    Future.delayed(Duration.zero, () {
      setState(() => _locked = true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      // store the time when app went to background
      _backgroundTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      // Only re-lock if the app was in background for the threshold
      if (_backgroundTime != null) {
        final diff = DateTime.now().difference(_backgroundTime!);
        const thresholdMinutes = 3;
        if (diff.inMinutes >= thresholdMinutes) {
          setState(() => _locked = true);
        }
      }
      // else: do NOT re-lock: this avoids re-locks caused by biometric dialogs
    }
  }

  void _unlock() {
    // when unlocking manually, reset background time to avoid re-lock race
    _backgroundTime = null;
    setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_locked) {
      return LockScreen(onUnlocked: _unlock);
    }
    return widget.child;
  }
}
