import 'package:flutter/material.dart';

// Widget pilihan jawaban yang akan digunakan pada layar pelaksanaan dan pemeriksaan latihan
class AnswerOptionTile extends StatelessWidget {
  const AnswerOptionTile({
    super.key,
    required this.label,
    required this.text,
    required this.selected,
    this.onTap,
    this.statusColor,
  });

  final String label;
  final String text;
  final bool selected;
  final VoidCallback? onTap;

  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = statusColor ?? colors.primary;

    return Material(
      color: selected
          ? accent.withValues(alpha: statusColor == null ? 0.09 : 0.06)
          : colors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 42),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? accent : theme.dividerColor,
              width: selected ? 1.4 : 1,
            ),
          ),

          // Pengaturan kotak pilihan jawaban
          child: Row(
            children: [
              Container(
                width: 28,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected && statusColor == null
                      ? accent
                      : colors.surface,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: selected ? accent : theme.dividerColor,
                  ),
                ),
                child: Text(
                  '$label.',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: !selected
                        ? colors.onSurface
                        : statusColor == null
                            ? colors.onPrimary
                            : accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}