import 'dart:convert';
import 'dart:io';
// import 'package:heic_to_jpg/heic_to_jpg.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

class ImageService {
  static const MethodChannel _channel = const MethodChannel('heic_to_jpg');

  getBase64ImageFromPath(File imageFile) async {
    String imagePath  = imageFile.path;
    String extension = p.extension(imagePath).replaceAll('.', '');
    if (extension == 'heic') {
      imagePath = await convertHeicToJpeg(imagePath);
      imageFile = new File(imagePath);
      extension = 'jpeg';
    }
    String myme = 'png';
    if(extension == 'jpg' || extension == 'jpeg') {
      myme = 'jpeg';
    }
    return "data:image/"+myme+";base64,"+base64Encode(imageFile.readAsBytesSync());
  }



  /// Convert HEIC/HEIF Image to JPEG Image.
  /// Get [heicPath] path as an input and return [jpg] path.
  /// You can set [jpgPath] if you want to set the output file path.
  /// If you don't set it the output file path is made in cache directory of each platform.
  static Future<String> convertHeicToJpeg(String heicPath) async {
    final String jpg = await _channel.invokeMethod('convert', {"heicPath": heicPath});
    return jpg;
  }
}