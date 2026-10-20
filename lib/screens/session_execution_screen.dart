import 'package:flutter/material.dart';

import 'session_resume_screen.dart';
import 'session_result_screen.dart';
import '../models/quiz_session.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/answer_option_tile.dart';
import '../widgets/question_number_strip.dart';
import '../widgets/theme_toggle_button.dart';

class SessionExecutionScreen extends StatefulWidget {
  const SessionExecutionScreen({super.key, required this.controller});
  final AppController controller;

  @override
  State<SessionExecutionScreen> createState() => _SessionExecutionScreenState();
}

class _SessionExecutionScreenState extends State<SessionExecutionScreen> with WidgetsBindingObserver {
  static const double _optionHeight = 48;
  static const double _optionGap = 8;

  AppController get controller => widget.controller;

  // Menghentikan timer selama proses pengumpulan
  bool _isCollecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Memastikan durasi berhenti dan disimpan ketika sesi latihan terhenti
  // Durasi akan kembali berjalan ketika sesi latihan dilanjutkan
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      controller.pauseSession();
    } else if (state == AppLifecycleState.resumed) {

      // Timer dihentikan selama dialog konfirmasi terbuka
      if (_isCollecting) return;
      final isOpen = ModalRoute.of(context)?.isActive ?? false;
      if (isOpen && controller.currentSession?.status == SessionStatus.paused) {
        controller.resumeSession();
      }
    }
  }

    //
  Future<void> _leaveSession() async {
    if (_isCollecting) return;
    await controller.pauseSession();
    if (!mounted) return;

    // Memastikan navigasi ke layar lanjutkan sesi ketika ada sesi terhenti yang belum diselesaikan.
    // Seluruh route di atas Beranda dibuang agar tidak menumpuk.
    await Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
        builder: (_) => SessionResumeScreen(controller: controller),
      ),
      (route) => route.isFirst,
    );
  }

  ButtonStyle _lightButtonStyle(ThemeData theme, Size size) {
    final isDark = theme.brightness == Brightness.dark;
    final fg = isDark ? AppTheme.lightText : theme.colorScheme.onSurface;
    final border = isDark ? AppTheme.lightBorder : theme.dividerColor;
    return OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: fg,
      disabledBackgroundColor: Colors.white.withValues(alpha: 0.45),
      disabledForegroundColor: fg.withValues(alpha: 0.4),
      side: BorderSide(color: border),
      minimumSize: size,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _confirmDialog(BuildContext dialogContext, int unanswered) {
    final theme = Theme.of(dialogContext);
    final colors = theme.colorScheme;

    return Dialog(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor),
      ),


      // Area kotak dialog konfirmasi
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.question_mark_outlined,
                    size: 28,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pengumpulan Latihan',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                unanswered > 0
                    ? 'Masih ada $unanswered pertanyaan yang belum dijawab. '
                        'Apakah Anda yakin ingin mengumpulkan latihan?'
                    : 'Seluruh pertanyaan telah dijawab. Apakah Anda yakin ingin '
                        'mengumpulkan latihan?',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: _lightButtonStyle(theme, const Size.fromHeight(44)),
                      child: const Text('Batal',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Iya',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _collectSession() async {
    if (_isCollecting) return;
    final session = controller.currentSession;
    if (session == null || session.status != SessionStatus.active) return;

    _isCollecting = true;
    try {
      // Timer dihentikan segera saat Kumpulkan ditekan.
      await controller.pauseSession();
      if (!mounted) return;

      final unanswered = session.unansweredCount;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => _confirmDialog(dialogContext, unanswered),
      );
      if (!mounted) return;

      if (confirmed != true) {
        // Ketika pengumpulan dibatalkan, timer kembali berjalan
        await controller.resumeSession();
        return;
      }

      final result = await controller.completeSession();
      if (!mounted || result == null) return;

      // Penggantian layar pelaksanaan dengan layar hasil agar tombol Kembali menuju layar informasi sesi
      await Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute<void>(
          builder: (_) => SessionResultScreen(
            controller: controller,
            result: result,
          ),
        ),
      );
    } finally {
      _isCollecting = false;
    }
  }

  String _formatDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leaveSession();
      },
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final theme = Theme.of(context);
          final colors = theme.colorScheme;
          final session = controller.currentSession;
          final questions = controller.currentQuestions;

          if (session == null || questions.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: const Text('Bahasa Inggris')),
              body: const Center(child: Text('Sesi latihan tidak tersedia.')),
            );
          }

          final currentIndex = session.currentIndex.clamp(0, questions.length - 1).toInt();
          final question = questions[currentIndex];
          final selectedAnswer = session.answers[question.id];
          final isLastQuestion = currentIndex == questions.length - 1;
          final screenSize = MediaQuery.sizeOf(context);
          final isWide = screenSize.width >= 700;
          final hPad = isWide ? 32.0 : 18.0;

          // Area pertanyaan
          final double questionAreaHeight = 100;

          ButtonStyle navStyle(Size size) => FilledButton.styleFrom(
                minimumSize: size,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              );

          return Scaffold(
            // Area Kepala Layar
            appBar: AppBar(
              // Tombol Kembali
              leading: IconButton(
                tooltip: 'Hentikan sementara dan kembali',
                onPressed: _leaveSession,
                icon: const Icon(Icons.arrow_back_rounded, size: 28),
              ),

              // Nama latihan
              centerTitle: true,
              title: Text(
                'Bahasa Inggris',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800, fontSize: 24),
              ),
            ),
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 18),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    // Daftar nomor horizontal
                                    child: QuestionNumberStrip(
                                      count: questions.length,
                                      currentIndex: currentIndex,
                                      statusOf: (i) =>
                                          session.answers[questions[i].id] != null
                                              ? QuestionNumberStatus.answered
                                              : QuestionNumberStatus.unanswered,
                                      onSelected: controller.goToQuestion,
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  // Timer
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: colors.surface,
                                      borderRadius: BorderRadius.circular(9),
                                      border:
                                          Border.all(color: theme.dividerColor),
                                    ),
                                    child: Text(
                                      _formatDuration(controller.elapsedSeconds),
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 15),

                              // Teks Petunjuk
                              Text(
                                'Pilih satu jawaban yang paling benar!',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: colors.onSurfaceVariant),
                              ),

                              const SizedBox(height: 15),

                              // Area penampilan pertanyaan
                              Container(
                                padding: EdgeInsets.all(isWide ? 22 : 14),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: theme.dividerColor, width: 2),
                                ),

                                // Label nomor pertanyaan
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: colors.primary.withValues(alpha: 0.09),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${currentIndex + 1}.',
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                            color: colors.primary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Area soal (bacaan + pertanyaan): tinggi tetap
                                    SizedBox(
                                      height: questionAreaHeight,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (question.passage != null &&
                                                question.passage!
                                                    .trim()
                                                    .isNotEmpty) ...[
                                              Text(
                                                question.passage!,
                                                style: theme.textTheme.bodyMedium
                                                    ?.copyWith(
                                                  height: 1.45,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                            ],
                                            Text(
                                              question.prompt,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(height: 1.5),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),
                                    for (var i = 0;
                                        i < question.options.length;
                                        i++) ...[

                                      // Pilihan jawaban
                                      SizedBox(
                                        height: _optionHeight,
                                        child: AnswerOptionTile(
                                          label: String.fromCharCode(65 + i),
                                          text: question.options[i],
                                          selected: selectedAnswer == i,
                                          onTap: () => controller.chooseAnswer(
                                              question.id, i),
                                        ),
                                      ),
                                      if (i < question.options.length - 1)
                                        const SizedBox(height: _optionGap),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Area tombol navigasi pertanyaan
                  Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 30),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: currentIndex == 0
                                    ? null
                                    : () => controller.goToQuestion(currentIndex - 1),
                                style: _lightButtonStyle(
                                    theme, const Size.fromHeight(44)),
                                child: const Text('Sebelumnya',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ),

                            // Jarak antartombol
                            const SizedBox(width: 15),

                            Expanded(
                              child: FilledButton(
                                onPressed: isLastQuestion
                                    ? _collectSession
                                    : () => controller.goToQuestion(currentIndex + 1),
                                style: navStyle(const Size.fromHeight(44)),
                                child: Text(
                                  isLastQuestion ? 'Kumpulkan' : 'Berikutnya',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Area tombol pengaturan tema
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 2, 18, 10),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ThemeToggleButton(
                        controller: controller,
                        compact: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}