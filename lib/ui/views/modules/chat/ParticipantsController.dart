import 'package:flutter/cupertino.dart';
import 'package:elh/models/ChatParticipants.dart';
import 'package:elh/models/ChatThread.dart';
import 'package:elh/repository/ChatRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:elh/ui/views/modules/chat/AddThreadView.dart';
import 'package:elh/ui/views/modules/chat/ChatView.dart';
import 'package:stacked_services/stacked_services.dart';

class ParticipantsContoller extends ChangeNotifier {
  ChatRepository _chatRepository = locator<ChatRepository>();
  DialogService _dialogService = locator<DialogService>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  NavigationService _navigationService = locator<NavigationService>();
  late Thread thread;
  late List<Participant?> participants;
  TextEditingController textEditingController = new TextEditingController();
  String userIdDeletting = "";
  late String currentUserId;

  //constructor
  ParticipantsContoller(List<Participant?> participants, thread, currentUserId) {
    this.participants = participants;
    this.currentUserId = currentUserId;
    this.thread = thread;
  }

  delete(Participant participant) async {
    var confirm = await _dialogService.showConfirmationDialog(title: participant.name, description: 'Confirmer la suppression ?', cancelTitle: 'Annuler', confirmationTitle: 'Supprimer');
    if(confirm?.confirmed == true) {
      this.userIdDeletting = participant.id;
      notifyListeners();
      ApiResponse apiResponse = await _chatRepository.deleteParticipant(participant, thread);
      if (apiResponse.status == 200) {
        _navigationService.replaceWithTransition(ChatView(thread: thread));
      } else {
        _errorMessageService.errorDefault();
      }
    }
  }

  void goToAddParticipants() {
    // closeEventSourceListner()
    _navigationService.navigateToView(AddThreadView(thread));
  }

}