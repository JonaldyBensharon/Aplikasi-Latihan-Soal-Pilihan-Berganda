import 'package:flutter/material.dart';

import '../models/quiz_result.dart';
import '../state/app_controller.dart';
import '../theme/responsive.dart';
import '../utils/formatters.dart';
import '../widgets/exercise_card.dart';
import '../widgets/session_scaffold.dart';
import 'session_info_screen.dart';
import 'session_inspection_screen.dart';

// Ringkasan hasil dari sesi latihan yang baru saja diselesaikan.
class SessionResultScreen extends StatelessWidget {
  const SessionResultScreen({
    super.key,
    required this.controller,
    required this.result,
  });

  final AppController controller;
  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final s = context.rs;
        final user = controller.currentUser;

        final completed = controller.sessions
            .where((session) => session.id == result.sessionId)
            .toList();
        final answeredCount = completed.isEmpty
            ? 0
            : completed.first.questionIds
                .where((id) => completed.first.answers[id] != null)
                .length;

        return SessionScaffold(
          controller: controller,
          showBack: false,
          children: [
            SessionGreeting(
              title: 'Selamat, ${user?.displayName ?? ''}!',
              message:
                  'Sesi latihan sudah selesai! Terima kasih telah menggunakan aplikasi ini.',
            ),
            ExerciseCard(
              footer: '$answeredCount/${result.totalQuestions} soal',
              children: [
                CardSection(
                  title: 'Riwayat Pembelajaran',
                  children: [
                    InfoRow(
                      label: 'Durasi pengerjaan',
                      value: formatDuration(result.durationSeconds),
                    ),
                    InfoRow(
                      label: 'Persentase jawaban benar',
                      value: formatPercentage(result.percentage),
                    ),
                  ],
                ),

                // Menyamakan tinggi dengan layar info
                SizedBox(height: 44 * s),
                RecordSection(
                  highestAccuracy: controller.currentUserHighestAccuracyResult,
                  fastestResult: controller.currentUserFastestResult,
                ),
              ],
            ),
            SizedBox(height: 14 * s),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => SessionInspectionScreen(
                            controller: controller,
                            result: result,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.fromHeight(40 * s),
                      foregroundColor: colors.onSurface,
                      backgroundColor: colors.surface,
                      side: BorderSide(color: theme.dividerColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10 * s),
                      ),
                    ),
                    child: const Text(
                      'Periksa',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement<void, void>(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              SessionInfoScreen(controller: controller),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: Size.fromHeight(40 * s),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10 * s),
                      ),
                    ),
                    child: const Text(
                      'Kembali',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}