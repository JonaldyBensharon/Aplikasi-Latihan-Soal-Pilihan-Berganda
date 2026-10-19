import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum QuestionNumberStatus { unanswered, answered, correct, wrong }

/// Daftar nomor soal horizontal yang digunakan pada layar pelaksanaan dan pemeriksaan latihan
class QuestionNumberStrip extends StatefulWidget {
  const QuestionNumberStrip({
    super.key,
    required this.count,
    required this.currentIndex,
    required this.statusOf,
    required this.onSelected,
  });

  final int count;
  final int currentIndex;
  final QuestionNumberStatus Function(int index) statusOf;
  final ValueChanged<int> onSelected;

  @override
  State<QuestionNumberStrip> createState() => _QuestionNumberStripState();
}

class _QuestionNumberStripState extends State<QuestionNumberStrip> {
  static const double _size = 34;
  static const double _gap = 5;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(animate: false));
  }

  @override
  void didUpdateWidget(covariant QuestionNumberStrip old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // Memungkinkan scroll daftar agar nomor aktif berada di area yang terlihat.
  void _reveal({bool animate = true}) {
    if (!mounted || !_scroll.hasClients) return;
    final pos = _scroll.position;
    final target = (widget.currentIndex * (_size + _gap) -
            (pos.viewportDimension - _size) / 2)
        .clamp(0.0, pos.maxScrollExtent);
    if (animate) {
      _scroll.animateTo(target,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    } else {
      _scroll.jumpTo(target);
    }
  }

  String _tooltip(int index, QuestionNumberStatus s) {
    final label = switch (s) {
      QuestionNumberStatus.unanswered => 'belum dijawab',
      QuestionNumberStatus.answered => 'sudah dijawab',
      QuestionNumberStatus.correct => 'dijawab benar',
      QuestionNumberStatus.wrong => 'dijawab salah',
    };
    return 'Soal ${index + 1} $label';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final brightness = theme.brightness;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        itemCount: widget.count,
        separatorBuilder: (_, __) => const SizedBox(width: _gap),
        itemBuilder: (context, index) {
          final status = widget.statusOf(index);
          final isCurrent = index == widget.currentIndex;
          final statusColor = switch (status) {
            QuestionNumberStatus.unanswered => theme.dividerColor,
            QuestionNumberStatus.answered ||
            QuestionNumberStatus.correct =>
              AppTheme.correctColor(brightness),
            QuestionNumberStatus.wrong => AppTheme.wrongColor(brightness),
          };
          final hasStatus = status != QuestionNumberStatus.unanswered;
          final background = isCurrent
              ? colors.primary
              : hasStatus
                  ? statusColor.withValues(alpha: 0.15)
                  : colors.surface;

          return Tooltip(
            message: _tooltip(index, status),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => widget.onSelected(index),
              child: Container(
                width: _size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: hasStatus || !isCurrent ? statusColor : colors.primary,
                    width: hasStatus ? 1.6 : 1,
                  ),
                ),
                child: Text(
                  '${index + 1}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isCurrent ? colors.onPrimary : colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}