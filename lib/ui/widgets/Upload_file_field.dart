// import 'dart:io';
// import 'package:elh/ui/views/modules/Dette/AddObligationController.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class UploadFileWidget extends StatefulWidget {
//   final AddObligationController controller; // Pass the controller

//   const UploadFileWidget({Key? key, required this.controller})
//       : super(key: key);

//   @override
//   _UploadFileWidgetState createState() => _UploadFileWidgetState();
// }

// class _UploadFileWidgetState extends State<UploadFileWidget> {
//   File? _selectedFile;
//   bool _isUploading = false;
//   String? _statusMessage;

//   final ImagePicker _picker = ImagePicker();
//   Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('jwt_token');
//   }

//   // Pick image or file
//   Future<void> _pickFile(ImageSource source) async {
//     final pickedFile = await _picker.pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedFile = File(pickedFile.path);
//         _statusMessage = null;
//       });
//     }
//     Navigator.pop(context);
//   }

//   // Show picker options
//   void _showPickerOptions() {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) => SafeArea(
//         child: Wrap(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text("Prendre une photo"),
//               onTap: () => _pickFile(ImageSource.camera),
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text("Choisir depuis la galerie"),
//               onTap: () => _pickFile(ImageSource.gallery),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Upload file to Symfony API
//   Future<void> _uploadFile() async {
//     final token = await widget.controller.getToken(); // get stored token
//     print(token);
//     if (token == null || token.isEmpty) {
//       setState(() {
//         _statusMessage = "Vous devez être connecté pour uploader un fichier.";
//       });
//       return;
//     }

//     if (_selectedFile == null) return;

//     setState(() {
//       _isUploading = true;
//       _statusMessage = null;
//     });

//     try {
//       String url = "http://10.0.2.2:8000/elh-api/upload";

//       FormData formData = FormData.fromMap({
//         "file": await MultipartFile.fromFile(
//           _selectedFile!.path,
//           filename: _selectedFile!.path.split('/').last,
//         ),
//       });

//       final dio = Dio();

//       final response = await dio.post(
//         url,
//         data: formData,
//         options: Options(
//           headers: {
//             "Authorization": "Bearer $token",
//             "Content-Type": "multipart/form-data",
//           },
//         ),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _statusMessage = "Upload réussi !";
//         });
//       } else {
//         setState(() {
//           _statusMessage =
//               "Échec de l'upload : ${response.data['error'] ?? 'Unknown error'}";
//         });
//       }
//     } on DioError catch (e) {
//       // Catch Dio-specific exceptions
//       String message = "Erreur lors de l'upload";
//       if (e.response != null) {
//         message += ": ${e.response?.statusCode} ${e.response?.statusMessage}";
//       } else {
//         message += ": ${e.message}";
//       }
//       setState(() {
//         _statusMessage = message;
//       });
//     } catch (e) {
//       setState(() {
//         _statusMessage = "Erreur inattendue: $e";
//       });
//     } finally {
//       setState(() {
//         _isUploading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         GestureDetector(
//           onTap: _showPickerOptions,
//           child: Container(
//             height: 60,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               border: Border.all(color: Colors.grey.shade400),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Center(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.attach_file, color: Colors.grey),
//                   const SizedBox(width: 8),
//                   Text(
//                     _selectedFile != null
//                         ? _selectedFile!.path.split('/').last
//                         : "Choisir un fichier",
//                     style: const TextStyle(color: Colors.black87, fontSize: 16),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 15),
//         ElevatedButton(
//           onPressed: _isUploading ? null : _uploadFile,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.green,
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           ),
//           child: _isUploading
//               ? const SizedBox(
//                   height: 20,
//                   width: 20,
//                   child: CircularProgressIndicator(
//                       color: Colors.white, strokeWidth: 2),
//                 )
//               : const Text("Upload",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         ),
//         if (_statusMessage != null) ...[
//           const SizedBox(height: 15),
//           Text(
//             _statusMessage!,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: _statusMessage!.contains("réussi")
//                   ? Colors.green
//                   : Colors.red,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ]
//       ],
//     );
//   }
// }
import 'dart:io';
import 'package:elh/common/theme.dart';
import 'package:elh/ui/views/modules/Dette/AddObligationController.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadFileWidget extends StatefulWidget {
  final AddObligationController controller;
  final Function(String fileUrl)? onFileUploaded;

  const UploadFileWidget({
    Key? key,
    required this.controller,
    this.onFileUploaded,
  }) : super(key: key);

  @override
  _UploadFileWidgetState createState() => _UploadFileWidgetState();
}

class _UploadFileWidgetState extends State<UploadFileWidget> {
  File? _selectedFile;
  String? _uploadedFileUrl;

  final ImagePicker _picker = ImagePicker();

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _pickAndUploadFile(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800, // scale down
        imageQuality: 70);
    if (pickedFile == null) return;

    widget.controller.setFile(pickedFile.path);
    print(pickedFile.path);

    setState(() {
      _selectedFile = File(pickedFile.path);
    });
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Prendre une photo"),
              onTap: () {
                Navigator.pop(sheetCtx); // pop ONLY the bottom sheet
                _pickAndUploadFile(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choisir depuis la galerie"),
              onTap: () {
                Navigator.pop(sheetCtx); // pop ONLY the bottom sheet
                _pickAndUploadFile(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteFile() {
    setState(() {
      _selectedFile = null;
      _uploadedFileUrl = null;
    });
    widget.controller.setFile(null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fichier supprimé.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _showPickerOptions,
          icon: const Icon(Icons.attach_file, color: Colors.white),
          label: Text(
            _selectedFile != null
                ? "Changer le fichier"
                : "Attacher une preuve",
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        if (_selectedFile != null) ...[
          const SizedBox(height: 12),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _selectedFile != null
                    ? Container(
                        width: double.infinity, // adapt width
                        constraints: const BoxConstraints(
                          maxHeight: 300, // limit height to avoid white screen
                        ),
                        child: Image.file(
                          _selectedFile!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: _deleteFile,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(6),
                    child:
                        const Icon(Icons.delete, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
