import 'package:flutter/material.dart';

import '../data/question_bank.dart';
import '../models/quiz_result.dart';
import '../models/quiz_session.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
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
  static const double _questionAreaHeight = 100;
  static const double _optionHeight = 48;
  static const double _optionGap = 8;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final session = _session;
    final user = controller.currentUser;

    // Memastikan hasil dan sesi yang diperiksa benar-benar milik pengguna aktif.
    if (session == null || user == null || user.id != widget.result.userId) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Kembali ke hasil sesi',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          centerTitle: true,
          title: const Text('Bahasa Inggris'),
        ),
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
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          centerTitle: true,
          title: const Text('Bahasa Inggris'),
        ),
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 700;
    final horizontalPadding = isWide ? 32.0 : 18.0;

    return Scaffold(

      // Area kepala layar
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali ke hasil sesi',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, size: 28),
        ),
        centerTitle: true,
        title: Text(
          'Bahasa Inggris',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 24,
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
                padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 18),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
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

                        const SizedBox(height: 15),

                        // Teks Petunjuk
                        Text(
                          'Berikut adalah hasil jawaban pada sesi sebelumnya.',
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
                            border: Border.all(color: statusColor, width: 2),
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
                                    color: isAnswered
                                        ? statusColor.withValues(alpha: 0.10)
                                        : colors.surface,
                                    borderRadius: BorderRadius.circular(8),
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


                              const SizedBox(height: 12),

                              // Area soal
                              SizedBox(
                                height: _questionAreaHeight,
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
                                SizedBox(
                                  height: _optionHeight,
                                  child: _buildOption(
                                    question: question,
                                    index: i,
                                    selectedAnswer: selectedAnswer,
                                    theme: theme,
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
              padding: EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Row(
                    children: [
                      // Tombol Sebelumnya
                      Expanded(
                        child: OutlinedButton(
                          onPressed: currentIndex == 0
                              ? null
                              : () => setState(() => _currentIndex--),
                          style: _lightButtonStyle(
                              theme, const Size.fromHeight(44)),
                          child: const Text('Sebelumnya', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),

                      // Jarak antartombol
                      const SizedBox(width: 15),

                      // Tombol Berikutnya
                      Expanded(
                        child: OutlinedButton(
                          onPressed: currentIndex == questions.length - 1
                              ? null
                              : () => setState(() => _currentIndex++),
                          style: _lightButtonStyle(
                              theme, const Size.fromHeight(44)),
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
              padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: ThemeToggleButton(controller: controller, compact: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}