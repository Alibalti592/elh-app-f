import 'dart:convert';
import 'package:app_install_date/app_install_date.dart';
import 'package:elh/locator.dart';
import 'package:elh/repository/UserDataRepository.dart';
import 'package:elh/services/BaseApi/ApiResponse.dart';
import 'package:elh/services/CacheDataService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_review/in_app_review.dart';

class AppReviewService {
  UserDataRepository _userDataRepository = locator<UserDataRepository>();
  CacheDataService cacheDataService = locator<CacheDataService>();
  final InAppReview inAppReview = InAppReview.instance;
  late SharedPreferences prefs;

  void askForReview() async {
    this.prefs = await SharedPreferences.getInstance();
    //check localy
    bool localAskReviewBlocked = await this.geLlocalAskReviewBlocked();
    if(localAskReviewBlocked) {
      return;
    }
    //wait 1 minute !
    Future.delayed(Duration(minutes: 1), () async {
      //check api
      this.prefs.setBool("lastAskReviewApp", true);
      ApiResponse apiResponse = await _userDataRepository.canAskUserAppReview();
      if (apiResponse.status == 200) {
        if(json.decode(apiResponse.data)['canAskUserAppReview'])  {
          if (await inAppReview.isAvailable()) {
            inAppReview.requestReview();
          }
        } else if(json.decode(apiResponse.data)['definitelyBlocked']) {
          this.prefs.setBool("localAskReviewBlocked", true);
        }
      }
    });
  }

  //mark as blocked or last ask iDO api less 3 days
  Future<bool> geLlocalAskReviewBlocked() async {
    //APP install less 2 weeks => blocked => return true
    try {
      DateTime twoWeeksAgo = DateTime.now();
      twoWeeksAgo = twoWeeksAgo.subtract(new Duration(days:(15)));
      DateTime installDate = await AppInstallDate().installDate;
      if(twoWeeksAgo.compareTo(installDate) < 0) {
        return true;
      }
    } catch (e) {}
    if(this.prefs.containsKey('localAskReviewBlocked') && this.prefs.getBool('localAskReviewBlocked') == true)  {
      return true;
    }
    return await cacheDataService.dataInCacheAndValid('lastAskReviewApp', 10); //fait une query max tous les 10 jours
  }

}