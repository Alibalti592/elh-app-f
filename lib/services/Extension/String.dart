extension StringExtension on String {
  String capitalize() {
    return this
      .toLowerCase()
      .split(" ")
      .map((word) => word[0].toUpperCase() + word.substring(1, word.length))
      .join(" ");
  }
  String truncate({required int max, String suffix = '...'}) {
    return this.length < max
        ? this
        : '${this.substring(0, (max - suffix.length))}$suffix';
  }
}