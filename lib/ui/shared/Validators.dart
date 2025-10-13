class ValidatorHelpers {
  static String? validateEmail(String? value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value!))
      return 'Saisir un e-mail valide !';
    else
      return null;
  }

  static String? validatePhone(String? value) {
    if (value!.length < 6)
      return 'Le téléphone doit contenir plus de 6 chiffres ';
    else
      return null;
  }

  static String? validateName(String? value) {
    if (value!.length < 2)
      return 'Le champs doit contenir au moins  2 caractères ';
    else
      return null;
  }

  static String? validatePassword(String? value) {
    String pattern = r'.{8,}$';
    RegExp regExp = new RegExp(pattern);
    if (!regExp.hasMatch(value!))
      return 'Votre mot de passe doit contenir : \n '
          '8 caractères \n ';
    else
      return null;
  }
}
