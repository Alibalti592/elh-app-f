import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/locator.dart';
import 'package:elh/models/user.dart';
import 'package:provider/provider.dart';
import 'package:elh/services/AuthenticationService.dart';
import 'package:elh/ui/bbRouter.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // 🔔 Declare messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permissions (especially for iOS)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

  setupLocator();
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  bool hasNetworkIDO = await _authenticationService.hasNetwork();
  var initialRoute = 'login';
  if (hasNetworkIDO) {
    var isloggedIn = await _authenticationService.isloggedIn();
    if (isloggedIn) {
      initialRoute = '/';
      //inApp link : sera initilisé à la redirection vers home !
    }
  } else {
    initialRoute = 'no-connexion';
  }
//  Locale set bellow : localizationsDelegates (conflit entre les 2)
//  initializeDateFormatting('fr_FR').then((_) => runApp(ElhApp(initialRoute: initialRoute)));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(ElhApp(initialRoute: initialRoute)));
}

class ElhApp extends StatelessWidget {
  final String initialRoute;
  ElhApp({required this.initialRoute});
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>(
      initialData: User.initial(),
      create: (BuildContext context) =>
          locator<AuthenticationService>().userController.stream,
      child: MaterialApp(
        title: 'Muslim Connect',
        theme: appTheme,
        debugShowCheckedModeBanner: false,
        navigatorKey: locator<NavigationService>().navigatorKey,
        initialRoute: initialRoute,
        onGenerateRoute: BBRouter.generateRoute,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('fr', ''),
          const Locale('en', ''),
        ],
      ),
    );
  }
}
