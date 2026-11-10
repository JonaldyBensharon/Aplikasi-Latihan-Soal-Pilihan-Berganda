import 'package:flutter/material.dart';

import '../data/question_bank.dart';
import '../models/quiz_result.dart';
import '../models/quiz_session.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/question_number_strip.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/answer_option_tile.dart';
import '../models/quiz_question.dart';

// Layar pemeriksaan jawaban untuk satu sesi latihan yang baru diselesaikan.
class SessionInspectionScreen extends StatefulWidget {
  const SessionInspectionScreen({
    super.key,
    required this.controller,
    required this.result,
  });

  final AppController controller;
  final QuizResult result;

  @override
  State<SessionInspectionScreen> createState() =>
      _SessionInspectionScreenState();
}

class _SessionInspectionScreenState extends State<SessionInspectionScreen> {
  int _currentIndex = 0;
  AppController get controller => widget.controller;

  QuizSession? get _session {
    for (final session in controller.sessions) {
      if (session.id == widget.result.sessionId &&
          session.userId == widget.result.userId &&
          session.status == SessionStatus.completed) {
        return session;
      }
    }
    return null;
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

  // Menentukan tampilan satu pilihan pada mode pemeriksaan
  Widget _buildOption({
    required QuizQuestion question,
    required int index,
    required int? selectedAnswer,
    required ThemeData theme,
  }) {
    final isCorrectOption = index == question.correctIndex;
    final isWrongSelection = selectedAnswer == index && !isCorrectOption;

    final Color? status = isCorrectOption
        ? AppTheme.correctColor(theme.brightness)
        : isWrongSelection
            ? AppTheme.wrongColor(theme.brightness)
            : null;

    return AnswerOptionTile(
      label: String.fromCharCode(65 + index),
      text: question.options[index],
      selected: status != null,
      statusColor: status,
    );
  }

  PreferredSizeWidget _appBar(ThemeData theme, double s, {bool styledTitle = true}) {
    return AppBar(
      toolbarHeight: 56 * s,
      leadingWidth: 56 * s,
      leading: IconButton(
        tooltip: 'Kembali ke hasil sesi',
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(Icons.arrow_back_rounded, size: 28 * s),
      ),
      centerTitle: true,
      title: Text(
        'Bahasa Inggris',
        style: styledTitle
            ? theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800, fontSize: 24)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = context.rs;
    final session = _session;
    final user = controller.currentUser;

    // Memastikan hasil dan sesi yang diperiksa benar-benar milik pengguna aktif.
    if (session == null || user == null || user.id != widget.result.userId) {
      return Scaffold(
        appBar: _appBar(theme, s, styledTitle: false),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Data pemeriksaan sesi tidak tersedia untuk pengguna ini.'),
          ),
        ),
      );
    }

    final questions = session.questionIds
        .map((id) => questionBank.firstWhere((question) => question.id == id))
        .toList();
    if (questions.isEmpty) {
      return Scaffold(
        appBar: _appBar(theme, s, styledTitle: false),
        body: const Center(child: Text('Soal untuk sesi ini tidak tersedia.')),
      );
    }

    final currentIndex = _currentIndex.clamp(0, questions.length - 1).toInt();
    final question = questions[currentIndex];
    final selectedAnswer = session.answers[question.id];
    final isAnswered = selectedAnswer != null;
    final isCorrect = isAnswered && selectedAnswer == question.correctIndex;
    final statusColor = !isAnswered
        ? theme.dividerColor
        : isCorrect
            ? AppTheme.correctColor(theme.brightness)
            : AppTheme.wrongColor(theme.brightness);
    final hPad = 18.0 * s;

    return Scaffold(
      // Area kepala layar
      appBar: _appBar(theme, s),

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

                        // Daftar nomor
                        QuestionNumberStrip(
                          count: questions.length,
                          currentIndex: currentIndex,
                          statusOf: (index) {
                            final q = questions[index];
                            final answer = session.answers[q.id];
                            if (answer == null) return QuestionNumberStatus.unanswered;
                            return answer == q.correctIndex
                                ? QuestionNumberStatus.correct
                                : QuestionNumberStatus.wrong;
                          },
                          onSelected: (index) => setState(() => _currentIndex = index),
                        ),

                        SizedBox(height: 15 * s),

                        // Teks Petunjuk
                        Text(
                          'Berikut adalah hasil jawaban pada sesi sebelumnya.',
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
                            border: Border.all(color: statusColor, width: 2),
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
                                    color: isAnswered
                                        ? statusColor.withValues(alpha: 0.10)
                                        : colors.surface,
                                    borderRadius: BorderRadius.circular(8 * s),
                                    border: Border.all(color: statusColor),
                                  ),
                                  child: Text(
                                    '${currentIndex + 1}.',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: isAnswered ? statusColor : colors.onSurface,
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (question.passage?.trim().isNotEmpty ==
                                          true) ...[
                                        Text(
                                          question.passage!,
                                          style:
                                              theme.textTheme.bodyMedium?.copyWith(
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
                                SizedBox(
                                  height: 48 * s,
                                  child: _buildOption(
                                    question: question,
                                    index: i,
                                    selectedAnswer: selectedAnswer,
                                    theme: theme,
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
                      // Tombol Sebelumnya
                      Expanded(
                        child: OutlinedButton(
                          onPressed: currentIndex == 0
                              ? null
                              : () => setState(() => _currentIndex--),
                          style: _lightButtonStyle(
                              theme, Size.fromHeight(44 * s), s),
                          child: const Text('Sebelumnya', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),

                      // Jarak antartombol
                      SizedBox(width: 15 * s),

                      // Tombol Berikutnya
                      Expanded(
                        child: OutlinedButton(
                          onPressed: currentIndex == questions.length - 1
                              ? null
                              : () => setState(() => _currentIndex++),
                          style: _lightButtonStyle(
                              theme, Size.fromHeight(44 * s), s),
                          child: const Text('Berikutnya', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Area tombol pengaturan tema
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 20 * s),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 760 * s),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ThemeToggleButton(controller: controller, compact: true),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}