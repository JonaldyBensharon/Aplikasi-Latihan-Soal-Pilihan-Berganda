class QuizResult {
  const QuizResult({required this.sessionId, required this.userId, required this.correctCount, required this.totalQuestions, required this.durationSeconds, required this.completedAt});
  final String sessionId;
  final String userId;
  final int correctCount;
  final int totalQuestions;
  final int durationSeconds;
  final DateTime completedAt;
  double get percentage => totalQuestions == 0 ? 0 : correctCount * 100 / totalQuestions;
  Map<String, dynamic> toJson() => {'sessionId': sessionId, 'userId': userId, 'correctCount': correctCount, 'totalQuestions': totalQuestions, 'durationSeconds': durationSeconds, 'completedAt': completedAt.toIso8601String()};
  factory QuizResult.fromJson(Map<String, dynamic> j) => QuizResult(sessionId: j['sessionId'] as String, userId: j['userId'] as String, correctCount: j['correctCount'] as int, totalQuestions: j['totalQuestions'] as int, durationSeconds: j['durationSeconds'] as int, completedAt: DateTime.parse(j['completedAt'] as String));
}
