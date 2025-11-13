import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class FileUploader extends StatefulWidget {
  @override
  _FileUploaderState createState() => _FileUploaderState();
}

class _FileUploaderState extends State<FileUploader> {
  String? fileUrl;
  bool isUploading = false;
  String? errorMessage;

  Future<void> pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );

    if (result == null || result.files.single.path == null) return;

    File file = File(result.files.single.path!);

    setState(() {
      isUploading = true;
      errorMessage = null;
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("https://test.muslim-connect.fr/elh-api/upload"),
    );

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var resBody = await response.stream.bytesToString();
        var data = jsonDecode(resBody);
        setState(() {
          fileUrl = data['fileUrl'];
        });
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = "Unauthorized: JWT token required.";
        });
      } else {
        setState(() {
          errorMessage = "Upload failed with status: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error uploading file: $e";
      });
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  Widget filePreview() {
    if (fileUrl == null) return SizedBox.shrink();

    if (fileUrl!.endsWith('.jpg') || fileUrl!.endsWith('.png')) {
      return Image.network(fileUrl!, height: 200);
    } else {
      return Text("File uploaded: $fileUrl");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: isUploading ? null : pickAndUploadFile,
          child: isUploading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text("Upload File"),
        ),
        SizedBox(height: 20),
        if (errorMessage != null)
          Text(errorMessage!, style: TextStyle(color: Colors.red)),
        filePreview(),
      ],
    );
  }
}
