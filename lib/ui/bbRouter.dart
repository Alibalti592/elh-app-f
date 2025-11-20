import 'package:elh/ui/views/modules/Carte/CarteListView.dart';
import 'package:elh/ui/views/modules/dece/DeceDetailsView.dart';
import 'package:elh/ui/views/modules/home/HomeView.dart';
import 'package:elh/ui/views/modules/user/CompleteRegister.dart';
import 'package:elh/ui/views/modules/user/OptScreen.dart';
import 'package:elh/ui/widgets/BiometricGuard.dart';
import 'package:flutter/material.dart';
import 'package:elh/ui/views/modules/chat/ChatView.dart';
import 'package:elh/ui/views/modules/user/ProfileView.dart';
import 'package:elh/ui/views/modules/user/NavigationParametersView.dart';
import 'package:elh/ui/views/modules/user/login.dart';
import 'package:elh/ui/views/modules/user/noConnexion.dart';
import 'package:elh/ui/widgets/SlideRightRoute.dart';

class BBRouter {
  static Route<dynamic> generateRoute(settings) {
    switch (settings.name) {
      case 'login':
        return MaterialPageRoute(builder: (_) => Login());
      case 'no-connexion':
        return MaterialPageRoute(builder: (_) => NoConnexion());
      case 'profileInfos':
        final arguments = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BiometricGuard(
            child: ProfileView(userInfos: arguments['userInfos']),
          ),
        );

      case 'navigationParameters':
        final arguments = settings.arguments as Map<String, dynamic>;
        return SlideRightRoute(
          page: BiometricGuard(
            child: NavigationParametersView(
              userInfos: arguments['userInfos'],
            ),
          ),
        );
      case 'chatThread':
        final arguments = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BiometricGuard(
            child: ChatView(thread: arguments['thread']),
          ),
        );

      case 'deceDetails':
        final arguments = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BiometricGuard(
            child: DeceDetailsView(arguments['dece']),
          ),
        );
      case 'completeRegister':
        return MaterialPageRoute(builder: (_) => CompleteRegister());

      case 'carteListView':
        final arguments = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BiometricGuard(
            child: CarteListView(openCarte: arguments['openCarte']),
          ),
        );
      case 'otp-screen':
        return MaterialPageRoute(builder: (_) => OtpScreen());
      //DASHBOARD
      case '/':
        return MaterialPageRoute(
          builder: (_) => BiometricGuard(child: HomeView()),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
