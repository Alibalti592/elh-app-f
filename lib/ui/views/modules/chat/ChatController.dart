import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:elh/services/ImageService.dart';
import 'package:elh/ui/views/modules/chat/ImageFullscreen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:elh/services/HubMessage/HubMessage.dart';
import 'package:flutter/cupertino.dart';
import 'package:elh/models/ChatMessage.dart';
import 'package:elh/models/ChatParticipants.dart';
import 'package:elh/models/ChatThread.dart';
import 'package:elh/repository/ChatRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ChatReactiveService.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:elh/services/HubMessage/class/event.dart';
import 'package:elh/ui/views/modules/chat/EditThreadDataView.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:path/path.dart' as p;

class ChatContoller extends FutureViewModel<dynamic> {
  ChatRepository _chatRepository = locator<ChatRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  DialogService _dialogService = locator<DialogService>();
  final ChatReactiveService _chatReactiveService = locator<ChatReactiveService>();
  NavigationService _navigationService = locator<NavigationService>();
  ScrollController scrollController = new ScrollController();
  int pageStackIndex = 0;
  bool isLoading = true;
  late Thread thread;
  String addMEssage = "";
  ValueNotifier<bool> isSending = ValueNotifier<bool>(false);
  ValueNotifier<bool> isDeleting = ValueNotifier<bool>(false);
  int page = 1;
  String? userId;
  bool loadParticipants = true;
  bool hasMoreMessages = true;
  List<Participant> participants = [];
  ValueNotifier<List<ChatMessage>> chatMessages = ValueNotifier<List<ChatMessage>>([]);
  bool userIsAdmin = false;
  ValueNotifier<String> showTypingIndicator = ValueNotifier<String>('');
  Participant? typingParticipant;
  bool firstLoading = true;
  Timer? typingTimeout;
  bool sendIsTyping = true;
  late EventSource eventSource;
  StreamSubscription<Event>? listner;
  TextEditingController textEditingController = new TextEditingController();
  ValueNotifier<String?> selectedMessageId = ValueNotifier<String?>(null);
  ValueNotifier<File?> toUploadFile = ValueNotifier<File?>(null);
  String fileType = "";
  String fileToUploadName = "";
  ValueNotifier<bool> threadLoading = ValueNotifier<bool>(false);
  Timer? timergetLastMessage;
  String? lastMessageId;
  final ImagePicker _picker = ImagePicker();

  //constructor
  ChatContoller(Thread thread) {
    this.thread = thread;
    textEditingController.selection = TextSelection.fromPosition(TextPosition(offset: addMEssage.length));
    this.scrollController.addListener(_scrollListener);
    timergetLastMessage = Timer.periodic(Duration(seconds: 10), (Timer t) => this.loadLastMessages());
  }

  @override
  Future<dynamic> futureToRun() => loadThreadData(true, false);

  cleanTimer() {
    if(this.timergetLastMessage != null) {
      this.timergetLastMessage!.cancel();
    }
  }

  loadLastMessages() async {
    if(this.lastMessageId != null) {
      ApiResponse apiResponse = await _chatRepository.loadLastMessages(this.thread.id.toString(), this.lastMessageId);
      if(apiResponse.status == 200) {
        var decodeData = json.decode(apiResponse.data);
        List<ChatMessage> newMessages = chatMessagesFromJson(decodeData['messages']);
        this.addUniqueMessages(newMessages);
        // this.chatMessages.value = List.from(chatMessages.value)..addAll(chatMessagesFromJson(decodeData['messages']));
        notifyListeners();
      }
    }
  }
  void addUniqueMessages(List<ChatMessage> newMessages) {
    for (var message in newMessages) {
      // Check if the message ID already exists in chatMessages
      bool exists = this.chatMessages.value.any((m) => m.id == message.id);
      if (!exists) {
        this.chatMessages.value.insert(0, message);
        this.lastMessageId = message.id;
      }
    }
  }

  Future loadThreadData(showMessageLoading, addToMessages) async {
    if(showMessageLoading) {
      this.isLoading = true;
      notifyListeners();
    }
    ApiResponse apiResponse = await _chatRepository.loadMessages(this.thread.id.toString(), page.toString(), loadParticipants.toString());
    if(apiResponse.status == 200) {
      var decodeData = json.decode(apiResponse.data);
      this.participants = participantFromJson(decodeData['participants']);
      if(addToMessages) {
        this.chatMessages.value = List.from(chatMessages.value)..addAll(chatMessagesFromJson(decodeData['messages']));
      } else {
        this.chatMessages.value = [];
        this.chatMessages.value = List.from(chatMessages.value)..addAll(chatMessagesFromJson(decodeData['messages']));
      }
      try {
        if(this.page == 1 && this.chatMessages.value.length > 0) {
          if(this.chatMessages.value.last != null) {
            this.lastMessageId = this.chatMessages.value.last!.id;
          }
        }
      } catch(e) {}

      this.userId = decodeData['userId'];
      this.hasMoreMessages = decodeData['hasMoreMessages'];
      this.isLoading = false;
      notifyListeners();
      if(this.firstLoading) {
        // initialiseHub(decodeData['hubUrl']);
        _chatReactiveService.chekIfMessage();
      }
      this.firstLoading = false;
    } else {
      //error déjà affiché via API Service !!
      print('errror');
    }
  }

