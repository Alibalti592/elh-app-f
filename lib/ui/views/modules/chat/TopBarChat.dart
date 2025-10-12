import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:elh/common/theme.dart';
import 'package:elh/repository/ChatRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:flutter/material.dart';
import 'package:elh/locator.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/modules/chat/ThreadsView.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

class TopBarChat extends StatelessWidget {
  TopBarChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TopBarController>.reactive(
        viewModelBuilder: () => TopBarController(),
        onViewModelReady: (controller) => controller.periodicHasMessage(),
        onDispose:  (controller) => controller.cleanTimer(),
        builder: (context, controller, child) => Row(
          children: [
            Container(
              width: 60,
              child: Stack(children: [
                Positioned(
                  bottom: 3,
                  right: 5,
                  child: Container(
                    height: 45,
                    width: 45,
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50)
                    ),
                    child: IconButton(
                      icon: SizedBox(
                        width: 25,
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              'assets/icon/bubbles.svg',
                              color: fontGreyDark,
                              height: 22,
                              width: 22.0,
                              // fit: BoxFit.fill,
                            )
                        ),
                      ),
                      onPressed: () => {controller.navigateToChat()},
                    ),
                  ),
                ),
                ValueListenableBuilder<bool>(
                  builder: (BuildContext context, bool hasMessage, Widget? child) {
                    return UIHelper.dotNotif(hasMessage, 7.0, 12.0);
                  },
                  valueListenable: controller.hasNotifMessage,
                )
              ]),
            ),
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50)
              ),
              child: IconButton(
                padding: const EdgeInsets.only(bottom:2, left: 2),
                icon: Icon(
                  MdiIcons.whatsapp,
                  color: fontGreyDark,
                  size: 25,
                ),
                onPressed: () => {controller.gotToWhatsapp()},
              ),
            ),
            IconButton(
              icon: SizedBox(
                width: 35,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/icon/send.svg',
                    color: fontGreyDark,
                    height: 25,
                    width: 25.0,
                    // fit: BoxFit.fill,
                  )
                ),
              ),
              onPressed: () => {controller.shareApp()},
            ),

          ],
        )
    );
  }
}

class TopBarController extends ChangeNotifier {
  NavigationService _navigationService = locator<NavigationService>();
  DialogService _dialogService = locator<DialogService>();
  ChatRepository _chatRepository = locator<ChatRepository>();
  ValueNotifier<bool> hasNotifMessage = ValueNotifier<bool>(false);
  Timer? activeTimer;

  cleanTimer() {
    if(this.activeTimer != null) {
      this.activeTimer!.cancel();
    }
  }

  periodicHasMessage() {
    this.checkIfMessageApiCall();
    this.activeTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      this.checkIfMessageApiCall();
    });
  }

  checkIfMessageApiCall() async {
    ApiResponse apiResponse = await _chatRepository.hasMessage();
    if(apiResponse.status == 200) {
      int nbNotifications = json.decode(apiResponse.data)['nbNotifications'];
      this.hasNotifMessage.value = nbNotifications > 0;
    }
  }

  navigateToChat() {
    this.hasNotifMessage.value = false;
    _navigationService.navigateWithTransition(ThreadsView(title: '',), transition: 'rightToLeft', duration:Duration(milliseconds: 200))?.then((value) {
      this.checkIfMessageApiCall();
    });
  }

  shareApp() {
    //selon plateform lien Appstrore / android
    Share.share(subject: '', "Télécharge l’application gratuite Muslim Connect pour gérer tes dettes, emprunts et testament, avec un partage sécurisé à tes proches, et reste connecté et informé des Salât al-Janaza dans ta mosquée : https://apps.apple.com/us/app/muslim-connect/id6478540540");
  }

  gotToWhatsapp() async {
    String contact = "+33759676631";
    String text = '';
    String androidUrl = "whatsapp://send?phone=$contact&text=$text";
    String iosUrl = "https://wa.me/$contact?text=${Uri.parse(text)}";
    var confirm = await _dialogService.showDialog(
        title: "Assalem Alaykoum", description: "Votre avis compte !\nDes idées ou améliorations ?\nPartagez-les pour améliorer Muslim Connect",
        buttonTitleColor: fontDark,
        buttonTitle: 'Contactez-nous !', barrierDismissible: true);
    if(confirm?.confirmed == true) {
      if (Platform.isIOS) {
        if (await canLaunchUrl(Uri.parse(iosUrl))) {
          await launchUrl(Uri.parse(iosUrl));
        }
      } else {
        if (await canLaunchUrl(Uri.parse(androidUrl))) {
          await launchUrl(Uri.parse(androidUrl));
        }
      }
    }
  }
}