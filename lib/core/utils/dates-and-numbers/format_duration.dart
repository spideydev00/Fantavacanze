// Metodo per formattare il tempo in mm:ss
String formatDuration(Duration d) {
  //90 se
  String minutes = d.inMinutes.remainder(60).toString();
  String seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');

  return "$minutes:$seconds";
}