  _scrollListener() {
    if(scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange && this.hasMoreMessages) {
      this.page++;
      this.loadThreadData(false, true);
    }
  }

  changePageIndex(newIndex) {
    this.pageStackIndex = newIndex;
    notifyListeners();
  }

 Participant? getParticipant(userId) {
    return this.participants.firstWhereOrNull(
          (participant) => participant.id == userId
    );
  }

  saveNewMessage() async {
    if((this.addMEssage != "" || this.toUploadFile.value != null) && !this.isSending.value) {
      this.isSending.value = true;
      String textTSend = this.addMEssage;
      Message message = new Message(meta: "", text: textTSend);
      if(this.selectedMessageId.value != null && this.addMEssage != "") { //edition
        ChatMessage chatMessage = this.chatMessages.value.firstWhere(
              (message) => message.id == this.selectedMessageId.value,
        );
        chatMessage.message = message;
        ApiResponse apiResponse = await _chatRepository.editMessage(chatMessage);
        if(apiResponse.status == 200) {
          var decodeData = json.decode(apiResponse.data);
          ChatMessage newChatMessage = ChatMessage.fromJson(decodeData['chatMessage']);
          this.updateChatMessageInList(newChatMessage);
          this.unSelectMessage();
        } else {
          _errorMessageService.errorShoMessage("Non modifié !");
        }
      } else { //new message
        ChatMessage chatMessage = new ChatMessage(id: 'ini', author: 'me', edited: false, deleted: false, message: message, type: "text",  showAuthor: false);
        ApiResponse apiResponse = await _chatRepository.addMessage(textTSend, thread, this.toUploadFile.value, this.fileToUploadName);
        if(apiResponse.status == 200) {
          var decodeData = json.decode(apiResponse.data);
          ChatMessage newChatMessage = ChatMessage.fromJson(decodeData['message']);
          this.addBubbleOnChat(newChatMessage);
          this.addMEssage = "";
          textEditingController.text = "";
          this.removeFile();
        } else {
          _errorMessageService.errorShoMessage("Non envoyé !");
        }
      }
    } else {
      _errorMessageService.errorShoMessage("Saisir un message");
    }
    this.isSending.value = false;
  }

  addBubbleOnChat(ChatMessage chatMessage) {
    this.chatMessages.value = [chatMessage, ...chatMessages.value];
  }

  goToEditDatas() {
    this.closeEventSourceListner();
    _navigationService.replaceWithTransition(EditThreadDataView(this.thread));
  }

  //real time
  initialiseHub(hubUrl) async {
    if(hubUrl != false) {
      var uri = Uri.dataFromString(hubUrl);
      // Map<String, String> params = uri.queryParameters;
      // var topic = params['topic'];
      // hubUrl = 'http://192.168.0.18:3002/.well-known/mercure?topic=$topic';
      this.eventSource = await EventSource.connect(hubUrl, openOnlyOnFirstListener: true, closeOnLastListener: true);
      this.listner = this.eventSource.listen((event) {
        var data  = json.decode(event.data!);
        var type = data['type'];
        var value = data['value'];
        if(type == 'typing' && this.userId != value) {
          this.typingParticipant = getParticipant(value);
          this.showTypingIndicator.value = value;
        } else if(type == 'newMessage' && this.userId != value) {
          this.page = 1;
          this.loadThreadData(false, false);
        }
      });
    }

  }

  closeEventSourceListner() {
    // this.listner.cancel();
    // this.eventSource.client.close();
  }

  handleOnType () async {
    if (this.typingTimeout != null && this.typingTimeout?.isActive == true) {
      if(this.sendIsTyping) {
        this.sendIsTyping = false;
        //Typing notif on hub
        _chatRepository.sendtypingNotification(this.thread, 'typing');
      }
      clearTimeout(this.typingTimeout!);
    }
    this.typingTimeout = setTimeout(() {
      //User Stop Typing notif on hub
      _chatRepository.sendtypingNotification(this.thread, 'typing-off');
      this.sendIsTyping = true;
    }, 4000);
  }

  Timer setTimeout(callback, [int duration = 1000]) {
    return Timer(Duration(milliseconds: duration), callback);
  }

  void clearTimeout(Timer t) {
    t.cancel();
  }

  openImageFullScreen(url, chatMessageId) {
    if(this.selectedMessageId.value != chatMessageId) {
      _navigationService.navigateToView(ImageFullscreen(url));
    } else { //unselect
      this.selectedMessageId.value = null;
    }
  }

  selectMessage(ChatMessage message) {
    if(message.author == 'me' && !message.deleted) {
      this.selectedMessageId.value = message.id;
      this.isDeleting.value = false;
    }
  }

