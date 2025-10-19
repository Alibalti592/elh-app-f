import 'dart:convert';

import 'package:elh/common/theme.dart';
import 'package:elh/locator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked_services/stacked_services.dart';

class ErrorMessageService {
  DialogService _dialogService = locator<DialogService>();
  bool dialogIsOpened = false; //prevent mutliple popup

  Future<DialogResponse?> errorOnAPICall({message}) async {
    if (message == null) {
      message =
          "Une erreur s'est produite à la récupération des données, merci de réessayer ultérieurement !";
    }
    DialogResponse? response;
    if (!dialogIsOpened) {
      this.dialogIsOpened = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        response = await _dialogService.showDialog(
            title: 'Oups une erreur', description: message);
        if (response != null && response!.confirmed) {
          this.dialogIsOpened = false;
        }
      });
    }
    return response;
  }

  void errorDefault() async {
    this.dialogIsOpened = false;
    if (!dialogIsOpened) {
      this.dialogIsOpened = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        DialogResponse? response = await _dialogService.showDialog(
            title: 'Oups une erreur',
            description:
                "Une erreur s'est produite merci de nous contacter si le problème persiste !");
        if (response != null && response.confirmed) {
          this.dialogIsOpened = false;
        }
      });
    }
  }

  void errorShoMessage(message, {title = 'Oups une erreur'}) async {
    if (message != null) {
      try {
        var data = json.decode(message);
        if (data.containsKey('message')) {
          message = data['message'];
        }
      } on FormatException {
        //no valid json
      }
    }
    if (!dialogIsOpened) {
      this.dialogIsOpened = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        DialogResponse? response =
            await _dialogService.showDialog(title: title, description: message);
        if (response != null && response.confirmed) {
          this.dialogIsOpened = false;
        }
      });
    }
  }

  void noConnexion() async {
    if (!dialogIsOpened) {
      this.dialogIsOpened = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        DialogResponse? response = await _dialogService.showDialog(
            title: 'Aucune connexion',
            description: "Veuillez vérifier votre connexion internet !");
        if (response != null && response.confirmed) {
          this.dialogIsOpened = false;
        }
      });
    }
  }

  showToaster(status, message) {
    Color bgColor = bgLight;
    Color fontColor = fontDark;
    if (status == 'success') {
      const Color successColor = Color(0xFF66bb6a);
      bgColor = successColor;
      fontColor = Colors.white;
      print(bgColor);
    } else if (status == 'error') {
      bgColor = errorColor;
      fontColor = white;
    }

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 2,
      backgroundColor: bgColor,
      textColor: fontColor,
      fontSize: 16.0,
      gravity: ToastGravity.TOP,
    );
  }
}
