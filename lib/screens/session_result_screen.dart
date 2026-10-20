import 'package:flutter/material.dart';

import '../models/quiz_result.dart';
import '../state/app_controller.dart';
import '../widgets/leaderboard_button.dart';
import '../widgets/theme_toggle_button.dart';
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
        final completedSessions = controller.sessions
            .where((session) => session.id == result.sessionId)
            .toList();
        final answeredQuestionCount = completedSessions.isEmpty
            ? 0
            : completedSessions.first.questionIds
                .where((id) => completedSessions.first.answers[id] != null)
                .length;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= _wideBreakpoint;
            final scale = isWide ? 1.2 : 1.0;

            return Scaffold(
              appBar: AppBar(
                toolbarHeight: 55,
                backgroundColor: colors.surface,
                surfaceTintColor: Colors.transparent,
                elevation: 3,
                scrolledUnderElevation: 3,
                shadowColor: Colors.black.withValues(
                  alpha: isDark ? 0.4 : 0.15,
                ),
                automaticallyImplyLeading: false,
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
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isWide ? 600 : 520,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Selamat, ${user?.displayName ?? ''}!',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16 * scale,
                                    color: colors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sesi latihan sudah selesai! Terima kasih telah menggunakan aplikasi ini.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                    height: 1.4,
                                    fontSize: 12 * scale,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _ResultInfoCard(
                                  scale: scale,
                                  result: result,
                                  highestAccuracy: highestAccuracy,
                                  fastestResult: fastestResult,
                                  answeredQuestionCount: answeredQuestionCount,
                                ),
                                const SizedBox(height: 14),
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
                                          minimumSize: const Size.fromHeight(40),
                                          foregroundColor: colors.onSurface,
                                          backgroundColor: colors.surface,
                                          side: BorderSide(
                                            color: theme.dividerColor,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Text(
                                          'Periksa',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () {
                                          Navigator.of(context).pushReplacement<void, void>(
                                            MaterialPageRoute<void>(
                                              builder: (_) => SessionInfoScreen(
                                                controller: controller,
                                              ),
                                            ),
                                          );
                                        },
                                        style: FilledButton.styleFrom(
                                          minimumSize: const Size.fromHeight(40),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Text(
                                          'Kembali',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
                          // Tombol Peringkat
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
}

class _ResultInfoCard extends StatelessWidget {
  const _ResultInfoCard({
    required this.scale,
    required this.result,
    required this.highestAccuracy,
    required this.fastestResult,
    required this.answeredQuestionCount,
  });

  final double scale;
  final QuizResult result;
  final QuizResult? highestAccuracy;
  final QuizResult? fastestResult;
  final int answeredQuestionCount;

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

          // Riwayat pembelajaran
          const SizedBox(height: 20),
          Text('Riwayat Pembelajaran', style: sectionStyle),
          const SizedBox(height: 5),
          _ResultRow(
            scale: scale,
            label: 'Durasi pengerjaan',
            value: _formatDuration(result.durationSeconds),
          ),
          const SizedBox(height: 8),
          _ResultRow(
            scale: scale,
            label: 'Persentase jawaban benar',
            value: _formatPercentage(result.percentage),
          ),

          // Memastikan jarak konsisten dengan layar info
          SizedBox(height: (28 + 12 * scale)),

          // Rekor belajar
          Text('Rekor Belajar', style: sectionStyle),
          const SizedBox(height: 5),
          _RecordRow(
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
          _RecordRow(
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
              '$answeredQuestionCount/${result.totalQuestions} soal',
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

class _ResultRow extends StatelessWidget {
  const _ResultRow({
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

class _RecordRow extends StatelessWidget {
  const _RecordRow({
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
            Expanded(child: Text(percentage, style: valueStyle)),
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

String _formatDuration(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  return '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

String _formatPercentage(double percentage) {
  final rounded = double.parse(percentage.toStringAsFixed(1));
  return '${rounded == rounded.roundToDouble() ? rounded.toInt() : rounded}%';
}
