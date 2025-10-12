import 'dart:async';
import 'dart:convert';
import 'package:elh/locator.dart';
import 'package:elh/repository/ChatRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:observable_ish/observable_ish.dart';
import 'package:stacked/stacked.dart';

class ChatReactiveService with ReactiveServiceMixin {
  ChatRepository _chatRepository = locator<ChatRepository>();
  RxValue<bool> _hasMessage = RxValue(false);
  bool get hasMessage => _hasMessage.value;
  int nbNotifications = 0;
  Timer? activeTimer;

  ChatReactiveService() {
    listenToReactiveValues([_hasMessage]);
    //on pourraier ajouter un EventSource ici avec localNotifications ...
  }

  chekIfMessage() async {
    ApiResponse apiResponse = await _chatRepository.hasMessage();
    if(apiResponse.status == 200) {
      this.nbNotifications = json.decode(apiResponse.data)['nbNotifications'];
      this._hasMessage.value = this.nbNotifications > 0;
      if(this.nbNotifications > 0) {
        return true;
      }
    }
    return false;
  }

  setHasMessage(value) {
    this._hasMessage.value = value;
  }

}