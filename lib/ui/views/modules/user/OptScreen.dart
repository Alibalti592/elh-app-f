import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:stacked_services/stacked_services.dart';
import 'package:elh/services/UserInfosReactiveService.dart';

class OtpScreen extends StatefulWidget {
  @override
  OtpScreenState createState() => OtpScreenState();
}

class OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  String? userEmail;
  String? codeSent;
  bool isLoading = false;
  NavigationService _navigationService = locator<NavigationService>();
  final UserInfoReactiveService _userInfoReactiveService =
      locator<UserInfoReactiveService>();

  @override
  void initState() {
    super.initState();
    _loadEmailAndSendOtp();
  }

  Future<void> _loadEmailAndSendOtp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('user_email_check');
    setState(() {
      userEmail = email;
    });

    if (email != null && email.isNotEmpty) {
      await _sendOtp(email);
    }
  }

  Future<void> _sendOtp(String email) async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse('https://muslim-connect.fr/send-otp');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        codeSent = data['otp'].toString();
      });
      print("OTP sent: $codeSent");
    } else {
      print("Failed to send OTP");
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _verifyOtp() async {
    String otpEntered = _controllers.map((c) => c.text).join();
    if (otpEntered.length < 6 || userEmail == null) return;

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('https://muslim-connect.fr/verify-otp');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": userEmail,
        "codeRecived": otpEntered,
        "codeSent": codeSent,
      }),
    );
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_email_check');
        if (data['status'] != null) {
          await prefs.setString('user_status_check', data['status']);
          await prefs.setBool('otp_status_override', true);
        }
        await _userInfoReactiveService.resetUserInfos();
        _navigationService.navigateTo('/');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  data['message'] ?? 'Échec de la vérification du code OTP')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Code de vérification invalide')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  bool get isOtpComplete => _controllers.every((c) => c.text.isNotEmpty);

  @override
  void dispose() {
    _controllers.forEach((c) => c.dispose());
    _focusNodes.forEach((f) => f.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color.fromRGBO(220, 198, 169, 1);

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: primaryColor,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top, // status bar padding
              bottom: 20,
              left: 10,
              right: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    _navigationService.navigateTo('login');
                  },
                ),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      "assets/images/logo-no-bg.png",
                      height: 80,
                    ),
                  ),
                ),
                SizedBox(width: 48), // space to balance IconButton
              ],
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Vérification de votre adresse e-mail",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  userEmail != null && userEmail!.isNotEmpty
                      ? "Nous vous avons envoyé un code de vérification à votre adresse e-mail $userEmail. "
                          "Veuillez saisir ce code ci-dessous pour confirmer votre identité."
                      : "Nous vous avons envoyé un code de vérification à votre adresse e-mail. "
                          "Veuillez saisir ce code ci-dessous pour confirmer votre identité.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          setState(() {});
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isOtpComplete && !isLoading ? _verifyOtp : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Vérifier le code",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: GestureDetector(
                    onTap: isLoading || userEmail == null
                        ? null
                        : () => _sendOtp(userEmail!),
                    child: Text(
                      "Je n'ai pas reçu de code ? Renvoyer le code",
                      style: TextStyle(
                        color: primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
