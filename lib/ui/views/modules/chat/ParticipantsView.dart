import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/models/ChatParticipants.dart';
import 'package:elh/models/ChatThread.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/userThumb.dart';
import 'package:elh/ui/views/modules/chat/ChatController.dart';
import 'package:elh/ui/views/modules/chat/ParticipantsController.dart';
import 'package:stacked/stacked.dart';

class ParticipantsView extends StatelessWidget {
  final List<Participant?> participants;
  final Thread thread;
  final String currentUserId;
  final ChatContoller chatController;
  ParticipantsView({Key? key, required this.participants, required this.thread, required this.currentUserId, required this.chatController}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ParticipantsContoller>.reactive(
        builder: (context, controller, child) => SingleChildScrollView(
          child: Column(
            children: [
              (thread.administrator && thread.type == 'group') ? Container(
                color: bgLightV2,
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      this.chatController.closeEventSourceListner();
                      controller.goToAddParticipants();
                    },
                    child: Icon(Icons.add_circle_outline_rounded, color: fontGrey),
                  ),
                ),
              ) : Container(),
              _listParticipants(controller)
            ],
          ),
        ),
        viewModelBuilder: () => ParticipantsContoller(participants, thread, currentUserId));
  }

  _listParticipants(ParticipantsContoller controller) {
    List<Widget> users = [];
    controller.participants.forEach((participant) {
      users.add(
          Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      userThumbIconEmpty(participant?.imageUrl, 40.0, Icons.person_outline_outlined , 16.0),
                      UIHelper.horizontalSpace(10),
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(participant!.name, style: TextStyle(fontWeight: FontWeight.bold),),
                            ],
                          )),
                      Container(
                        width: 70,
                        alignment: Alignment.topRight,
                        child: _actions(controller, participant, thread.administrator),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
      );
    });
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: users,
      ),
    );
  }
  
  Widget _actions(ParticipantsContoller controller, Participant participant, bool isAdministrator) {
    return (isAdministrator && thread.type == 'group' && participant.id != controller.currentUserId)  ? controller.userIdDeletting == participant.id ? BBloader() : IconButton(icon: Icon(Icons.delete_sweep_outlined), onPressed: () {
      controller.delete(participant);
    }): Container();
  }
}
