// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// // import 'package:heic_to_jpg/heic_to_jpg.dart';
// import 'package:elh/locator.dart';
// import 'package:elh/services/BaseApi/ApiResponse.dart';
// import 'package:elh/services/ErrorMessageService.dart';
// import 'package:elh/services/ImageService.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:stacked/stacked.dart';
// import 'package:stacked_services/stacked_services.dart';
// import 'package:path/path.dart' as p;
//
//
// class BbImagePickerController extends FutureViewModel<dynamic> {
//   NavigationService _navigationService = locator<NavigationService>();
//   ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
//   bool isUploading = false;
//   bool hasChangedAndNotSaved = false;
//   bool imageIsLoading = false;
//   final ImagePicker _picker = ImagePicker();
//   XFile? pickedFile;
//   String? filePath;
//   BoxFit fitType = BoxFit.cover;
//   late File imageFile;
//   late File imageFileOriginal;
//   var image;
//   bool square = true;
//
//   BbImagePickerController(PostDetails postDetails) {
//     this.postDetails = postDetails;
//     notifyListeners();
//   }
//
//   @override
//   Future<dynamic> futureToRun() => ini();
//
//   Future ini() async {
//     retrieveLostData();
//     if(this.pickedFile == null) {
//       this.openSingleImagePicker();
//     }
//   }
//
//   openSingleImagePicker() async {
//     this.imageIsLoading = true;
//     notifyListeners();
//     //picker fait le resize , 1200 !
//     try {
//       this.pickedFile = (await this._picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1200,
//         maxHeight: 1200,
//       ))!;
//       await prepareImageForUI();
//       //FORCE CROP : evite erreur
//       // String extension = p.extension(this.filePath).replaceAll('.', '');
//       // if(extension == 'png') {
//       //   cropImage();
//       // }
//     } catch (e) {
//       this._errorMessageService.errorShoMessage(e, title: "Problème lors de la sélection d'image");
//     }
//   }
//
//   changeFit() {
//     if(this.fitType == BoxFit.cover) {
//       this.imageFile = this.imageFileOriginal;
//       this.fitType = BoxFit.contain;
//       this.square = false;
//     } else {
//       this.fitType = BoxFit.cover;
//       this.square = true;
//     }
//     notifyListeners();
//   }
//
//   cropImage() async {
//     CroppedFile? croppedImage = await ImageCropper().cropImage(
//       sourcePath: this.filePath!,
//       maxWidth: 900,
//       maxHeight: 900,
//       aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
//       uiSettings: [
//         AndroidUiSettings(
//           lockAspectRatio: true,
//           hideBottomControls: true,
//         ),
//         IOSUiSettings(
//             aspectRatioLockEnabled: true
//         )
//       ]
//     );
//     if (croppedImage  != null) {
//       this.imageFile = croppedImage as File;
//       this.filePath = this.imageFile.path;
//       notifyListeners();
//     }
//   }
//
//   prepareImageForUI() async {
//     this.imageFile = new File(pickedFile!.path);
//     notifyListeners();
//     this.imageFileOriginal = new File(pickedFile!.path);
//     this.filePath = pickedFile!.path;
//     this.imageIsLoading = false;
//     notifyListeners();
//   }
//
//   Future<void> retrieveLostData() async {
//     final LostDataResponse response = await _picker.retrieveLostData();
//     if (response.isEmpty) {
//       return;
//     }
//     if (response.file != null) {
//       if (response.type == RetrieveType.image) {
//         this.pickedFile = response.file!;
//       }
//     }
//   }
//
//   uploadImage(context) async {
//     this.isUploading = true;
//     notifyListeners();
//     //transform HEIC if needed
//     String extension = p.extension(this.filePath!).replaceAll('.', '');
//     if (extension == 'heic') {
//       this.filePath = await ImageService.convertHeicToJpeg(this.filePath!);
//       this.imageFile = new File(this.filePath!);
//       extension = 'jpeg';
//     }
//     String myme = 'png';
//     if(extension == 'jpg' || extension == 'jpeg') {
//       myme = 'jpeg';
//     }
//     String base64Image = "data:image/"+myme+";base64,"+base64Encode(this.imageFile.readAsBytesSync());
//     ApiResponse apiResponse = await _socialRepository.uploadImage(this.postDetails.id, base64Image, this.square);
//     if(apiResponse.status == 200) {
//       this.postDetails.images = [];
//       this.postDetails.images = [];
//       this.postDetails.images = postImagesFromJson(json.encode(json.decode(apiResponse.data)['images']));
//       Navigator.of(context).pop();
//     } else {
//       _errorMessageService.errorDefault();
//       this.isUploading = false;
//       notifyListeners();
//     }
//   }
//
// // getThumbnail() async {
// //   if(this.imageFile == null) {
// //     this.thumbBytes = null;
// //     notifyListeners();
// //   }
// //   var thumbImage = imageLib.decodeImage(await this.imageFile.readAsBytes());
// //   imageLib.copyResize(thumbImage, width: 150);
// //   this.thumbBytes = await this.applyFilter(thumbImage);
// //   notifyListeners();
// // }
// //
// // applyFilter(image) {
// //   Filter filter = BrooklynFilter();
// //   String filename = this.filePath;
// //   List<int> _bytes = image.getBytes();
// //   if (filter != null) {
// //     filter.apply(_bytes as dynamic, image.width, image.height);
// //   }
// //   imageLib.Image _image =
// //   imageLib.Image.fromBytes(image.width, image.height, _bytes);
// //   _bytes = imageLib.encodeNamedImage(_image, filename);
// //   print(_bytes);
// //   return _bytes;
// // }
// }