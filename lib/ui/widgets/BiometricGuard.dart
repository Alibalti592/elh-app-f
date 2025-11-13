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
      _backgroundTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundTime != null) {
        final diff = DateTime.now().difference(_backgroundTime!);
        if (diff.inMinutes >= 3) {
          setState(() => _locked = true);
        }
      } else {
        // Cold start after app closed
        setState(() => _locked = true);
      }
    }
  }

  void _unlock() {
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
