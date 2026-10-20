import 'package:flutter/material.dart';

import '../models/quiz_result.dart';
import 'session_execution_screen.dart';
import '../state/app_controller.dart';
import '../widgets/leaderboard_button.dart';
import '../widgets/theme_toggle_button.dart';

class SessionInfoScreen extends StatelessWidget {
  const SessionInfoScreen({super.key, required this.controller});
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
        final latestResult = controller.currentUserLatestResult;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= _wideBreakpoint;

            // Pengaturan skala teks berdasarkan ukuran layar
            final scale = isWide ? 1.2 : 1.0;

            return Scaffold(

              // Area judul layar
              appBar: AppBar(
                toolbarHeight: 55,
                backgroundColor: colors.surface,
                surfaceTintColor: Colors.transparent,
                elevation: 3,
                scrolledUnderElevation: 3,
                shadowColor: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
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

              // Area isi layar
              body: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Expanded(

                      // Pengaturan padding salam pembuka
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

                            // Salam pembuka dan instruksi
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
                                  'Silakan tekan tombol Mulai untuk melaksanakan sesi latihan.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                    height: 1.4,
                                    fontSize: 12 * scale,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Area penampilan data latihan
                                _TrainingInfoCard(
                                  scale: scale,
                                  averageDuration:
                                      controller.currentUserAverageDurationSeconds,
                                  averagePercentage:
                                      controller.currentUserAveragePercentage,
                                  latestCompletedAt: latestResult?.completedAt,
                                  highestAccuracy: highestAccuracy,
                                  fastestResult: fastestResult,
                                ),
                                const SizedBox(height: 30),


                                // Area Tombol Mulai
                                Center(
                                  child: SizedBox(
                                    width: 135,
                                    height: 40,
                                    child: FilledButton(
                                      onPressed: () async {
                                        // Tombol Mulai selalu membuat sesi baru
                                        final ready = await controller.startNewSession();
                                        if (!ready || !context.mounted) return;
                                        await Navigator.of(context).pushReplacement<void, void>(
                                          MaterialPageRoute<void>(
                                            builder: (_) => SessionExecutionScreen(controller: controller),
                                          ),
                                        );
                                      },
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        'Mulai',
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
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
                    

                    // Area bawah untuk bagian tombol
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
                          LeaderboardButton(
                            compact: true,
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Layar peringkat akan dibuat pada tahap berikutnya.',
                                    ),
                                  ),
                                );
                            },
                          ),
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

class _TrainingInfoCard extends StatelessWidget {
  const _TrainingInfoCard({
    required this.scale,
    required this.averageDuration,
    required this.averagePercentage,
    required this.latestCompletedAt,
    required this.highestAccuracy,
    required this.fastestResult,
  });

  final double scale;
  final int? averageDuration;
  final double? averagePercentage;
  final DateTime? latestCompletedAt;
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
      // Padding area isi kartu
      padding: EdgeInsets.fromLTRB(18 * scale, 16 * scale, 18 * scale, 14 * scale),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.8)),
      ),

      // Nama latihan
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          _InfoRow(
            scale: scale,
            label: 'Durasi rata-rata',
            value: averageDuration == null ? '-' : _formatDuration(averageDuration!),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            scale: scale,
            label: 'Rata-rata benar',
            value: averagePercentage == null
                ? '-'
                : _formatPercentage(averagePercentage!),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            scale: scale,
            label: 'Waktu latihan terakhir',
            value: latestCompletedAt == null
                ? '-'
                : _formatRelativeDate(latestCompletedAt!),
          ),

          // Rekor belajar
          const SizedBox(height: 20),
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
              '10 Soal',
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

// Baris riwayat belajar dengan label di kiri dan nilai di area kanan
class _InfoRow extends StatelessWidget {
  const _InfoRow({
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

        // Expanded memaksa area nilai mengisi sisa lebar sehingga data berada pada posisi ujung kanan.
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
            Expanded(
              child: Text(percentage, textAlign: TextAlign.left, style: valueStyle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(duration, textAlign: TextAlign.right, style: valueStyle),
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
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}

String _formatPercentage(double percentage) {
  final rounded = double.parse(percentage.toStringAsFixed(1));
  return '${rounded == rounded.roundToDouble() ? rounded.toInt() : rounded}%';
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