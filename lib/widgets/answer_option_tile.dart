import 'package:flutter/material.dart';

import '../theme/responsive.dart';

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
    final s = context.rs;

    return Material(
      color: selected
          ? accent.withValues(alpha: statusColor == null ? 0.09 : 0.06)
          : colors.surface,
      borderRadius: BorderRadius.circular(10 * s),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10 * s),
        child: Container(
          constraints: BoxConstraints(minHeight: 42 * s),
          padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 8 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10 * s),
            border: Border.all(
              color: selected ? accent : theme.dividerColor,
              width: selected ? 1.4 : 1,
            ),
          ),

          // Pengaturan kotak pilihan jawaban
          child: Row(
            children: [
              Container(
                width: 28 * s,
                height: 26 * s,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected && statusColor == null
                      ? accent
                      : colors.surface,
                  borderRadius: BorderRadius.circular(7 * s),
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
              SizedBox(width: 10 * s),
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