import 'dart:convert';

import 'package:elh/locator.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/services/AuthenticationService.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/UserInfosReactiveService.dart';
import 'package:elh/ui/views/modules/user/loginModel.dart';
import 'package:flutter/material.dart';
import 'package:elh/services/BiometricHelper.dart';
import 'package:elh/services/PinService.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? _preferredMethod; // 'biometric' or 'pin'
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final UserInfoReactiveService _userInfoReactiveService =
      locator<UserInfoReactiveService>();
  @override
  void initState() {
    super.initState();
    fetchDataUser();
    _initStateAsync();
  }

  Future<void> _initStateAsync() async {
    final hasPin = await PinService.hasPin();
    final method = await PinService.getUnlockMethod();
    final biometricEnabled = await PinService.isBiometricEnabled();

    final preferred = biometricEnabled ? 'biometric' : method;

    setState(() {
      _creatingPin = !hasPin && !biometricEnabled;
      _preferredMethod = preferred;
      _message = (hasPin || biometricEnabled)
          ? 'Entrez votre PIN'
          : 'Créez votre PIN à 4 chiffres';
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_preferredMethod == 'biometric') {
        final hasDeviceBio = await BiometricHelper.hasEnrolledBiometrics();
        if (hasDeviceBio) {
          await _maybeAutoAuthenticate();
        } else {
          await PinService.saveBiometricEnabled(false);
          await PinService.saveUnlockMethod('pin');
          setState(() {
            _preferredMethod = 'pin';
            _creatingPin = !hasPin;
          });
        }
      }
    });
  }

  Future<void> _maybeAutoAuthenticate() async {
    final success = await BiometricHelper.authenticateWithFallback(context);
    if (success) {
      await PinService.saveBiometricEnabled(true);
      await PinService.saveUnlockMethod('biometric');
      widget.onUnlocked();
    } else {
      setState(() =>
          _message = 'Authentification biométrique échouée. Entrez le PIN.');
    }
  }

  Future<void> _handleUnlock() async {
    final input = _controller.text.trim();
    if (input.length != 4) return;

    if (_creatingPin) {
      await PinService.savePin(input);
      setState(() {
        _creatingPin = false;
        _message = 'PIN créé ! Veuillez vous authentifier';
        _controller.clear();
      });
      return;
    }

    final correct = await PinService.verifyPin(input);
    if (correct) {
      widget.onUnlocked();
    } else {
      setState(() => _message = 'PIN incorrect. Réessayez.');
      _controller.clear();
    }
  }

  Future<void> _useBiometric() async {
    try {
      final canCheck = await BiometricHelper.hasEnrolledBiometrics();
      debugPrint('canCheck biometrics = $canCheck');

      if (!mounted) return;

      if (!canCheck) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Aucune biométrie configurée sur l\'appareil')),
        );
        return;
      }

      final success = await BiometricHelper.authenticateWithFallback(context);
      debugPrint('biometric authenticate result = $success');

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biométrie OK')),
        );
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

  Future<void> fetchDataUser() async {
    try {
      UserInfos? infos =
          await _userInfoReactiveService.getUserInfos(cache: true);
      String userName = infos?.fullname ?? "Utilisateur";

      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (infos?.email != null) {
        await prefs.setString('user_email_check', infos!.email!);
      }
      if (infos?.status != null) {
        await prefs.setString('user_status_check', infos!.status!);
      }

      print(
          "User info saved: $userName, email: ${infos?.email}, status: ${infos?.status}");
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  Future<ApiResponse> login(String username, String password) async {
    ApiResponse apiResponse =
        await _authenticationService.login(username.trim(), password);
    print("Login API Response: ${apiResponse.status} - ${apiResponse.data}");

    if (apiResponse.status == 200) {
      await _userInfoReactiveService.getUserInfos(cache: false);
      print(apiResponse.data);

      // Decode JSON string
      final data = json.decode(apiResponse.data);
      String token = data['token'];
      print(token);
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
        _creatingPin = false;
        _message = 'Entrez votre PIN';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les PIN ne correspondent pas')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showMethodChooser() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Choisir méthode de déblocage'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'biometric'),
              child: const Text('Empreinte / Face ID'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'pin'),
              child: const Text('PIN'),
            ),
          ],
        );
      },
    );

    if (choice != null) {
      if (choice == 'biometric') {
        final hasDeviceBio = await BiometricHelper.hasEnrolledBiometrics();
        if (!hasDeviceBio) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Aucune empreinte / Face ID disponible sur cet appareil')));
          return;
        }
        await PinService.saveUnlockMethod('biometric');
        await PinService.saveBiometricEnabled(true);
        setState(() => _preferredMethod = 'biometric');
        await _useBiometric();
      } else {
        await PinService.saveUnlockMethod('pin');
        await PinService.saveBiometricEnabled(false);
        setState(() => _preferredMethod = 'pin');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final showBiometricFirst = _preferredMethod == 'biometric';
    final showPinFirst = _preferredMethod == 'pin' || _preferredMethod == null;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF5F2EB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Muslim Connect',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A5A3E)),
                      ),
                      const SizedBox(height: 20),
                      Icon(Icons.fingerprint,
                          size: 100, color: Color(0xFF7A9A7A)),
                      const SizedBox(height: 20),
                      Text(
                        _message ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18, color: Color(0xFF4A5A3E)),
                      ),
                      const SizedBox(height: 20),
                      if (showPinFirst) ...[
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
                                borderSide: BorderSide.none),
                            counterText: '',
                          ),
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _handleUnlock,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7A9A7A),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: Text(
                              _creatingPin ? 'Sauvegarder le PIN' : 'Débloquer',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white)),
                        ),
                        TextButton(
                            onPressed: _forgotPinFlow,
                            child: const Text("Mot de passe oublié ?")),
                        const SizedBox(height: 10),
                        TextButton(
                            onPressed: _showMethodChooser,
                            child:
                                const Text('Changer la méthode de déblocage')),
                        if (_preferredMethod == 'biometric')
                          const SizedBox(height: 10),
                        if (_preferredMethod == 'biometric')
                          TextButton(
                              onPressed: _useBiometric,
                              child: const Text(
                                  "Utiliser l'empreinte digitale / Face ID")),
                      ] else ...[
                        ElevatedButton(
                          onPressed: _useBiometric,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7A9A7A),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: const Text('Utiliser empreinte / Face ID',
                              style: TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                            onPressed: _showMethodChooser,
                            child:
                                const Text('Changer la méthode de déblocage')),
                        const SizedBox(height: 12),
                        TextButton(
                            onPressed: () =>
                                setState(() => _preferredMethod = 'pin'),
                            child: const Text('Saisir le PIN à la place')),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
