// import 'package:flutter/material.dart';
// import 'package:elh/common/theme.dart';
// import 'package:elh/models/PostDetails.dart';
// import 'package:elh/ui/shared/BBLoader.dart';
// import 'package:elh/ui/shared/ui_helpers.dart';
// import 'package:elh/ui/views/modules/social/imagePicker/BbImagePickerController.dart';
// import 'package:stacked/stacked.dart';
//
// class BbImagePickerView extends StatelessWidget {
//   final PostDetails postDetails;
//   BbImagePickerView(this.postDetails);
//   @override
//   Widget build(BuildContext context) {
//     return ViewModelBuilder<BbImagePickerController>.reactive(
//         viewModelBuilder: () => BbImagePickerController(this.postDetails),
//         builder: (context, controller, child) => Scaffold(
//             backgroundColor: white,
//             appBar: AppBar(
//               elevation: 0,
//               iconTheme: new IconThemeData(color: Colors.black),
//               leading: IconButton(
//                   icon: Icon(Icons.close, color: Colors.black),
//                   onPressed: () {
//                     if(controller.hasChangedAndNotSaved) {
//                       //alert
//                     } else {
//                       Navigator.of(context).pop();
//                     }
//                   }),
//               backgroundColor: white,
//               title: Text('Ajouter une image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
//               actions: [
//                 controller.imageFile != null  ? Center(
//                   child: controller.isUploading ? BBloader() : GestureDetector(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 10),
//                       child: Text('Valider', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 15),),
//                     ),
//                     onTap: () async {
//                       await controller.uploadImage(context);
//                     },
//                   ),
//                 ) : Container()
//               ],
//             ),
//             // extendBody: true,
//             body: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     controller.imageIsLoading ? BBloader() : Container(),
//                     (controller.imageIsLoading || controller.imageFile == null) ? Text('Aucune image selectionnée') : Container(
//                       color: bgUltraLight,
//                       child: Image.file(
//                         controller.imageFile,
//                         width: 300,
//                         height: 300,
//                         fit: controller.fitType,
//                       ),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       mainAxisSize: MainAxisSize.max,
//                       children: [
//                         IconButton(
//                           icon: Icon(
//                             controller.fitType == BoxFit.cover ? Icons.fit_screen : Icons.aspect_ratio_outlined,
//                             color: Colors.black54,
//                           ),
//                           onPressed: () {
//                            controller.changeFit();
//                         }),
//                         UIHelper.horizontalSpace(20),
//                         controller.fitType == BoxFit.cover ? GestureDetector(
//                           child: Container(
//                             decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.black38),
//                             padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
//                             child: Row(
//                               children: [
//                                 Icon(Icons.crop, color: white, size: 15,),
//                                 UIHelper.horizontalSpace(5),
//                                 Text('Recadrer', style: TextStyle(color: white, fontSize: 13),),
//                               ],
//                             ),
//                         ), onTap: () {
//                           controller.cropImage();
//                         }) : Container()
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }