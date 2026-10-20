import 'package:flutter/material.dart';

import '../models/quiz_result.dart';
import '../models/quiz_session.dart';
import '../state/app_controller.dart';
import '../widgets/leaderboard_button.dart';
import '../widgets/theme_toggle_button.dart';
import 'session_execution_screen.dart';

// Ringkasan sesi yang dihentikan sementara sebelum pengguna melanjutkannya.
class SessionResumeScreen extends StatelessWidget {
  const SessionResumeScreen({super.key, required this.controller});

  final AppController controller;
  static const double _wideBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        final user = controller.currentUser;
        final highestAccuracy = controller.currentUserHighestAccuracyResult;
        final fastestResult = controller.currentUserFastestResult;

        final activeSession = controller.currentSession;
        final session =
            controller.pausedSession ??
            (activeSession?.status == SessionStatus.active
                ? activeSession
                : null);

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= _wideBreakpoint;
            final scale = isWide ? 1.2 : 1.0;

            return Scaffold(

              // Area kepala layar
              appBar: AppBar(
                toolbarHeight: 55,
                backgroundColor: colors.surface,
                surfaceTintColor: Colors.transparent,
                elevation: 3,
                scrolledUnderElevation: 3,
                shadowColor: Colors.black.withValues(
                  alpha: isDark ? 0.4 : 0.15,
                ),
                leading: IconButton(
                  tooltip: 'Kembali ke Beranda',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 28),
                ),
                centerTitle: true,
                title: Text(
                  'Sesi Latihan',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 24 * scale,
                    color: colors.onSurface,
                  ),
                ),
              ),

              // Area isi
              body: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          isWide ? 32 : 22,
                          15,
                          isWide ? 32 : 22,
                          15,
                        ),

                        // Area salam dan petunjuk
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isWide ? 600 : 520,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Halo, ${user?.displayName ?? ''}!',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16 * scale,
                                    color: colors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Silakan tekan tombol Lanjut untuk melanjutkan sesi latihan yang terhenti.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                    height: 1.4,
                                    fontSize: 12 * scale,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // penampilan data sesi terhenti
                                _PausedSessionCard(
                                  scale: scale,
                                  session: session,
                                  highestAccuracy: highestAccuracy,
                                  fastestResult: fastestResult,
                                ),
                                const SizedBox(height: 24),
                                Center(
                                  child: SizedBox(
                                    width: 135,
                                    height: 40,
                                    child: FilledButton(
                                      onPressed:
                                          controller.pausedSession == null
                                          ? null
                                          : () => _continueSession(context),
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Lanjut',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isWide ? 32 : 25,
                        8,
                        isWide ? 32 : 25,
                        isWide ? 28 : 35,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Tombol peringkat
                          LeaderboardButton(
                            compact: true,
                            controller: controller,
                          ),

                          // Tombol pengaturan tema
                          ThemeToggleButton(
                            controller: controller,
                            compact: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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

class _PausedSessionCard extends StatelessWidget {
  const _PausedSessionCard({
    required this.scale,
    required this.session,
    required this.highestAccuracy,
    required this.fastestResult,
  });

  final double scale;
  final QuizSession? session;
  final QuizResult? highestAccuracy;
  final QuizResult? fastestResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final sectionStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 14 * scale,
      color: colors.onSurface,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        16 * scale,
        18 * scale,
        14 * scale,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // Nama latihan
          Text(
            'Bahasa Inggris',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15 * scale,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 5),

          // Deskripsi latihan
          Text(
            'Kosakata, tata bahasa, dan penyusunan kalimat dalam bahasa Inggris.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 12 * scale,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Riwayat pembelajaran
          Text('Riwayat Pembelajaran', style: sectionStyle),
          const SizedBox(height: 5),
          _ResumeInfoRow(
            scale: scale,
            label: 'Durasi pengerjaan',
            value: session == null
                ? '-'
                : _formatDuration(session!.elapsedSeconds),
          ),
          const SizedBox(height: 8),
          _ResumeInfoRow(
            scale: scale,
            label: 'Waktu terakhir terhenti',
            value: session?.lastPausedAt == null
                ? '-'
                : _formatPausedAt(session!.lastPausedAt!),
          ),

          // Memastikan jarak konsisten dengan layar info
          SizedBox(height: (28 + 12 * scale)),
          Text('Rekor Belajar', style: sectionStyle),
          const SizedBox(height: 5),
          _ResumeRecordRow(
            scale: scale,
            label: 'Tingkat kebenaran tertinggi',
            percentage: highestAccuracy == null
                ? '-'
                : _formatPercentage(highestAccuracy!.percentage),
            duration: highestAccuracy == null
                ? '-'
                : _formatDuration(highestAccuracy!.durationSeconds),
          ),
          const SizedBox(height: 15),
          _ResumeRecordRow(
            scale: scale,
            label: 'Durasi pengerjaan tercepat',
            percentage: fastestResult == null
                ? '-'
                : _formatPercentage(fastestResult!.percentage),
            duration: fastestResult == null
                ? '-'
                : _formatDuration(fastestResult!.durationSeconds),
          ),
          const SizedBox(height: 25),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              session == null
                  ? '-'
                  : '${session!.questionIds.length - session!.unansweredCount}/'
                        '${session!.questionIds.length} soal',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 11.5 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumeInfoRow extends StatelessWidget {
  const _ResumeInfoRow({
    required this.scale,
    required this.label,
    required this.value,
  });

  final double scale;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 12 * scale,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurface,
              fontSize: 12 * scale,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResumeRecordRow extends StatelessWidget {
  const _ResumeRecordRow({
    required this.scale,
    required this.label,
    required this.percentage,
    required this.duration,
  });

  final double scale;
  final String label;
  final String percentage;
  final String duration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final valueStyle = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurface,
      fontSize: 12 * scale,
      height: 1.35,
      fontWeight: FontWeight.w500,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 12 * scale,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                percentage,
                textAlign: TextAlign.left,
                style: valueStyle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                duration,
                textAlign: TextAlign.right,
                style: valueStyle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String _formatDuration(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final remainingSeconds = seconds % 60;
  return '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}:'
      '${remainingSeconds.toString().padLeft(2, '0')}';
}

String _formatPercentage(double percentage) {
  final rounded = double.parse(percentage.toStringAsFixed(1));
  return '${rounded == rounded.roundToDouble() ? rounded.toInt() : rounded}%';
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
