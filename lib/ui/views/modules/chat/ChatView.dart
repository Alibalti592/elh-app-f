import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:elh/ui/shared/Responsive.dart';
import 'package:flutter/material.dart';
import 'package:elh/common/theme.dart';
import 'package:elh/models/ChatMessage.dart';
import 'package:elh/models/ChatParticipants.dart';
import 'package:elh/models/ChatThread.dart';
import 'package:elh/services/Extension/String.dart';
import 'package:elh/ui/shared/BBLoader.dart';
import 'package:elh/ui/shared/ui_helpers.dart';
import 'package:elh/ui/views/common/userThumb.dart';
import 'package:elh/ui/views/modules/chat/ChatController.dart';
import 'package:elh/ui/views/modules/chat/ParticipantsView.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ChatView extends StatelessWidget {
  final Thread thread;
  ChatView({Key? key, required this.thread}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatContoller>.reactive(
        builder: (context, controller, child) => PopScope(
              canPop: true,
              onPopInvoked: (didPop) {
                if (didPop) {
                  controller.cleanTimer();
                }
              },
              child: Scaffold(
                  backgroundColor: white,
                  appBar: AppBar(
                    leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () async {
                          if (controller.pageStackIndex == 1) {
                            controller.changePageIndex(0);
                          } else if (controller.selectedMessageId.value ==
                              null) {
                            controller.closeEventSourceListner();
                            Navigator.of(context).pop('refresh');
                          } else {
                            controller.unSelectMessage();
                          }
                        }),
                    titleSpacing: 0,
                    title: ValueListenableBuilder<String?>(
                        valueListenable: controller.selectedMessageId,
                        builder: (BuildContext context,
                            String? selectedMessageId, Widget? child) {
                          return selectedMessageId == null
                              ? GestureDetector(
                                  onTap: () {
                                    controller.changePageIndex(0);
                                  },
                                  child: Row(
                                    children: [
                                      userThumbIconEmpty(
                                          thread.image,
                                          35.0,
                                          thread.type == 'simple'
                                              ? Icons.person_outline_outlined
                                              : Icons.group_outlined,
                                          16.0),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Text(
                                            thread.name.length > 20
                                                ? thread.name.substring(0, 20) +
                                                    '...'
                                                : thread.name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(child: Text("1"));
                        }),
                    actions: [
                      ValueListenableBuilder<String?>(
                          valueListenable: controller.selectedMessageId,
                          builder: (BuildContext context,
                              String? selectedMessageId, Widget? child) {
                            return selectedMessageId == null
                                ? __chatActionsDropdown(thread, controller)
                                : __chatMessageSelectActions(controller);
                          }),
                    ],
                    flexibleSpace: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(220, 198, 169, 1),
                            Color.fromRGBO(143, 151, 121, 1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    backgroundColor: white,
                  ),
                  body: controller.isLoading
                      ? BBloader()
                      : IndexedStack(
                          index: controller.pageStackIndex,
                          children: [
                            SafeArea(
                              child: Column(
                                children: [
                                  ValueListenableBuilder<List<ChatMessage>>(
                                    builder: (BuildContext context,
                                        List<ChatMessage> chatMessages,
                                        Widget? child) {
                                      return Flexible(
                                          child: bubbleItemList(
                                              context, controller));
                                    },
                                    valueListenable: controller.chatMessages,
                                  ),
                                  userIsTyping(controller),
                                  // eventOnNextMessage(controller),
                                  filePreview(controller, context),
                                  Container(
                                    child: _buildInput(controller),
                                  ),
                                ],
                              ),
                            ),
                            ParticipantsView(
                                participants: controller.participants,
                                thread: controller.thread,
                                currentUserId: controller.userId!,
                                chatController: controller)
                          ],
                        )),
            ),
        viewModelBuilder: () => ChatContoller(thread));
  }

  Widget __chatMessageSelectActions(ChatContoller controller) {
    return ValueListenableBuilder<bool>(
        valueListenable: controller.isDeleting,
        builder: (BuildContext context, bool isDeleting, Widget? child) {
          return isDeleting
              ? BBloader()
              : Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          controller.iniEditMessage();
                        },
                        child: Icon(MdiIcons.pencilOutline)),
                    UIHelper.horizontalSpace(15),
                    GestureDetector(
                        onTap: () {
                          controller.deleteMessage();
                        },
                        child: Icon(MdiIcons.trashCanOutline)),
                    UIHelper.horizontalSpace(20),
                  ],
                );
        });
  }

  Widget __chatActionsDropdown(Thread thread, ChatContoller controller) {
    List<PopupMenuItem> popupMenuItems = [];
    if (thread.type == 'group' && thread.administrator) {
      popupMenuItems.add(PopupMenuItem(
          child: Row(
            children: [
              Icon(MdiIcons.security, color: fontGrey, size: 15),
              UIHelper.horizontalSpace(6),
              Text(
                'Admin du groupe',
                style: TextStyle(color: fontGrey, fontSize: 15),
              )
            ],
          ),
          value: "donothing"));
    }
    if (thread.type == 'group') {
      popupMenuItems.add(PopupMenuItem(
          child: Row(
            children: [
              Icon(
                Icons.group_outlined,
                color: fontGrey,
                size: 16,
              ),
              UIHelper.horizontalSpace(6),
              Flexible(child: Text('Participants'))
            ],
          ),
          value: "participants"));
    }
    if (thread.type == 'group' && thread.administrator) {
      popupMenuItems.add(PopupMenuItem(
          child: Row(
            children: [
              Icon(
                MdiIcons.pencil,
                color: fontGrey,
                size: 16,
              ),
              UIHelper.horizontalSpace(6),
              Text('Éditer')
            ],
          ),
          value: "edit"));
    }
    if (thread.type == 'group' && !thread.administrator) {
      popupMenuItems.add(PopupMenuItem(
          child: Row(
            children: [
              Icon(MdiIcons.exitToApp, color: white, size: 19),
              UIHelper.horizontalSpace(6),
              Text('Quitter la conversation')
            ],
          ),
          value: "leave-thread"));
    }
    if (thread.type == 'simple' || thread.administrator) {
      popupMenuItems.add(PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: fontDark, size: 19),
              UIHelper.horizontalSpace(6),
              Text('Supprimer la discussion')
            ],
          ),
          value: "delete-thread"));
    }

    return ValueListenableBuilder<bool>(
        valueListenable: controller.threadLoading,
        builder: (BuildContext context, bool threadLoading, Widget? child) {
          return threadLoading
              ? BBloader()
              : PopupMenuButton(
                  itemBuilder: (BuildContext bc) => popupMenuItems,
                  onCanceled: () {},
                  onSelected: (newValue) {
                    if (newValue == 'leave-thread') {
                      controller.leaveThread();
                    } else if (newValue == 'delete-thread') {
                      controller.deleteThread();
                    } else if (newValue == 'participants') {
                      controller.changePageIndex(1);
                    } else if (newValue == 'edit' && thread.administrator) {
                      controller.goToEditDatas();
                    } else {
                      controller.changePageIndex(0);
                    }
                  },
                );
        });
  }

  Widget _buildInput(ChatContoller controller) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: white,
        border: Border.all(
          color: borderGrey,
          width: 1,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
      ),
      child: ValueListenableBuilder<bool>(
        builder: (BuildContext context, bool isSending, Widget? child) {
          return Row(
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 100,
                  ),
                  child: TextField(
                    maxLines: null,
                    minLines: 1,
                    maxLength: 500,
                    keyboardType: TextInputType.multiline,
                    enabled: isSending ? false : true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: "Envoyer un mess...",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      counterText: "", //hide counter
                    ),
                    onChanged: (String text) {
                      controller.addMEssage = text;
                      controller.handleOnType();
                    },
                    controller: controller.textEditingController,
                    onSubmitted: (String value) async {
                      if (!controller.isSending.value) {
                        controller.saveNewMessage();
                      }
                    },
                  ),
                ),
              ),
              isSending
                  ? BBloader()
                  : Row(
                      children: [
                        Transform.rotate(
                          angle: -0.8,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            child: GestureDetector(
                              child: Icon(MdiIcons.attachment,
                                  color: Colors.grey, size: 22),
                              onTap: () async {
                                controller.openFilePicker('file');
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: GestureDetector(
                            child: Icon(MdiIcons.imageOutline,
                                color: Colors.grey, size: 22),
                            onTap: () async {
                              controller.openFilePicker('image');
                            },
                          ),
                        ),
                        UIHelper.horizontalSpace(3),
                        GestureDetector(
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Transform.rotate(
                                angle: 0.75,
                                child: SizedBox(
                                  width: 25,
                                  child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.center,
                                      child: SvgPicture.asset(
                                        'assets/icon/send.svg',
                                        color: fontGreyDark,
                                        height: 24,
                                        width: 24.0,
                                        // fit: BoxFit.fill,
                                      )),
                                ),
                              )),
                          onTap: () async {
                            if (!isSending) {
                              controller.saveNewMessage();
                            }
                          },
                        ),
                      ],
                    ),
            ],
          );
        },
        valueListenable: controller.isSending,
      ),
    );
  }

  Widget bubbleItemList(context, ChatContoller controller) {
    List<ChatMessage> chatMessages = controller.chatMessages.value;
    return ListView.builder(
        controller: controller.scrollController,
        reverse: true,
        itemCount: chatMessages.length,
        itemBuilder: (BuildContext ctxt, int index) {
          //prebuild
          String currentUserID = chatMessages[index].author;
          bool messageOfcurrentUser = currentUserID == 'me';
          String? meta = chatMessages[index].message?.meta;
          FileMessage? fileMessage = chatMessages[index].fileMessage;
          Widget userProfile = Container();
          Widget lastMessageCheck = Container();
          if (!messageOfcurrentUser) {
            Participant? participant =
                controller.getParticipant(chatMessages[index].author);
            if (participant != null) {
              userProfile = Container(
                margin: EdgeInsets.only(left: 10, right: 5),
                child: userThumbIconEmpty(participant.imageUrl, 30.0,
                    Icons.person_outline_outlined, 15.0),
              );
            }
            if (controller.thread.type == 'group' && participant != null) {
              String userName = participant.name.truncate(max: 12);
              meta = '$userName - $meta';
            }
          } else {
            bool islast = index == 0;
            if (islast) {
              lastMessageCheck = Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50)),
                  child: Icon(
                    Icons.check,
                    color: Colors.blue,
                    size: 14,
                  ));
            }
          }

          Widget dateInfos = (chatMessages[index].message?.meta.length)! > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: Text(meta!,
                      style: TextStyle(
                        color: fontGrey,
                        fontSize: 11,
                      )),
                )
              : Container();

          return GestureDetector(
            onLongPress: () {
              controller.selectMessage(chatMessages[index]);
            },
            onTap: () {
              controller.unSelectMessage();
            },
            child: ValueListenableBuilder<String?>(
                valueListenable: controller.selectedMessageId,
                builder: (BuildContext context, String? selectedMessageId,
                    Widget? child) {
                  return Container(
                    color: selectedMessageId == chatMessages[index].id
                        ? primaryColor
                        : Colors.transparent,
                    child: Opacity(
                      opacity:
                          selectedMessageId == chatMessages[index].id ? 0.5 : 1,
                      child: Row(
                        key: UniqueKey(),
                        mainAxisAlignment: messageOfcurrentUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          userProfile,
                          //imp !!
                          IntrinsicWidth(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * .8,
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 6),
                              margin: EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                color: messageOfcurrentUser
                                    ? Color(0xFFD9F5FF)
                                    : white,
                                border: messageOfcurrentUser
                                    ? Border.all(
                                        color: Colors.transparent, width: 0)
                                    : Border.all(
                                        color: borderGrey,
                                        width: 1,
                                      ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  fileMessage != null
                                      ? Column(
                                          children: [
                                            fileMessage.type == 'chat-file'
                                                ? GestureDetector(
                                                    onTap: () {
                                                      launchUrlString(
                                                          fileMessage.link);
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8.0,
                                                          horizontal: 3),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                              MdiIcons
                                                                  .fileDocumentOutline,
                                                              color:
                                                                  primaryColor,
                                                              size: 20),
                                                          UIHelper
                                                              .horizontalSpace(
                                                                  5),
                                                          Text(
                                                              fileMessage.label,
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      primaryColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold))
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : GestureDetector(
                                                    onTap: () {
                                                      controller
                                                          .openImageFullScreen(
                                                              fileMessage.link,
                                                              chatMessages[
                                                                      index]
                                                                  .id);
                                                    },
                                                    child: ConstrainedBox(
                                                      constraints:
                                                          new BoxConstraints(
                                                              maxWidth: 300,
                                                              maxHeight: 300),
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            fileMessage.link,
                                                        placeholder: (context,
                                                                url) =>
                                                            SizedBox(
                                                                width: 100,
                                                                height: 50,
                                                                child: UIHelper
                                                                    .lineLoaders(
                                                                        1,
                                                                        20.0)),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(Icons.error),
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        )
                                      : Container(),
                                  //CONTENT MESSAGE
                                  Row(
                                    children: [
                                      chatMessages[index].deleted
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 3.0),
                                              child: Icon(MdiIcons.cancel,
                                                  color: fontGrey, size: 14),
                                            )
                                          : Container(),
                                      Flexible(
                                        child: Linkify(
                                          style: chatMessages[index].deleted
                                              ? TextStyle(
                                                  color: fontGrey,
                                                  fontSize: 14,
                                                )
                                              : TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                          onOpen: (link) =>
                                              launchUrlString(link.url),
                                          text:
                                              "${chatMessages[index].message?.text}",
                                        ),
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: dateInfos,
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: lastMessageCheck,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          );
        });
  }

  Widget filePreview(ChatContoller controller, context) {
    return ValueListenableBuilder<File?>(
        valueListenable: controller.toUploadFile,
        builder: (BuildContext context, File? file, Widget? child) {
          return file == null
              ? Container()
              : Container(
                  color: bgLightV2,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      controller.fileType == 'image'
                          ? Container(
                              width: Responsive.width(80, context),
                              height: 150,
                              child: Image.file(file))
                          : Container(
                              width: Responsive.width(80, context),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Transform.rotate(
                                        angle: -0.8,
                                        child: Icon(MdiIcons.attachment,
                                            color: fontGreyDark)),
                                    UIHelper.horizontalSpace(5),
                                    Text(controller.fileToUploadName),
                                  ],
                                ),
                              )),
                      InkWell(
                          onTap: () {
                            controller.removeFile();
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Icon(
                              Icons.close,
                              color: fontGrey,
                              size: 20,
                            ),
                          ))
                    ],
                  ),
                );
        });
  }

  Widget userIsTyping(ChatContoller controller) {
    //stter current  particiopant typing in et VlueNotifer on typinguserID
    return ValueListenableBuilder<String>(
      builder:
          (BuildContext context, String showTypingIndicator, Widget? child) {
        return showTypingIndicator != ""
            ? Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        userThumbIconEmpty(
                            controller.typingParticipant != null
                                ? controller.typingParticipant?.imageUrl
                                : "",
                            40.0,
                            Icons.person_outline_outlined,
                            16.0),
                        UIHelper.horizontalSpaceSmall(),
                        BBloader()
                      ],
                    ),
                  ],
                ),
              )
            : Container();
      },
      valueListenable: controller.showTypingIndicator,
    );
  }
}
