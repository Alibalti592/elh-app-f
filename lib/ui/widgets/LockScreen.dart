import 'dart:convert';
import 'package:elh/models/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elh/locator.dart';
import 'package:elh/services/AuthenticationService.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/UserInfosReactiveService.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/services/BiometricHelper.dart';
import 'package:elh/services/PinService.dart';

enum LockStage {
  firstChoice, // Screen 1
  createPin, // Screen 2
  enterPin, // Screen 3
  biometricOnly, // Screen 4
}

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _pinController = TextEditingController();
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final UserInfoReactiveService _userInfoReactiveService =
      locator<UserInfoReactiveService>();

  static const Color bg = Color(0xFFF5F2EB);
  static const Color green = Color(0xFF9AAE86);
  static const Color darkGreen = Color(0xFF717E5A);

  LockStage _stage = LockStage.firstChoice;
  String? _message;

  @override
  void initState() {
    super.initState();
    fetchDataUser();
    _initStage();
  }

  Future<void> _enterBiometricOnlyStage() async {
    setState(() => _stage = LockStage.biometricOnly);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final hasBio = await BiometricHelper.hasEnrolledBiometrics();
      if (!mounted) return;

      if (!hasBio) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Aucune empreinte / Face ID disponible sur cet appareil')));
        final hasPin = await PinService.hasPin();
        if (!hasPin) {
          setState(() => _stage = LockStage.firstChoice);
        } else {
          setState(() => _stage = LockStage.enterPin);
        }
        return;
      }

      await _useBiometric();
    });
  }

  Future<void> _initStage() async {
    final hasPin = await PinService.hasPin();
    final method = await PinService.getUnlockMethod(); // 'pin' or 'biometric'
    final biometricEnabled = await PinService.isBiometricEnabled();

    if (!hasPin && !biometricEnabled) {
      setState(() {
        _stage = LockStage.firstChoice;
        _message = null;
      });
      return;
    }

    if (hasPin && method == 'pin') {
      setState(() {
        _stage = LockStage.enterPin;
        _message = 'Utilise ton code à 4 chiffres';
      });
      return;
    }

    if (biometricEnabled && method == 'biometric') {
      await _enterBiometricOnlyStage();
      return;
    }

    setState(() {
      _stage = LockStage.firstChoice;
    });
  }

  Future<void> fetchDataUser() async {
    try {
      UserInfos? infos =
          await _userInfoReactiveService.getUserInfos(cache: true);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (infos?.email != null) {
        await prefs.setString('user_email_check', infos!.email!);
      }
      if (infos?.status != null) {
        await prefs.setString('user_status_check', infos!.status!);
      }

      debugPrint(
          "User info saved: ${infos?.fullname}, email: ${infos?.email}, status: ${infos?.status}");
    } catch (e) {
      debugPrint("Error fetching user info: $e");
    }
  }

  Future<ApiResponse> login(String username, String password) async {
    ApiResponse apiResponse =
        await _authenticationService.login(username.trim(), password);
    if (apiResponse.status == 200) {
      await _userInfoReactiveService.getUserInfos(cache: false);
      final data = json.decode(apiResponse.data);
      final token = data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      await fetchDataUser();
    } else {
      debugPrint(
          'Login failed: status=${apiResponse.status}, data=${apiResponse.data}');
    }
    return apiResponse;
  }

  Future<void> _forgotPinFlow() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email_check');

    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Impossible de récupérer l'email de l'utilisateur.")),
      );
      return;
    }

    final pwdController = TextEditingController();
    final pwd = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pin oublié'),
          content: TextField(
            controller: pwdController,
            obscureText: true,
            decoration:
                const InputDecoration(hintText: 'Mot de passe du compte'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Annuler')),
            ElevatedButton(
                onPressed: () =>
                    Navigator.pop(context, pwdController.text.trim()),
                child: const Text('Valider')),
          ],
        );
      },
    );

    if (pwd == null || pwd.isEmpty) return;

    final verifyingSnack = ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vérification du mot de passe...')),
    );

    try {
      final apiResponse = await login(email, pwd);
      verifyingSnack.close();

      if (apiResponse.status != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe incorrect.')),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion: $e')),
      );
      return;
    }

    final newPin1Controller = TextEditingController();
    final newPin2Controller = TextEditingController();
    final newPinsMatch = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Entrez un nouveau PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPin1Controller,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Nouveau PIN'),
              ),
              TextField(
                controller: newPin2Controller,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Confirmer PIN'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                final a = newPin1Controller.text.trim();
                final b = newPin2Controller.text.trim();
                Navigator.pop(context, a.isNotEmpty && a == b && a.length == 4);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (newPinsMatch == true) {
      await PinService.savePin(newPin1Controller.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN mis à jour avec succès')),
      );
      setState(() {
        _stage = LockStage.enterPin;
        _message = 'Utilise ton code à 4 chiffres';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les PIN ne correspondent pas')),
      );
    }
  }

  Future<void> _useBiometric() async {
    try {
      final canCheck = await BiometricHelper.hasEnrolledBiometrics();
      if (!mounted) return;

      if (!canCheck) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Aucune biométrie configurée sur l\'appareil')),
        );
        return;
      }

      final success = await BiometricHelper.authenticateWithFallback(context);
      if (!mounted) return;

      if (success) {
        await PinService.saveUnlockMethod('biometric');
        await PinService.saveBiometricEnabled(true);
        widget.onUnlocked();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biométrie annulée ou échouée')),
        );
      }
    } catch (e) {
      debugPrint('useBiometric error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur biométrie: $e')),
      );
    }
  }

  Future<void> _handleCreatePin() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4) return;

    await PinService.savePin(pin);
    await PinService.saveUnlockMethod('pin');
    await PinService.saveBiometricEnabled(false);

    setState(() {
      _pinController.clear();
      _stage = LockStage.enterPin;
      _message = 'Utilise ton code à 4 chiffres';
    });
  }

  Future<void> _handleEnterPin() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4) return;

    final ok = await PinService.verifyPin(pin);
    if (ok) {
      widget.onUnlocked();
    } else {
      setState(() {
        _message = 'PIN incorrect. Réessayez.';
        _pinController.clear();
      });
    }
  }

  Widget _title({bool locked = false}) {
    if (!locked) {
      return const Text(
        'Muslim Connect',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: darkGreen,
        ),
      );
    }
    return const Column(
      children: [
        Text(
          'Muslim Connect',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: darkGreen,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'verrouillé',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: darkGreen,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }

  Widget _lockIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(
        Icons.lock_outline,
        size: 80,
        color: green,
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        child: const Text(
          '',
        ),
      ),
    );
  }

  Widget _greenButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _whiteButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide.none,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _pinField() {
    return TextField(
      controller: _pinController,
      keyboardType: TextInputType.number,
      maxLength: 4,
      obscureText: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        counterText: '',
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 20, letterSpacing: 8),
    );
  }

  Widget _buildFirstChoice() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _lockIcon(),
        const SizedBox(height: 24),
        const Text(
          'Sécurise ton compte avec',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        _whiteButton('FaceID / Empreinte', () async {
          final hasBio = await BiometricHelper.hasEnrolledBiometrics();
          if (!hasBio) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'Aucune empreinte / Face ID disponible sur cet appareil')));
            return;
          }
          await PinService.saveUnlockMethod('biometric');
          await PinService.saveBiometricEnabled(true);
          await _enterBiometricOnlyStage();
        }),
        const SizedBox(height: 8),
        const Text(
          'OU',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        _whiteButton('Code à 4 chiffres', () {
          setState(() {
            _stage = LockStage.createPin;
          });
        }),
      ],
    );
  }

  Widget _buildCreatePin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _lockIcon(),
        const SizedBox(height: 24),
        const Text(
          'Crée ton code à 4 chiffres',
          style: TextStyle(color: darkGreen, fontSize: 14),
        ),
        const SizedBox(height: 8),
        _pinField(),
        const SizedBox(height: 16),
        _greenButton('Enregistrer', _handleCreatePin),
        const SizedBox(height: 24),
        _whiteButton('Utilise FaceID/ Empreinte', () async {
          final hasBio = await BiometricHelper.hasEnrolledBiometrics();
          if (!hasBio) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'Aucune empreinte / Face ID disponible sur cet appareil')));
            return;
          }
          await PinService.saveUnlockMethod('biometric');
          await PinService.saveBiometricEnabled(true);
          await _enterBiometricOnlyStage();
        }),
      ],
    );
  }

  Widget _buildEnterPin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _lockIcon(),
        const SizedBox(height: 24),
        const Text(
          'Utilise ton code à 4 chiffres',
          style: TextStyle(color: darkGreen, fontSize: 14),
        ),
        const SizedBox(height: 8),
        _pinField(),
        const SizedBox(height: 16),
        _greenButton('Déverrouiller', _handleEnterPin),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _forgotPinFlow,
          child: const Text(
            'Code à 4 chiffres oublié?',
            style: TextStyle(
              color: darkGreen,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _whiteButton('Utilise FaceID/ Empreinte', _useBiometric),
      ],
    );
  }

  Widget _buildBiometricOnly() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _lockIcon(),
        const SizedBox(height: 24),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            text: 'Utilise ton FaceID / ',
            style: TextStyle(color: darkGreen, fontSize: 14),
            children: [
              TextSpan(
                text: 'Empreinte',
                style: TextStyle(fontWeight: FontWeight.w700),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
        _whiteButton('Utilise le code à 4 chiffres', () {
          setState(() => _stage = LockStage.enterPin);
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final locked =
        _stage == LockStage.enterPin || _stage == LockStage.biometricOnly;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _title(locked: locked),
                  const SizedBox(height: 32),
                  if (_stage == LockStage.firstChoice) _buildFirstChoice(),
                  if (_stage == LockStage.createPin) _buildCreatePin(),
                  if (_stage == LockStage.enterPin) _buildEnterPin(),
                  if (_stage == LockStage.biometricOnly) _buildBiometricOnly(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
