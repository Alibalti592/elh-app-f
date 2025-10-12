import 'package:shared_preferences/shared_preferences.dart';

class CacheDataService {

  dataInCacheAndValid(key, nbDays) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if(!prefs.containsKey(key)) {
        return false;
      }
      //save en shared preferance un timestamp et checker le timestamp par rappport à la limite souhaitée
      var yesterday = DateTime.now().subtract(Duration(days: nbDays));
      int yesterdayTimestamp = yesterday.millisecondsSinceEpoch;
      if(!prefs.containsKey("${key}validation")) {
        prefs.setInt("${key}validation", DateTime.now().millisecondsSinceEpoch);
        return false;
      } else {
        int? lastValidationLimit = prefs.getInt("${key}validation");
        if(lastValidationLimit != null) {
          if((lastValidationLimit - yesterdayTimestamp) <= 0) {
            prefs.setInt("${key}validation", DateTime.now().millisecondsSinceEpoch);
            return false;
          }
        }
      }
      return true;
    } catch(e) {
      return false;
    }
  }

  //call it from start app ?!
  // checkIsTodayVisit() async {
  //   Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  //
  //   SharedPreferences preferences = await _prefs;
  //   String lastVisitDate = preferences.get("mDateKey");
  //
  //   String toDayDate = DateTime.now().day.toString(); // Here is you just get only date not Time.
  //
  //   if (toDayDate == lastVisitDate) {
  //     // this is the user same day visit again and again
  //
  //   } else {
  //     // this is the user first time visit
  //     preferences.setString("mDateKey", toDayDate);
  //   }
  // }

}