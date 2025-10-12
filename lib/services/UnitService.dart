

class UnitService {

  convertSpeedForRunFromKMH($speed) {
    if($speed is String) {
      $speed = num.parse($speed);
    }
    if($speed == 0) {
      return "";
    }
    $speed = $speed/3.6; // = en m/s
    $speed = (1/$speed)/0.06; //en min / km
    return setReadableSpeedForRun($speed);
  }

  setReadableSpeedForRun($speed) {
    var minutes = $speed.floor();
    var secondes = (($speed - minutes)*60).round();
    if(secondes == 60) {
      minutes = minutes + 1;
      secondes = 0;
    }
    if(secondes < 10&&secondes > 0) {
      secondes = "0$secondes";
    }
    if (secondes == 0) {
      secondes = "00";
    }
    return "$minutes:$secondes";
  }
}