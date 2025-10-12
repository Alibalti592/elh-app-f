import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:elh/models/carte.dart';
import 'package:elh/models/mosque.dart';
import 'package:elh/services/CacheDataService.dart';
import 'package:elh/ui/views/modules/Carte/CarteListView.dart';
import 'package:elh/ui/views/modules/Dette/DetteView.dart';
import 'package:elh/ui/views/modules/Mosque/DeceMosqueView.dart';
import 'package:elh/ui/views/modules/Pompe/DemandPompeView.dart';
import 'package:elh/ui/views/modules/Priere/PriereView.dart';
import 'package:elh/ui/views/modules/Relation/RelationView.dart';
import 'package:elh/ui/views/modules/Testament/ListSharedTestamentView.dart';
import 'package:elh/ui/views/modules/dece/DeceListView.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:elh/locator.dart';
import 'package:elh/models/ChatThread.dart';
import 'package:elh/repository/ChatRepository.dart';
import 'package:elh/repository/NotificationRepository.dart';
import 'package:elh/services/AuthenticationService.dart';
import 'package:elh/services/BBNavigationService.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ChatReactiveService.dart';
import 'package:elh/ui/views/modules/chat/ChatView.dart';
import 'package:elh/ui/views/modules/chat/ThreadsView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked_services/stacked_services.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final NotificationRepository _notificationRepository =
      locator<NotificationRepository>();
  CacheDataService _cacheDataService = locator<CacheDataService>();
  NavigationService _navigationService = locator<NavigationService>();
  BBNavigationService _bbNavigationService = locator<BBNavigationService>();
  ChatRepository _chatRepository = locator<ChatRepository>();
  final ChatReactiveService _chatReactiveService =
      locator<ChatReactiveService>();
  bool hasreceivedChatMessage = false; //for dot !
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  getUserToken() async {
    //do it better avec error ...  dialog ou redirect ..
    String token = await _authenticationService.getUserToken();
    return token;
  }

  Future initialise() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    try {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      var initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      var initializationSettingsIOS = DarwinInitializationSettings();
      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onDidReceiveNotificationResponse: onSelectNotification);
    } catch (e) {}
    _fcm.getToken().then((token) async {
      var fcmTokenStrV2 = token.toString();
      var userToken = await getUserToken();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool tokenValid =
          await _cacheDataService.dataInCacheAndValid('fcmTokenStrV2', 30);

      if (!tokenValid) {
        this.saveTokenAPI(fcmTokenStrV2, userToken, prefs);
      } else if (prefs.getString('fcmTokenStrV2') != fcmTokenStrV2) {
        _notificationRepository.deleteFCMToken(
            prefs.getString('fcmTokenStrV2'), userToken);
        this.saveTokenAPI(fcmTokenStrV2, userToken, prefs);
      }
    });

    // _fcm.getToken().then((token) async {
    //   var fcmTokenStr = token.toString();
    //   var userToken = await getUserToken();
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   bool tokenValid = await _cacheDataService.dataInCacheAndValid('fcmTokenStr', 30);
    //   //token not set, one month max if not used (update just in case) ...
    //   if(!tokenValid) {
    //     //save le token mais pas de doublon possible sur api
    //     this.saveTokenAPI(fcmTokenStr, userToken, prefs);
    //   } else if(prefs.getString('fcmTokenStr') != fcmTokenStr) {
    //     //delete old string
    //     _notificationRepository.deleteFCMToken(prefs.getString('fcmTokenStr'), userToken);
    //     this.saveTokenAPI(fcmTokenStr, userToken, prefs);
    //   }
    // });

    //Quand l'app s'ouvre depuis une notifiation => app passe en FG et on recupère le message
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        navigateFromMessage(message);
      }
    });

    //l'app est déjà ouvert en BG
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      if (message != null) {
        navigateFromMessage(message);
      }
    });

    //l'app est en FG
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      if (message != null) {
        if (Platform.isAndroid) {
          //to avoid double notifs IOS ??!!
          RemoteNotification? notification = message.notification;
          this.showLocalNotification(notification!, message);
        }
      }
    });
  }

  saveTokenAPI(fcmTokenStrV2, userToken, prefs) async {
    String deviceIdentifier = '';
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceIdentifier = androidInfo.id;
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceIdentifier = iosInfo.identifierForVendor!;
      }
    } catch (e) {}
    _notificationRepository.postFCMToken(
        fcmTokenStrV2, userToken, deviceIdentifier);
    prefs.setString('fcmTokenStrV2', fcmTokenStrV2);
  }

  // TOP-LEVEL or STATIC function to handle background messages
  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) {
//    navigateToChat(message);
    return Future<void>.value();
  }

  void navigateFromMessage(RemoteMessage message) async {
    this._bbNavigationService.setFromView('notification');
    if (message.data['view'] == 'chatview') {
      navigateToChat(message);
    } else if (message.data['view'] == 'pompe_noitif_view') {
      _navigationService.navigateToView(DemandPompeView());
    } else if (message.data['view'] == 'pardon_view') {
      _navigationService.navigateToView(DeceListView());
    } else if (message.data['view'] == 'mosque_notif_view') {
      if (message.data.containsKey('mosque')) {
        Mosque mosque = Mosque.fromJson(message.data['mosque']);
        _navigationService.navigateToView(DeceMosqueView(mosque));
      }
    } else if (message.data['view'] == 'new_friend') {
      _navigationService.navigateToView(RelationView());
    } else if (message.data['view'] == 'carte_list_view') {
      var carteString = json.decode(message.data['carte']);
      Carte carte = Carte.fromJson(carteString);
      _navigationService
          .navigateToView(CarteListView(openCarte: carte, onglet: 'receive'));
    } else if (message.data['view'] == 'obligation_list_view') {
      String tab = message.data['tab'] ?? 'processing';
      _navigationService
          .navigateToView(DetteView(message.data['type'], tab: tab));
    } else if (message.data['view'] == 'shared_testament_view') {
      _navigationService.navigateToView(ListSharedTestamentView());
    } else if (message.data['view'] == 'pray') {
      _navigationService.navigateToView(PriereView());
    }
  }

  void navigateToChat(RemoteMessage message) async {
    var messageDatas = message.data;
    bool hasThread = false;
    if (messageDatas.containsKey('threadId')) {
      ApiResponse apiResponse =
          await _chatRepository.getThreadFromId(messageDatas['threadId']);
      if (apiResponse.status == 200) {
        var decodeData = json.decode(apiResponse.data);
        Thread thread = Thread.fromJson(decodeData['thread']);
        _navigationService.navigateToView(ChatView(thread: thread));
        hasThread = true;
      }
    }
    if (!hasThread) {
      _navigationService.navigateToView(ThreadsView(title: ""));
    }
  }

  void showLocalNotification(
      RemoteNotification notification, RemoteMessage message,
      {showLocallNotif = true}) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'idoChannelID', 'iDOChannelName',
        channelDescription: 'notification iDO',
        importance: Importance.max,
        playSound: true,
        showProgress: true,
        priority: Priority.high);

    var iOSChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSChannelSpecifics);

    //should set an ID ? message.messageId.toString()
    if (showLocallNotif) {
      await flutterLocalNotificationsPlugin.show(
          0, notification.title, notification.body, platformChannelSpecifics,
          payload: json.encode(message.data));
    }
  }

  void onSelectNotification(NotificationResponse notificationResponse) {
    var messageData = jsonDecode(notificationResponse.payload!);
    RemoteMessage message = new RemoteMessage(data: messageData);
    this.navigateFromMessage(message);
  }
}
