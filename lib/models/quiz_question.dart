class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.passage,
  });

  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String? passage;

  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'options': options,
        'correctIndex': correctIndex,
        'passage': passage,
      };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: json['id'] as String,
        prompt: json['prompt'] as String,
        options: (json['options'] as List).cast<String>(),
        correctIndex: json['correctIndex'] as int,
        passage: json['passage'] as String?,
      );
}
