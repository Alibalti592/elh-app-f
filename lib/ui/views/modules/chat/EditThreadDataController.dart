import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:elh/locator.dart';
import 'package:elh/models/ChatThread.dart';
import 'package:elh/repository/ChatRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/services/ImageService.dart';
import 'package:elh/ui/views/modules/chat/ChatView.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked_services/stacked_services.dart';

class EditThreadDataController extends ChangeNotifier {
  ChatRepository _chatRepository = locator<ChatRepository>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  final ImageService _imageService = locator<ImageService>();
  TextEditingController searchInputController = new TextEditingController();
  NavigationService _navigationService = locator<NavigationService>();
  bool isLoading = true;
  bool isSaving = false;
  List threadTypeChoices = [];
  List selectionTypeChoices = [];
  late Thread thread;
  final _formKey = GlobalKey<FormState>();
  get formKey => _formKey;

  final ImagePicker _picker = ImagePicker();
  late XFile pickedFile;
  File? imageFile;

  EditThreadDataController(thread) {
    this.thread = thread;
  }

  openSingleImagePicker() async {
    double maxSize = 300;
    try {
      this.pickedFile = (await this._picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxSize,
        maxHeight: maxSize,
      ))!;
      cropImage(pickedFile.path);
    } catch (e) {
      this._errorMessageService.errorShoMessage(e, title: "Problème lors de la sélection d'image");
    }
  }

  cropImage(filePath) async {
    int maxWidth = 160;
    int maxHeight = 160;
    CropStyle cropStyle = CropStyle.circle;
    CropAspectRatio cropAspectRatio = CropAspectRatio(ratioX: 1.0, ratioY: 1.0);
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: filePath,
        compressFormat: ImageCompressFormat.jpg, //force jpeg !
        compressQuality: 100,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        aspectRatio: cropAspectRatio,
        uiSettings: [
          AndroidUiSettings(
            lockAspectRatio: true,
            hideBottomControls: true,
            cropStyle: cropStyle
          ),
          IOSUiSettings(
              aspectRatioLockEnabled: true,
              cropStyle: cropStyle,
          )
        ]
    );
    if (croppedImage  != null) {
      this.imageFile = File(croppedImage.path);
      notifyListeners();
    }
  }

  saveThread() async {
    this.isSaving = true;
    notifyListeners();
    String imageBase64 = "";
    if(this.imageFile != null) {
      imageBase64 = await _imageService.getBase64ImageFromPath(this.imageFile!);
    }
    ApiResponse apiResponse = await _chatRepository.saveThreadGroupDatas(this.thread, imageBase64) ;
    if(apiResponse.status == 200) {
      this.thread = Thread.fromJson(json.decode(apiResponse.data)['thread']);
      _navigationService.replaceWithTransition(ChatView(thread: thread));
    } else {
      _errorMessageService.errorOnAPICall();
      this.isSaving = false;
      notifyListeners();
    }
  }
}