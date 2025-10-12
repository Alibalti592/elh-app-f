
getNullOrInt(value) {
  return value == null ? null : getNullOrNum(value).round();
}

getNullOrNum(value) {
  if(value != null && value is String) {
    if(value.length > 0) {
      value = value.replaceAll(',','.');
    }
  }
  return value == null ? null : num.parse(value);
}
