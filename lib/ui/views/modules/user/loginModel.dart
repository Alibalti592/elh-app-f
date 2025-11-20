import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:elh/models/userInfos.dart';
import 'package:elh/ui/views/modules/user/ResetPasswordView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:elh/locator.dart';
import 'package:elh/models/userRegistration.dart';
import 'package:elh/repository/UserRepository.dart';
import 'package:elh/services/AuthenticationService.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/services/UserInfosReactiveService.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginModel extends FutureViewModel<dynamic> {
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final UserRepository userRepository = locator<UserRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  NavigationService _navigationService = locator<NavigationService>();
  String? errorMessage;
  EdgeInsets marginLogo = EdgeInsets.only(top: 150.0, bottom: 50.0);
  late UserRegistration userRegistration;
  final UserInfoReactiveService _userInfoReactiveService =
      locator<UserInfoReactiveService>();
  final DialogService _dialogService = locator<DialogService>();

  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  get registerFormKey => _registerFormKey;
  bool autoValidate = false;
  bool obscureText = true;

  bool acceptCondition = false;
  bool acceptNewsletter = false;
  String version = "";

  bool showTextBeforeRegister = false;
  String introtext = '';
  ValueNotifier<bool> isLogging = ValueNotifier<bool>(false);

  TextEditingController phoneController = TextEditingController();
  PhoneNumber phoneNumber = PhoneNumber(isoCode: 'FR');

  ValueNotifier<bool> isRegistering = ValueNotifier<bool>(false);
  PageController? pageController;

  ValueNotifier<String?> emailError = ValueNotifier(null);
  ValueNotifier<String?> passwordError = ValueNotifier(null);
  ValueNotifier<String?> globalError = ValueNotifier(null);

  LoginModel() {
    phoneNumber = PhoneNumber(isoCode: 'FR');
    autoValidate = false;
    obscureText = true;
    userRegistration = new UserRegistration();
    this.isRegistering.value = false;
    this.isLogging.value = false;
  }

  @override
  Future<dynamic> futureToRun() => iniLoginPage();

  Future iniLoginPage() async {
    print("Initializing Login Page");
    setAppVersion();
    bool isOnline = await this.hasNetwork();
    print("Network status: $isOnline");
    if (!isOnline) {
      _errorMessageService.noConnexion();
    }
    // else {
    //   ApiResponse apiResponse = await userRepository.getIntroText();
    //   print(
    //       "Intro Text API Response: ${apiResponse.status} - ${apiResponse.data}");
    //   if (apiResponse.status == 200) {
    //     var data = json.decode(apiResponse.data);
    //     this.introtext = data['text'];
    //     this.showTextBeforeRegister = true;
    //     notifyListeners();
    //   }
    // }
  }

  resetShowIntro() {
    this.showTextBeforeRegister = true;
    notifyListeners();
  }

  showregisterForm() {
    this.showTextBeforeRegister = false;
    notifyListeners();
  }

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('www.google.fr');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Future<ApiResponse> login(String username, String password) async {
  //   if (username.length == 0 || password.length == 0) {
  //     _errorMessageService.errorShoMessage('Saisir vos identifiants !');
  //     return new ApiResponse(404, []);
  //   }
  //   this.isLogging.value = true;
  //   //clear prefs !
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.clear();
  //   FlutterSecureStorage storage = const FlutterSecureStorage();
  //   await storage.deleteAll();
  //   ApiResponse apiResponse =
  //       await _authenticationService.login(username.trim(), password);
  //   if (apiResponse.status == 200) {
  //     //set user infos (cache for drawer) !!
  //     await _userInfoReactiveService.getUserInfos(cache: false);
  //     notifyListeners();
  //     Timer(Duration(milliseconds: 500), () {
  //       _navigationService.clearStackAndShow('/');
  //       this.isLogging.value = false;
  //     });
  //   } else {
  //     this.isLogging.value = false;
  //     _errorMessageService.dialogIsOpened = false;
  //     if (apiResponse.status == 401) {
  //       _errorMessageService.errorShoMessage(
  //           title: 'Connexion  impossible',
  //           "Avez-vous déjà créé votre compte ? Si oui le mot de passe ou l'identifiant est incorrect ! Sinon merci de créer un compte");
  //     } else {
  //       //alert message
  //       _errorMessageService.errorShoMessage(apiResponse.data);
  //     }
  //   }
  //   return apiResponse;
  // }

  void toggleObscureText() {
    obscureText = !obscureText;
    notifyListeners();
  }

  // validate only when login button pressed
  bool validateCredentials(String username, String password) {
    bool isValid = true;

    if (username.isEmpty) {
      emailError.value = "Veuillez saisir votre e-mail";
      isValid = false;
    } else if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
        .hasMatch(username)) {
      emailError.value = "Email invalide";
      isValid = false;
    } else {
      emailError.value = null;
    }

    if (password.isEmpty) {
      passwordError.value = "Veuillez saisir votre mot de passe";
      isValid = false;
    } else {
      passwordError.value = null;
    }

    return isValid;
  }

  Future<ApiResponse> login(String username, String password) async {
    // validation happens only now
    if (!validateCredentials(username, password)) {
      return ApiResponse(404, []);
    }

    isLogging.value = true;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    FlutterSecureStorage storage = const FlutterSecureStorage();
    await storage.deleteAll();

    ApiResponse apiResponse =
        await _authenticationService.login(username.trim(), password);
    print("Login API Response: ${apiResponse.status} - ${apiResponse.data}");

    isLogging.value = false;

    if (apiResponse.status == 200) {
      await _userInfoReactiveService.getUserInfos(cache: false);
      print(apiResponse.data);

      notifyListeners();

      // Decode JSON string
      final data = json.decode(apiResponse.data);
      String token = data['token'];
      print(token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      await fetchDataUser();
      navigateBasedOnStatus();
    } else {
      if (apiResponse.status == 401) {
        globalError.value = "Identifiant ou mot de passe incorrect";
      } else {
        emailError.value = apiResponse.data.toString();
      }
    }

    return apiResponse;
  }

  void goToResetPassword() {
    _navigationService.navigateTo('/reset-password');
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

  Future<void> navigateBasedOnStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? status = prefs.getString('user_status_check') ?? "unactive";

    Timer(Duration(seconds: 1), () {
      if (status == "unactive") {
        _navigationService.navigateTo('otp-screen');
      } else {
        _navigationService.navigateTo('/');
      }

      this.isRegistering.value = false;
    });
  }

  register(PageController? pageController) async {
    this.pageController = pageController;
    if (!this.acceptCondition) {
      _errorMessageService
          .errorShoMessage("Vous devez accepter les conditions générales");
      return;
    }

    if (!this.isRegistering.value) {
      this.isRegistering.value = true;
      bool navigated = false;

      try {
        // form valid?
        if (registerFormKey.currentState.validate()) {
          userRegistration.acceptNewsletter = this.acceptNewsletter;

          ApiResponse apiResponse =
              await userRepository.registerUser(userRegistration);

          if (apiResponse.status == 409) {
            DialogResponse? response =
                await this._dialogService.showConfirmationDialog(
                      title: 'Ce compte existe déjà',
                      cancelTitle: "Modifier l'email",
                      confirmationTitle: 'Se connecter',
                    );

            this.isRegistering.value = false;

            if (response?.confirmed == true && this.pageController != null) {
              this.pageController!.animateToPage(
                    0,
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                  );
            }
          } else if (apiResponse.status == 200) {
            await _authenticationService.login(
              userRegistration.email!,
              userRegistration.password!,
            );
            await fetchDataUser();
            navigateBasedOnStatus();
            navigated = true;
          } else {
            _errorMessageService.errorShoMessage(apiResponse.data);
          }
        } else {
          autoValidate = true;
          _errorMessageService.errorShoMessage("Vérfiez les données saisies");
        }
      } catch (e) {
        _errorMessageService.errorShoMessage(e.toString());
      } finally {
        if (!navigated) this.isRegistering.value = false;
      }
    }
  }

  acceptConditionChange(value) {
    this.acceptCondition = value;
    notifyListeners();
  }

  acceptNewsletterChange(value) {
    this.acceptNewsletter = value;
    notifyListeners();
  }

  userRegistrationController(type, value) {
    userRegistration.setUserRegistrationVlue(type, value);
    notifyListeners();
  }

  setAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    this.version = packageInfo.version;
    notifyListeners();
  }

  FutureOr<bool> openUrl(url) async {
    Uri _url = Uri.parse(url);
    return launchUrl(_url);
  }

  gotToResetPassword() {
    _navigationService.navigateToView(ResetPasswordView());
  }

  setPhoneNumber(PhoneNumber phoneNumber) {
    this.userRegistration.phone = phoneNumber.parseNumber();
    this.userRegistration.phonePrefix = phoneNumber.dialCode!;
    this.phoneNumber = phoneNumber;
    notifyListeners();
  }
}
