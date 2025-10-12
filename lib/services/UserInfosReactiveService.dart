import 'dart:convert';

import 'package:elh/locator.dart';
import 'package:elh/models/userInfos.dart';
import 'package:elh/repository/UserRepository.dart';
import 'package:elh/services/AuthenticationService.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/CacheDataService.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

class UserInfoReactiveService with ReactiveServiceMixin {
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final CacheDataService _cacheDataService = locator<CacheDataService>();
  ErrorMessageService _errorMessageService = locator<ErrorMessageService>();
  UserRepository _userRepository = locator<UserRepository>();
  UserInfos? userInfos;
  // UserInfoReactiveService() {}

  getUserToken() async {
    String token = await _authenticationService.getUserToken();
    return token;
  }

  /*
   * Est utilisé comme cache car on ne fait le call qu'une seule fois !
   */
  Future getUserInfos({cache = true}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool cacheDataValid =
        await _cacheDataService.dataInCacheAndValid('userInfos', 1);
    bool isInitialised = false;
    if (cacheDataValid && cache) {
      userInfos = userInfosFromJson(prefs.getString('userInfos')!);
      if (userInfos!.socialProfileSlug!.length != 0) {
        //pbs de version
        isInitialised = true;
      }
    }
    if (!isInitialised) {
      var userToken = await getUserToken();
      ApiResponse apiResponse = await _userRepository.getUserInfos(userToken);
      if (apiResponse.status == 200) {
        userInfos = userInfosFromJson(apiResponse.data);
        prefs.setString('userInfos', json.encode(userInfos));
      } else {
        _errorMessageService.errorOnAPICall();
      }
    }
    return userInfos;
  }

  resetUserInfos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userInfos');
  }
}
