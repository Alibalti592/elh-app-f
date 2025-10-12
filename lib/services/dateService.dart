import 'package:elh/services/Extension/DateWeekExtension.dart';

class DateService {

  DateTime getFirstDayOfMonth(DateTime currentDate) {
    return new DateTime(currentDate.year, currentDate.month, 1);
  }
  DateTime getLastDayOfMonth(DateTime currentDate) {
    return new DateTime(currentDate.year, currentDate.month + 1, 0);
  }

  DateTime getFirstDayOfWeek(currentDate) {
    int today = currentDate.weekday;
    // ISO week date weeks start on monday, so correct the day number
    var dayNr = (today + 6) % 7;
    var firstDayOffWeek =  currentDate.subtract(new Duration(days:(dayNr)));
    return this.setTimeNull(firstDayOffWeek);
  }

  DateTime getLastDayOfWeek(currentDate) {
    var monday = this.getFirstDayOfWeek(currentDate);
    return monday.add(new Duration(days:6)); //attention time = 0 0 0 soit début de journée ..
  }

  DateTime setTimeNull(DateTime dateTime) {
    return new DateTime(dateTime.year, dateTime.month, dateTime.day, 0, 0, 0);
  }

  int weekNumber(DateTime date) {
    return date.weekOfYear;
  }

  String getReadableDurationFromMinutes(timeInMinutes) {
    int hours = (timeInMinutes / 60).floor();
    int minutes = timeInMinutes - hours*60;
    String readMinutes = '$minutes';
    if(minutes == 0) {
      readMinutes = "00";
    } else if(minutes < 10 ) {
      readMinutes = "0$minutes";
    }
    return "${hours}h$readMinutes";
  }

  String hhmm(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
    // int hours = (timeInMinutes / 60).floor();
    // int minutes = timeInMinutes - hours*60;
    // String readMinutes = '$minutes';
    // if(minutes == 0) {
    //   readMinutes = "00";
    // } else if(minutes < 10 ) {
    //   readMinutes = "0$minutes";
    // }
    // return "$hours:$readMinutes";
  }

  String hhmmss(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}