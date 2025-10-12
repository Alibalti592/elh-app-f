import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/locator.dart';
import 'package:elh/services/BaseApi/HandleApiReponseError.dart';

class ApiException implements Exception {
  final ApiResponse _apiResponse;
  final HandleApiResponseError _handleApiResponseError = locator<HandleApiResponseError>();

  ApiException(this._apiResponse) {
    _handleApiResponseError.onApiResponseError(this._apiResponse);
  }

  String toString() {
    return "Erreur ${_apiResponse.status}, Message : ${_apiResponse.data}";
  }
}