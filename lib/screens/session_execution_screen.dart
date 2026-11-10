import 'package:flutter/material.dart';

import 'session_resume_screen.dart';
import 'session_result_screen.dart';
import '../models/quiz_session.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../utils/formatters.dart';
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

  // Pengaturan tombol warna putih
  ButtonStyle _lightButtonStyle(ThemeData theme, Size size, double s) {
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * s)),
    );
  }

  Widget _confirmDialog(BuildContext dialogContext, int unanswered) {
    final theme = Theme.of(dialogContext);
    final colors = theme.colorScheme;
    final s = dialogContext.rs;

    return Dialog(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 24 * s),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20 * s),
        side: BorderSide(color: theme.dividerColor),
      ),

      // Area kotak dialog konfirmasi
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400 * s),
        child: Padding(
          padding: EdgeInsets.fromLTRB(22 * s, 24 * s, 22 * s, 20 * s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 56 * s,
                  height: 56 * s,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.question_mark_outlined,
                    size: 28 * s,
                    color: colors.primary,
                  ),
                ),
              ),
              SizedBox(height: 16 * s),
              Text(
                'Pengumpulan Latihan',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10 * s),
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
              SizedBox(height: 22 * s),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: _lightButtonStyle(
                          theme, Size.fromHeight(44 * s), s),
                      child: const Text('Batal',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: FilledButton.styleFrom(
                        minimumSize: Size.fromHeight(44 * s),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * s),
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
          final s = context.rs;
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
          final hPad = 18.0 * s;

          ButtonStyle navStyle(Size size) => FilledButton.styleFrom(
                minimumSize: size,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10 * s),
                ),
              );

          return Scaffold(
            // Area Kepala Layar
            appBar: AppBar(
              toolbarHeight: 56 * s,
              leadingWidth: 56 * s,

              // Tombol Kembali
              leading: IconButton(
                tooltip: 'Hentikan sementara dan kembali',
                onPressed: _leaveSession,
                icon: Icon(Icons.arrow_back_rounded, size: 28 * s),
              ),

              // Nama latihan
              centerTitle: true,
              title: Text(
                'Bahasa Inggris',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800, fontSize: 24),
              ),
            ),

            // Area isi
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(hPad, 20 * s, hPad, 18 * s),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 760 * s),
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

                                  SizedBox(width: 10 * s),

                                  // Timer
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10 * s, vertical: 8 * s),
                                    decoration: BoxDecoration(
                                      color: colors.surface,
                                      borderRadius: BorderRadius.circular(9 * s),
                                      border:
                                          Border.all(color: theme.dividerColor),
                                    ),
                                    child: Text(
                                      formatDuration(controller.elapsedSeconds),
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 15 * s),

                              // Teks Petunjuk
                              Text(
                                'Pilih satu jawaban yang paling benar!',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: colors.onSurfaceVariant),
                              ),

                              SizedBox(height: 15 * s),

                              // Area penampilan pertanyaan
                              Container(
                                padding: EdgeInsets.all(16 * s),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(15 * s),
                                  border: Border.all(color: theme.dividerColor, width: 2),
                                ),

                                // Label nomor pertanyaan
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10 * s, vertical: 4 * s),
                                        decoration: BoxDecoration(
                                          color: colors.primary.withValues(alpha: 0.09),
                                          borderRadius: BorderRadius.circular(8 * s),
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

                                    SizedBox(height: 12 * s),

                                    // Area soal
                                    SizedBox(
                                      height: 100 * s,
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
                                              SizedBox(height: 10 * s),
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

                                    SizedBox(height: 16 * s),
                                    for (var i = 0;
                                        i < question.options.length;
                                        i++) ...[

                                      // Pilihan jawaban
                                      SizedBox(
                                        height: 48 * s,
                                        child: AnswerOptionTile(
                                          label: String.fromCharCode(65 + i),
                                          text: question.options[i],
                                          selected: selectedAnswer == i,
                                          onTap: () => controller.chooseAnswer(
                                              question.id, i),
                                        ),
                                      ),
                                      if (i < question.options.length - 1)
                                        SizedBox(height: 8 * s),
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
                    padding: EdgeInsets.fromLTRB(hPad, 10 * s, hPad, 30 * s),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 760 * s),
                        child: Row(
                          children: [
                            // Tombol sebelumnya
                            Expanded(
                              child: OutlinedButton(
                                onPressed: currentIndex == 0
                                    ? null
                                    : () => controller.goToQuestion(currentIndex - 1),
                                style: _lightButtonStyle(
                                    theme, Size.fromHeight(44 * s), s),
                                child: const Text('Sebelumnya',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ),

                            // Jarak antartombol
                            SizedBox(width: 15 * s),

                            // Tombol berikutnya dan kumpulkan
                            Expanded(
                              child: FilledButton(
                                onPressed: isLastQuestion
                                    ? _collectSession
                                    : () => controller.goToQuestion(currentIndex + 1),
                                style: navStyle(Size.fromHeight(44 * s)),
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
                    padding: EdgeInsets.fromLTRB(hPad, 2, hPad, 10 * s),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 760 * s),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ThemeToggleButton(
                            controller: controller,
                            compact: true,
                          ),
                        ),
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