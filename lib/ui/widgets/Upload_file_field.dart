import 'dart:io';
import 'package:elh/common/theme.dart';
import 'package:elh/ui/views/modules/Dette/AddObligationController.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
          icon: const Icon(Icons.attach_file,
              color: Color.fromARGB(255, 255, 191, 0)),
          label: Text(
            _selectedFile != null
                ? "Changer le fichier"
                : "Attacher une preuve",
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 191, 0)),
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
