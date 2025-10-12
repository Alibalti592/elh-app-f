import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:elh/models/BBLocation.dart';
import 'package:elh/services/ImageService.dart';
import 'package:elh/store/LocationStore.dart';
import 'package:elh/ui/views/common/BBLocation/BBLocationView.dart';
import 'package:flutter/cupertino.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/repository/UserDataRepository.dart';
import 'package:elh/repository/UserRepository.dart';
import 'package:elh/services/AuthenticationService.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/locator.dart';
import 'package:elh/services/UserInfosReactiveService.dart';
import 'package:elh/ui/shared/Validators.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ProfileViewModel extends FutureViewModel<dynamic> {
  final AuthenticationService _authenticationService = locator<AuthenticationService>();
  NavigationService _navigationService = locator<NavigationService>();
  UserDataRepository _userDataRepository= locator<UserDataRepository>();
  UserRepository _userRepository= locator<UserRepository>();
  UserInfoReactiveService _userInfoReactiveService= locator<UserInfoReactiveService>();
  LocationStore _locationStore = locator<LocationStore>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  DialogService _dialogService = locator<DialogService>();
  ValueNotifier<bool> isSaving = ValueNotifier<bool>(false);
  final ImageService _imageService = locator<ImageService>();
  late UserInfos userInfos;
  late UserInfos userInfosForEdit;
  Bblocation? newLocation;
  String? newEmail;
  TextEditingController passwordController = TextEditingController();
  TextEditingController cityTextController = TextEditingController();
  dynamic paramsConfid;
  //Export
  ValueNotifier<bool> isSavingData = ValueNotifier<bool>(false);
  String? userToken;
  //images
  final ImagePicker _picker = ImagePicker();
  XFile? pickedFile;
  File? bannerFile;
  File? profileFile;
  TextEditingController phoneController = TextEditingController();
  PhoneNumber phoneNumber  = PhoneNumber(isoCode: 'FR');

  //constructor
  ProfileViewModel(userInfos)  {
   this.userInfos = userInfos;
   this.newEmail = this.userInfos.email;
   phoneController.text = this.userInfos.phone == null ? "" : this.userInfos.phone!;
   this.userInfosForEdit = userInfos;
   cityTextController.text = this.userInfos.city;
   this.setIniPhoneNumber();
  }

  setIniPhoneNumber() async {
    phoneNumber  = PhoneNumber(isoCode: PhoneNumber.getISO2CodeByPrefix(this.userInfos.phonePrefix), phoneNumber: this.userInfos.phone, dialCode: this.userInfos.phonePrefix);
  }

  @override
  Future<dynamic> futureToRun() => loadDatas();

  getUserToken() async {
    String token = await _authenticationService.getUserToken();
    this.userToken = token;
  }

  Future loadDatas() async {
    await getUserToken();
  }

  Future<void> refreshData() async {
    this.isSavingData.value = false;
  }

  openSearchLocation(context) {
    _navigationService.navigateWithTransition(BBLocationView(), transitionStyle: Transition.downToUp, duration:Duration(milliseconds: 300))?.then((value) {
        if(value == "setLocation") {
          this.newLocation = _locationStore.selectedLocation;
          if(this.newLocation != null) {
            this.userInfosForEdit.city = this.newLocation!.city;
            cityTextController.text = this.newLocation!.city;
          }
        }
    });
    //CALLBACK !!
  }

  deleteAccount() async {
    DialogResponse? response = await this._dialogService.showConfirmationDialog(title: 'Valider la suppression définitive de votre compte et de ses données ?',
        cancelTitle: 'Annuler', confirmationTitle: 'Supprimer définitivement');
    if(response?.confirmed == true) {
      await getUserToken();
      ApiResponse apiResponse = await _userRepository.deleteAccount(this.userToken);
      if (apiResponse.status == 200) {
        //logout
        _authenticationService.logoutUser();
      } else {
        _errorMessageService.errorOnAPICall();
      }
    }
  }

  saveAccount() async {
    this.isSaving.value = true;
    String? locationString;
    if(this.newLocation != null) {
      locationString = json.encode(this.newLocation!.toJson());
    } else if(this.userInfos.city == null) {
      this.isSaving.value = false;
      _dialogService.showDialog(title: 'Vérifier votre ville', description: "Saisir votre localisation ");
      return;
    }
    String? newEmail;
    String? newEmailFromUI = this.newEmail?.trim();
    if(newEmailFromUI != this.userInfos.email) {
      String? validEmailMessage = ValidatorHelpers.validateEmail(newEmailFromUI);
      if(validEmailMessage != null) {
        _dialogService.showDialog(title: 'Vérifier le mail', description: "Adresse email invalide !");
        this.isSaving.value = false;
        return;
      }
      newEmail = newEmailFromUI;
    }
    if(this.userInfos.phone == null || this.userInfos.phone == '') {
      _dialogService.showDialog(title: 'Vérifier le téléphone', description: "Saisir un numéro de teléphone !");
      this.isSaving.value = false;
      return;
    }
    ApiResponse apiResponse = await _userDataRepository
        .saveUserAccount(userInfosToJson(this.userInfosForEdit), locationString, newEmail);
    if(apiResponse.status == 200) {
      var data = json.decode(apiResponse.data);
      if(data.containsKey('token')) {
        var jwt = apiResponse.data;
        if (_authenticationService.jwtIsToken(jwt)) {
          await _authenticationService.setNewTokenForUser(jwt);
        }
      }
      await _userInfoReactiveService.resetUserInfos();
      this.userInfos = await _userInfoReactiveService.getUserInfos(cache: false);
      this.userInfosForEdit = this.userInfos;
      this.isSaving.value = false;
      _errorMessageService.showToaster("success", 'Profil mis à jour');
    } else {
      var data = json.decode(apiResponse.data);
      String? message;
      if(data.containsKey('message')) {
        message = data['message'];
      }
      _dialogService.showDialog(title: 'Oups une erreur', description: message);
      this.isSaving.value = false;
      return;
    }
  }

  openSingleImagePicker(imageKey) async {
    double maxSize = 1200;
    if(imageKey == 'profile') {
      maxSize = 800;
    }
    try {
      this.pickedFile = await this._picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxSize,
        maxHeight: maxSize,
      );
      cropImage(pickedFile?.path, imageKey);
    } catch (e) {
      this._errorMessageService.errorShoMessage(e, title: "Problème lors de la sélection d'image");
    }
  }

  cropImage(filePath, imageKey) async {
    int maxWidth = 200;
    int maxHeight = 200;
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
      ],
    );
    if(croppedImage != null) {
      this.profileFile = File(croppedImage.path);
      notifyListeners();
      String? base64Profile;
      if(this.profileFile != null) {
        base64Profile = await _imageService.getBase64ImageFromPath(this.profileFile!);
      }
      if(base64Profile != null) {
        //save it !!
        ApiResponse apiResponse = await _userDataRepository.updatePhoto(base64Profile);
        if(apiResponse.status == 200) {
          await _userInfoReactiveService.resetUserInfos();
          this.userInfos = await _userInfoReactiveService.getUserInfos(cache: false);
        } else {
          _errorMessageService.errorShoMessage( "Oups une erreur sur l'image !");
        }
      }
    } else {
      this.profileFile = null;
      notifyListeners();
    }
  }


  removeImage() async {
    this.isSaving.value = true;
    ApiResponse apiResponse = await _userDataRepository.removePhoto();
    if(apiResponse.status == 200) {
      await _userInfoReactiveService.resetUserInfos();
      this.userInfos = await _userInfoReactiveService.getUserInfos(cache: false);
      this.profileFile = null;
      this.userInfos.photo = "";
      this.isSaving.value = false;
      notifyListeners();
    } else {
      _errorMessageService.errorShoMessage( "Oups une erreur lors supression image !");
      this.isSaving.value = false;
    }
  }


  setPhoneNumber(PhoneNumber phoneNumber) {
    this.userInfos.phone = phoneNumber.parseNumber();
    this.userInfos.phonePrefix = phoneNumber.dialCode !;
    this.phoneNumber = phoneNumber;
    notifyListeners();
  }


}