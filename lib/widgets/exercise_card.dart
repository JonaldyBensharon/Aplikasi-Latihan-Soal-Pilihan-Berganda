import 'package:flutter/material.dart';

import '../models/quiz_result.dart';
import '../theme/responsive.dart';
import '../utils/formatters.dart';

// Desain dasar dari kartu informasi latihan berisikan nama, deskripsi, riwayat, dan rekor.
class ExerciseCard extends StatelessWidget {
  const ExerciseCard({super.key, required this.children, required this.footer});

  final List<Widget> children;
  final String footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = context.rs;

    return Container(
      padding: EdgeInsets.fromLTRB(18 * s, 16 * s, 18 * s, 14 * s),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24 * s),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bahasa Inggris',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: 5 * s),
          Text(
            'Kosakata, tata bahasa, dan penyusunan kalimat dalam bahasa Inggris.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          SizedBox(height: 20 * s),
          ...children,
          SizedBox(height: 25 * s),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              footer,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CardSection extends StatelessWidget {
  const CardSection({
    super.key,
    required this.title,
    required this.children,
    this.spacing = 8,
  });

  final String title;
  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.rs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 5 * s),
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: spacing * s),
          children[i],
        ],
      ],
    );
  }
}

// Rekor Belajar pada layar awal, terhenti, dan hasil sesi latihan.
class RecordSection extends StatelessWidget {
  const RecordSection({
    super.key,
    required this.highestAccuracy,
    required this.fastestResult,
  });

  final QuizResult? highestAccuracy;
  final QuizResult? fastestResult;

  @override
  Widget build(BuildContext context) {
    return CardSection(
      title: 'Rekor Belajar',
      spacing: 15,
      children: [
        RecordRow(label: 'Tingkat kebenaran tertinggi', result: highestAccuracy),
        RecordRow(label: 'Durasi pengerjaan tercepat', result: fastestResult),
      ],
    );
  }
}

// Baris dengan label di kiri dan nilai di kanan.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = context.rs;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurface,
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// Baris rekor belajar dengan label, lalu nilai persentase di kiri dan durasi di kanan.
class RecordRow extends StatelessWidget {
  const RecordRow({super.key, required this.label, required this.result});

  final String label;
  final QuizResult? result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = context.rs;
    final valueStyle = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurface,
      fontSize: 12,
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
            fontSize: 12,
            height: 1.35,
          ),
        ),
        SizedBox(height: 6 * s),
        Row(
          children: [
            Expanded(
              child: Text(
                result == null ? '-' : formatPercentage(result!.percentage),
                style: valueStyle,
              ),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: Text(
                result == null ? '-' : formatDuration(result!.durationSeconds),
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