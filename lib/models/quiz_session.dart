enum SessionStatus { active, paused, completed }

class QuizSession {
  QuizSession({required this.id, required this.userId, required this.questionIds, required this.startedAt, Map<String, int?> answers = const {}, this.currentIndex = 0, this.elapsedSeconds = 0, this.lastPausedAt, this.completedAt, this.status = SessionStatus.active}) : answers = Map<String, int?>.from(answers);
  final String id;
  final String userId;
  final List<String> questionIds;
  final DateTime startedAt;
  Map<String, int?> answers;
  int currentIndex;
  int elapsedSeconds;
  DateTime? lastPausedAt;
  DateTime? completedAt;
  SessionStatus status;

  int get unansweredCount => questionIds.where((id) => !answers.containsKey(id) || answers[id] == null).length;
  Map<String, dynamic> toJson() => {'id': id, 'userId': userId, 'questionIds': questionIds, 'startedAt': startedAt.toIso8601String(), 'answers': answers, 'currentIndex': currentIndex, 'elapsedSeconds': elapsedSeconds, 'lastPausedAt': lastPausedAt?.toIso8601String(), 'completedAt': completedAt?.toIso8601String(), 'status': status.name};
  factory QuizSession.fromJson(Map<String, dynamic> j) => QuizSession(
    id: j['id'] as String, userId: j['userId'] as String, questionIds: (j['questionIds'] as List).cast<String>(), startedAt: DateTime.parse(j['startedAt'] as String),
    answers: (j['answers'] as Map<String, dynamic>).map((k,v) => MapEntry(k, v as int?)), currentIndex: j['currentIndex'] as int, elapsedSeconds: j['elapsedSeconds'] as int,
    lastPausedAt: j['lastPausedAt'] == null ? null : DateTime.parse(j['lastPausedAt'] as String), completedAt: j['completedAt'] == null ? null : DateTime.parse(j['completedAt'] as String),
    status: SessionStatus.values.firstWhere((s) => s.name == j['status'], orElse: () => SessionStatus.paused));
}
