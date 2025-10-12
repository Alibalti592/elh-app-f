class ParseService {

  static int toInt(intOrString) {
    if(intOrString is int) {
      return intOrString;
    } else {
      var parsed = int.tryParse(intOrString);
      if(parsed == null) {
        return 0;
      }
      return parsed;
    }
  }

}