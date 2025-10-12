import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:elh/env.dart';
import 'package:elh/locator.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/AppException.dart';
import 'package:elh/services/ErrorMessageService.dart';

class BaseApiHelper {
  final String? baseApiUrl = environment['baseApiUrl'];
  final String? baseApiUrlPublic = environment['baseApiUrlPublic'];
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();

  Future<ApiResponse> get(String url, requestHeaders, { public = false }) async {
    var apiResponse;
    try {
      final response = await http.get(this.getFullURL(url, public: public), headers: requestHeaders);
      apiResponse = _returnResponse(response);
      if(apiResponse.status == 401) {
        try {
          if(json.decode(apiResponse.data)['message'] == "JWT Token not found"
              || json.decode(apiResponse.data)['message'] == "Invalid credentials.") {
            if (!url.contains("chat/has-messages") && !url.contains("load-last-messages")) {
              //_localAuthService.logoutUserLocaly();
            }
          }
        } catch(e) {}
      } else if(apiResponse.data is String && apiResponse.status == 403) {
        _errorMessageService.errorOnAPICall(message: apiResponse.data);
      } else if(apiResponse.status != 200) { //ou cas plus spé ??
        throw new ApiException(apiResponse);
      }
    } on SocketException {
      _errorMessageService.errorShoMessage("Veuillez vérifier votre connexion internet !", title: 'Aucune connexion');
      apiResponse = new ApiResponse(500, 'Aucune connexion internet !');
    }
    return apiResponse;
  }

  Future<ApiResponse> post(String url, requestHeaders, body, { public = false }) async {
    var apiResponse;
    try {
      final response = await http.post(this.getFullURL(url, public: public), headers: requestHeaders, body: body);
      apiResponse = _returnResponse(response);
    } on SocketException {
      _errorMessageService.errorShoMessage("Veuillez vérifier votre connexion internet !", title: 'Aucune connexion');
      apiResponse = new ApiResponse(500, 'Aucune connexion internet !');
    }
    return apiResponse;
  }

  Future<ApiResponse> getExternal(String url, requestHeaders) async {
    var apiResponse;
    try {
      final response = await http.get(Uri.parse(url), headers: requestHeaders);
      apiResponse = _returnResponse(response);
       if(apiResponse.status != 200) {
            throw new ApiException(apiResponse);
        }
    } on SocketException {
      _errorMessageService.errorShoMessage("Veuillez vérifier votre connexion internet !", title: 'Aucune connexion');
      apiResponse = new ApiResponse(500, 'Aucune connexion internet !');
    }
    return apiResponse;
  }

  Uri getFullURL(url, { public = false }) {
//    String extraParam = isProduction ? "" : "?XDEBUG_SESSION_START=PHPSTORM"; //pbs avec autres paramters
    if(public) {
      return Uri.parse(baseApiUrlPublic! + url);
    }
    return Uri.parse(baseApiUrl! + url);
  }

  ApiResponse _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return new ApiResponse(200, response.body);
      case 307:
        return new ApiResponse(200, null); //Redirect, used for in App link research !
      case 401:
        return new ApiResponse(401,  response.body);
      case 409:
        return new ApiResponse(409,  response.body); //already exist
      case 403:
        var message = "Accès non autorisé à la ressource !";
        try {
          var decodeBody = json.decode(response.body);
          if(decodeBody is String) {
            message = response.body;
          } else {
            message = decodeBody['message'] ?? "Une erreur s'est  produite : ${response.body.toString()}";
          }
        } on FormatException {
         //if AccesDednied body is HTML PAGE and canot be decoded !!
        }
        return new ApiResponse(403, message);
      case 404:
        return new ApiResponse(404, "Url non existante !");
      case 500:
        return new ApiResponse(500, response.body);
      case 400:
      default:
      return new ApiResponse(500, "Une erreur s'est  produite : ${response.statusCode}");
    }
  }

}