  unSelectMessage() {
    this.selectedMessageId.value = null;
    this.addMEssage = "";
    this.textEditingController.text = "";
  }

  deleteMessage() async {
    if(this.selectedMessageId.value != null) {
      var confirm = await _dialogService.showConfirmationDialog(title: "Supprimer le message", description: 'Confirmer la suppression ?', cancelTitle: 'Annuler', confirmationTitle: 'Supprimer');
      if(confirm?.confirmed == true) {
        this.isDeleting.value = true;
        ApiResponse apiResponse = await _chatRepository.deleteMessage(this.selectedMessageId.value);
        if (apiResponse.status == 200) {
          //replace message
          var decodeData = json.decode(apiResponse.data);
          ChatMessage newChatMessage = ChatMessage.fromJson(decodeData['chatMessage']);
          this.updateChatMessageInList(newChatMessage);
          this.unSelectMessage();
        } else {
          _errorMessageService.errorDefault();
        }
        this.isDeleting.value = false;
      }
    }
  }


  updateChatMessageInList(ChatMessage newChatMessage) {
    String newChatMessageId = newChatMessage.id;
    this.chatMessages.value = this.chatMessages.value.map((chatMessage) {
      return chatMessage.id == newChatMessageId ? newChatMessage : chatMessage;
    }).toList();
  }

  iniEditMessage() async {
    ChatMessage chatMessage =  this.chatMessages.value.firstWhere(
          (message) => message.id == this.selectedMessageId.value,
    );
    this.addMEssage = chatMessage.message!.text;
    this.textEditingController.text = this.addMEssage;
  }

  openFilePicker(type) async {
    var allowedExtensions = ['jpg', 'png', 'jpeg', 'heic', 'gif', 'svg', 'pdf', 'gps', 'tcx', 'fit', 'xml'];
    PlatformFile? fileDatas;
    if(type == 'file') {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );
      if(result != null) {
        fileDatas = result.files.first;
      }
    } else { //image
      XFile? pickedFile = await this._picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
      );
      if(pickedFile != null) {
        File file = File(pickedFile.path);
        fileDatas = PlatformFile(
          name: pickedFile.name, // XFile does not have a direct name, you can extract from path
          path: pickedFile.path,
          size: await file.length(), // Get file size in bytes
          bytes: await file.readAsBytes(), // Read the file as bytes
        );
      }
    }

    if(fileDatas != null) {
      if(!allowedExtensions.contains(fileDatas.extension)) {
        _errorMessageService.errorShoMessage(title: 'Format', 'Format non supporté !');
        return;
      }
      var sizeInMB = fileDatas.size/1000000;
      this.fileToUploadName = fileDatas.name;
      String filePath = fileDatas.path!;
      bool isImage = ['jpg', 'png', 'jpeg', 'heic'].contains(fileDatas.extension);
      //si imlage traitement !
      if(fileDatas.extension == 'heic') {
        filePath = await ImageService.convertHeicToJpeg(filePath);
      }
      if(isImage) {
        this.fileType = 'image';
        try {
          final String targetPath = p.join(Directory.systemTemp.path, this.fileToUploadName);
          var imageCompressresult = await FlutterImageCompress.compressAndGetFile(
            filePath, targetPath,
            minWidth: 1200,
            minHeight: 1500,
            quality: 92,
          );
          var newSizeMB = (await imageCompressresult!.length()) /1000000;
          if(newSizeMB < sizeInMB) {
            filePath = targetPath;
            sizeInMB = newSizeMB;
          }
        } catch(e) {}
      }
      //PREVIEW
      this.toUploadFile.value = File(filePath);
    }
  }

  removeFile() {
    this.fileToUploadName = "";
    this.fileType = "";
    this.toUploadFile.value = null;
  }


  leaveThread() async {
    var confirm = await _dialogService.showConfirmationDialog(title: "Quitter la conversation ?",
        cancelTitle: 'Annuler',
        confirmationTitle: 'Quitter');
    if(confirm?.confirmed == true) {
      this.threadLoading.value = true;
      ApiResponse apiResponse = await _chatRepository.leaveThread(this.thread.id);
      if (apiResponse.status == 200) {
        this.closeEventSourceListner();
        _navigationService.back(result: 'refresh');
      } else {
        _errorMessageService.errorDefault();
      }
      this.threadLoading.value = false;
    }
  }

  deleteThread() async {
    var confirm = await _dialogService.showConfirmationDialog(title: "Supprimer la discussion et les messages ?", cancelTitle: 'Annuler',
        confirmationTitle: 'Supprimer');
    if(confirm?.confirmed == true) {
      this.threadLoading.value = true;
      ApiResponse apiResponse = await _chatRepository.deleteThread(this.thread.id);
      if (apiResponse.status == 200) {
        this.closeEventSourceListner();
        _navigationService.back(result: 'refresh');
      } else {
        _errorMessageService.errorDefault();
      }
      this.threadLoading.value = false;
    }
  }
}