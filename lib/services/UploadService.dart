import 'dart:convert';
import 'dart:io';
import 'package:mime_type/mime_type.dart';

class UploadService {

  String convertFileToBase64WithMimeType(File file) {
    List<int> fileBytes = file.readAsBytesSync();
    String? mimeType = mime(file.path);
    String base64Encoded = base64Encode(fileBytes);
    return "data:$mimeType;base64,$base64Encoded";
  }
}