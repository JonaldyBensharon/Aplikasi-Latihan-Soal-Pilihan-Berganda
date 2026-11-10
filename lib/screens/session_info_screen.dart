import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import '../theme/responsive.dart';
import '../utils/formatters.dart';
import '../widgets/exercise_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/session_scaffold.dart';
import 'session_execution_screen.dart';

class SessionInfoScreen extends StatelessWidget {
  const SessionInfoScreen({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final s = context.rs;
        final user = controller.currentUser;
        final averageDuration = controller.currentUserAverageDurationSeconds;
        final averagePercentage = controller.currentUserAveragePercentage;
        final latest = controller.currentUserLatestResult;

        return SessionScaffold(
          controller: controller,
          children: [
            SessionGreeting(
              title: 'Halo, ${user?.displayName ?? ''}!',
              message:
                  'Silakan tekan tombol Mulai untuk melaksanakan sesi latihan.',
            ),

            // Area penampilan data latihan
            ExerciseCard(
              footer: '10 Soal',
              children: [
                CardSection(
                  title: 'Riwayat Pembelajaran',
                  children: [
                    InfoRow(
                      label: 'Durasi rata-rata',
                      value: averageDuration == null
                          ? '-'
                          : formatDuration(averageDuration),
                    ),
                    InfoRow(
                      label: 'Rata-rata benar',
                      value: averagePercentage == null
                          ? '-'
                          : formatPercentage(averagePercentage),
                    ),
                    InfoRow(
                      label: 'Waktu latihan terakhir',
                      value: latest == null
                          ? '-'
                          : _formatRelativeDate(latest.completedAt),
                    ),
                  ],
                ),
                SizedBox(height: 20 * s),
                RecordSection(
                  highestAccuracy: controller.currentUserHighestAccuracyResult,
                  fastestResult: controller.currentUserFastestResult,
                ),
              ],
            ),
            SizedBox(height: 30 * s),

            // Tombol Mulai selalu membuat sesi baru
            PrimaryButton(
              label: 'Mulai',
              onPressed: () async {
                final ready = await controller.startNewSession();
                if (!ready || !context.mounted) return;
                await Navigator.of(context).pushReplacement<void, void>(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        SessionExecutionScreen(controller: controller),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

String _formatRelativeDate(DateTime dateTime) {
  final elapsed = DateTime.now().difference(dateTime);
  if (elapsed.inDays >= 1) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }
  if (elapsed.inHours >= 1) return '${elapsed.inHours} jam lalu';
  if (elapsed.inMinutes >= 1) return '${elapsed.inMinutes} menit lalu';
  return '${elapsed.inSeconds.clamp(0, 59)} detik lalu';
}