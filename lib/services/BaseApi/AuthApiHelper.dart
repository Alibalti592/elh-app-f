import 'package:elh/locator.dart';
import 'package:elh/services/AuthenticationService.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/BaseApi/BaseApiHelper.dart';

class AuthApiHelper {
  final BaseApiHelper _baseApiHelper = locator<BaseApiHelper>();
  final AuthenticationService _authenticationService = locator<AuthenticationService>();

  getUserToken() async {
    String token = await _authenticationService.getUserToken();
    return token;
  }

  Future<ApiResponse> get(String url) async {
    String token = await this.getUserToken();
    Map<String, String> requestHeaders = { 'Content-type': 'application/json', 'Authorization': "Bearer $token" };
    return _baseApiHelper.get(url, requestHeaders);
  }

  Future<ApiResponse> post(String url, body, {type= 'json'}) async {
    String token = await this.getUserToken();
    Map<String, String> requestHeaders = { 'Content-type': 'application/$type', 'Authorization': "Bearer $token" };
    return _baseApiHelper.post(url, requestHeaders, body);
  }

}