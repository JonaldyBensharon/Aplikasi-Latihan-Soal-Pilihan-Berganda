// Format waktu menjadi jam, menit, dan detik

String formatDuration(int totalSeconds) {
  final h = totalSeconds ~/ 3600;
  final m = (totalSeconds % 3600) ~/ 60;
  final s = totalSeconds % 60;
  return '${h.toString().padLeft(2, '0')}:'
      '${m.toString().padLeft(2, '0')}:'
      '${s.toString().padLeft(2, '0')}';
}

String formatPercentage(double percentage) {
  final rounded = double.parse(percentage.toStringAsFixed(1));
  return '${rounded == rounded.roundToDouble() ? rounded.toInt() : rounded}%';
}