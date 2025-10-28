import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/ui/views/modules/user/loginModel.dart';

class WelcomeDesign extends StatelessWidget {
  final LoginModel model;
  final VoidCallback onSignUpPressed;
  final VoidCallback onLoginPressed;

  const WelcomeDesign({
    Key? key,
    required this.model,
    required this.onSignUpPressed,
    required this.onLoginPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: _backgroundImageSimple(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              // Logo
              Image.asset(
                "assets/images/logo-no-bg.png",
                height: 173,
              ),
              // Design de bienvenue
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Salutation
                    Text(
                      "Assalem alaykoum , Bienvenue sur",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'inter',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: fontDark,
                      ),
                    ),
                    // Sous-titre

                    const SizedBox(height: 4),

                    // Titre principal
                    Text(
                      "Muslim Connect                            ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: const Color.fromRGBO(143, 151, 121, 1)),
                    ),
                    const SizedBox(height: 20),

                    const SizedBox(height: 15),

                    // Description
                    Text(
                      "Muslim Connect, la seule application pensée pour chaque musulman : elle "
                      "t'aide à suivre tes dettes et emprunts, à gérer ton testament et organiser "
                      "tes actions de Sadaqa Jariya — simplement, en toute sérénité, selon les "
                      "principes de l'Islam.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'inter',
                          fontSize: 20,
                          color: Color.fromRGBO(75, 85, 99, 1),
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 30),

                    // Bouton d'inscription
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onSignUpPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(143, 151, 121, 1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "S'inscrire",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onLoginPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(
                              color: Color.fromRGBO(143, 151, 121, 1)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Se connecter",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(143, 151, 121, 1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _backgroundImageSimple() {
    return BoxDecoration(
      color: Color.fromRGBO(240, 233, 223, 1),
      image: DecorationImage(
        image: AssetImage('assets/images/bg-light-pattern.png'),
        fit: BoxFit.cover,
        opacity: 0.05,
      ),
    );
  }
}
