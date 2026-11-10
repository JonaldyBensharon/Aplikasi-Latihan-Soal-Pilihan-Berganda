import 'package:flutter/material.dart';

import '../models/quiz_session.dart';
import '../state/app_controller.dart';
import '../theme/responsive.dart';
import '../utils/formatters.dart';
import '../widgets/exercise_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/session_scaffold.dart';
import 'session_execution_screen.dart';

// Ringkasan sesi yang dihentikan sementara sebelum pengguna melanjutkannya.
class SessionResumeScreen extends StatelessWidget {
  const SessionResumeScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final s = context.rs;
        final user = controller.currentUser;
        final activeSession = controller.currentSession;
        final session = controller.pausedSession ??
            (activeSession?.status == SessionStatus.active
                ? activeSession
                : null);

        return SessionScaffold(
          controller: controller,
          children: [
            SessionGreeting(
              title: 'Halo, ${user?.displayName ?? ''}!',
              message:
                  'Silakan tekan tombol Lanjut untuk melanjutkan sesi latihan yang terhenti.',
            ),

            // Penampilan data sesi terhenti
            ExerciseCard(
              footer: session == null
                  ? '-'
                  : '${session.questionIds.length - session.unansweredCount}/'
                      '${session.questionIds.length} soal',
              children: [
                CardSection(
                  title: 'Riwayat Pembelajaran',
                  children: [
                    InfoRow(
                      label: 'Durasi pengerjaan',
                      value: session == null
                          ? '-'
                          : formatDuration(session.elapsedSeconds),
                    ),
                    InfoRow(
                      label: 'Waktu terakhir terhenti',
                      value: session?.lastPausedAt == null
                          ? '-'
                          : _formatPausedAt(session!.lastPausedAt!),
                    ),
                  ],
                ),

                // Menyamakan tinggi dengan layar info (yang memiliki satu baris lebih banyak)
                SizedBox(height: 44 * s),
                RecordSection(
                  highestAccuracy: controller.currentUserHighestAccuracyResult,
                  fastestResult: controller.currentUserFastestResult,
                ),
              ],
            ),
            SizedBox(height: 24 * s),
            PrimaryButton(
              label: 'Lanjut',
              onPressed: controller.pausedSession == null
                  ? null
                  : () => _continueSession(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> _continueSession(BuildContext context) async {
    // Periksa kembali state sebelum melanjutkan agar sesi tidak dibuat ulang.
    if (controller.pausedSession == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Sesi terhenti sedang tidak tersedia.')),
        );
      return;
    }

    await controller.resumeSession();
    if (!context.mounted || controller.currentSession == null) return;
    await Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) => SessionExecutionScreen(controller: controller),
      ),
    );
  }
}

String _formatPausedAt(DateTime pausedAt) {
  final now = DateTime.now();
  final localTime = pausedAt.toLocal();
  final difference = now.difference(localTime);
  if (difference.isNegative) return 'Baru saja';
  if (difference.inDays >= 1) {
    return '${localTime.day.toString().padLeft(2, '0')}/'
        '${localTime.month.toString().padLeft(2, '0')}/'
        '${localTime.year}';
  }
  if (difference.inHours >= 1) return '${difference.inHours} jam lalu';
  if (difference.inMinutes >= 1) return '${difference.inMinutes} menit lalu';
  return '${difference.inSeconds} detik lalu';
}