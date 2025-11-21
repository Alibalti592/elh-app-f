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
  // main controllers
  final _pinController = TextEditingController();
  // NEW: confirm controller for create-pin
  final _confirmPinController = TextEditingController();

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

  // NEW: dispose controllers
  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
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
        _message = 'Saisis ton code à 4 chiffres';
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

  Future<void> _persistUserStatus(
      SharedPreferences prefs, String? newStatus) async {
    if (newStatus == null) return;
    final bool override = prefs.getBool('otp_status_override') ?? false;
    if (override && newStatus != 'active') {
      return;
    }
    await prefs.setString('user_status_check', newStatus);
    if (newStatus == 'active' && override) {
      await prefs.remove('otp_status_override');
    }
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
        await _persistUserStatus(prefs, infos!.status!);
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
          content: Text("Impossible de récupérer l'email de l'utilisateur."),
        ),
      );
      return;
    }

    final pwdController = TextEditingController();
    bool obscurePwd =
        true; // <-- pour gérer l'état de visibilité du mot de passe

    final pwd = await showDialog<String?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Code à 4 chiffres oublié?'),
              content: TextField(
                controller: pwdController,
                obscureText: obscurePwd,
                decoration: InputDecoration(
                  hintText: 'Mot de passe du compte',
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePwd ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePwd = !obscurePwd;
                      });
                    },
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context, pwdController.text.trim()),
                  child: const Text('Valider'),
                ),
              ],
            );
          },
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
          title: const Text('Entrez un nouveau code à 4 chiffres'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPin1Controller,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Nouveau code à 4 chiffres',
                ),
              ),
              TextField(
                controller: newPin2Controller,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Enregistrer'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
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
        _message = 'Saisis ton code à 4 chiffres';
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

  // UPDATED: create pin now requires confirmation
  Future<void> _handleCreatePin() async {
    final pin = _pinController.text.trim();

    if (pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le code doit contenir 4 chiffres')),
      );
      return;
    }

    await PinService.savePin(pin);
    await PinService.saveUnlockMethod('pin');
    await PinService.saveBiometricEnabled(false);

    setState(() {
      _pinController.clear();
      _stage = LockStage.enterPin;
      _message = 'Saisis ton code à 4 chiffres';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code enregistré avec succès')),
    );
  }

  Future<void> _handleEnterPin() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4) return;

    final ok = await PinService.verifyPin(pin);
    if (ok) {
      widget.onUnlocked();
    } else {
      setState(() {
        _message = 'Code à 4 chiffres incorrect. Réessayez.';
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

  // small helper to build a PIN field for any controller
  Widget _pinFieldFor(
    TextEditingController controller, {
    String hintText = '****',
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 4,
      obscureText: true,
      obscuringCharacter: '*', // shows ****
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          letterSpacing: 8,
          fontSize: 20,
        ),
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
      style: const TextStyle(
        fontSize: 20,
        letterSpacing: 8,
      ),
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
        // UPDATED: check if PIN already exists — if yes show enterPin, else show createPin
        _whiteButton('Code à 4 chiffres', () async {
          final hasPin = await PinService.hasPin();
          if (!mounted) return;
          if (hasPin) {
            setState(() {
              _stage = LockStage.enterPin;
              _message = 'Saisis ton code à 4 chiffres';
            });
          } else {
            setState(() {
              _stage = LockStage.createPin;
            });
          }
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
        // only one field
        _pinFieldFor(
          _pinController,
          hintText: '****',
        ),
        const SizedBox(height: 16),
        _greenButton('Enregistrer', _handleCreatePin),
        const SizedBox(height: 24),
        _whiteButton('Saisis FaceID/ Empreinte', () async {
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
          'Saisis ton code à 4 chiffres',
          style: TextStyle(color: darkGreen, fontSize: 14),
        ),
        const SizedBox(height: 8),
        _pinFieldFor(_pinController),
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
        _whiteButton('Saisis FaceID/ Empreinte', _useBiometric),
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
            text: 'Saisis ton FaceID / ',
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
        _whiteButton('Saisis le code à 4 chiffres', () async {
          final hasPin = await PinService.hasPin();
          if (!mounted) return;
          if (hasPin) {
            setState(() => _stage = LockStage.enterPin);
            _message = 'Saisis ton code à 4 chiffres';
          } else {
            // no PIN yet -> show create PIN
            setState(() => _stage = LockStage.createPin);
            _message = null;
          }
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
