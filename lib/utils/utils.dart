class Utils {
  static String secondsToMinutes(int secs) {
    var minutes = secs / 60;
    var seconds = secs % 60;
    return '${minutes.toInt().toString().padLeft(1, "0")}:${seconds.toString().padLeft(2, "0")}';
  }
}
