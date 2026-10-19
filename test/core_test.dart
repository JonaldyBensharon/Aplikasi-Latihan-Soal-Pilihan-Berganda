import 'package:flutter_test/flutter_test.dart';
import 'package:drill_exe/data/question_bank.dart';
import 'package:drill_exe/models/quiz_result.dart';

void main() {
  group('Bank soal', () {
    test('berisi tepat 10 soal dengan ID unik dan empat pilihan', () {
      expect(questionBank, hasLength(10));
      expect(questionBank.map((question) => question.id).toSet(), hasLength(10));
      for (final question in questionBank) {
        expect(question.options, hasLength(4));
        expect(question.correctIndex, inInclusiveRange(0, 3));
      }
    });

    test('soal dengan bacaan memiliki teks bacaan yang tidak kosong', () {
      final questionsWithPassage = questionBank.where(
        (question) => question.passage != null,
      );
      expect(questionsWithPassage, hasLength(3));
      expect(
        questionsWithPassage.every((question) => question.passage!.trim().isNotEmpty),
        isTrue,
      );
    });
  });

  test('persentase hasil menggunakan seluruh soal sebagai penyebut', () {
    final result = QuizResult(
      sessionId: 's',
      userId: 'u',
      correctCount: 7,
      totalQuestions: 10,
      durationSeconds: 45,
      completedAt: DateTime.utc(2026, 1, 1),
    );
    expect(result.percentage, 70);
  });
}
