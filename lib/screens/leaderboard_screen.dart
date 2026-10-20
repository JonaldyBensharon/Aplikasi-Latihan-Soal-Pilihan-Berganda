import 'package:flutter/material.dart';

import '../models/quiz_result.dart';
import '../state/app_controller.dart';
import '../widgets/theme_toggle_button.dart';

// Peringkat seluruh pengguna berdasarkan hasil latihan yang sudah selesai.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  static const double _wideBreakpoint = 600;
  bool _sortByScore = true;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        final controller = widget.controller;

        final entries = _sortByScore
            ? controller.leaderboardByScore
            : controller.leaderboardByDuration;
        final usersById = {for (final user in controller.users) user.id: user};
        final visibleEntries = entries
            .where((result) => usersById.containsKey(result.userId))
            .toList();
        final currentUserId = controller.currentUser?.id;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= _wideBreakpoint;
            final scale = isWide ? 1.2 : 1.0;

            final themeButton =
                ThemeToggleButton(controller: controller, compact: true);
            final sortButton = _SortButton(
              sortByScore: _sortByScore,
              scale: scale,
              onSelected: (value) => setState(() => _sortByScore = value),
            );

            return Scaffold(

              // Area kepala layar
              appBar: AppBar(
                toolbarHeight: 55,
                backgroundColor: colors.surface,
                surfaceTintColor: Colors.transparent,
                elevation: 3,
                scrolledUnderElevation: 3,
                shadowColor: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                leading: IconButton(
                  tooltip: 'Kembali',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 28),
                ),
                centerTitle: true,
                title: Text(
                  'Peringkat',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 24 * scale,
                    color: colors.onSurface,
                  ),
                ),
              ),

              // Area isi
              body: SafeArea(
                top: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(maxWidth: isWide ? 720 : 520),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isWide ? 32 : 20,
                        20,
                        isWide ? 32 : 20,
                        isWide ? 28 : 25,
                      ),
                      child: Column(
                        children: [
                          // Area tombol pada bagian atas
                          Row(
                            mainAxisAlignment: isWide
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.spaceBetween,
                            children: isWide
                                ? [
                                    sortButton,
                                    const SizedBox(width: 12),
                                    themeButton,
                                  ]
                                : [themeButton, sortButton],
                          ),
                          const SizedBox(height: 20),

                          // Area papan peringkat
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.fromLTRB(
                                12 * scale,
                                14 * scale,
                                12 * scale,
                                12 * scale,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.dividerColor
                                      .withValues(alpha: 0.8),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                        alpha: isDark ? 0.15 : 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: visibleEntries.isEmpty
                                  ? _EmptyState(scale: scale)
                                  : Column(
                                      children: [
                                        _HeaderLabels(scale: scale),
                                        const SizedBox(height: 10),

                                        Expanded(
                                          child: ListView.separated(
                                            itemCount: visibleEntries.length,
                                            separatorBuilder: (_, __) =>
                                                const SizedBox(height: 8),
                                            itemBuilder: (context, index) {
                                              final result =
                                                  visibleEntries[index];
                                              return _LeaderboardRow(
                                                rank: index + 1,
                                                name: usersById[result.userId]!
                                                    .displayName,
                                                result: result,
                                                scoreMode: _sortByScore,
                                                isCurrentUser:
                                                    result.userId ==
                                                        currentUserId,
                                                scale: scale,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}


const double _rankColumnWidth = 64;
const double _statColumnWidth = 84;
const double _rowHorizontalPadding = 10;

class _SortButton extends StatelessWidget {
  const _SortButton({
    required this.sortByScore,
    required this.scale,
    required this.onSelected,
  });

  final bool sortByScore;
  final double scale;
  final ValueChanged<bool> onSelected;

  PopupMenuItem<bool> _item(BuildContext context, bool value, String label) {
    final selected = value == sortByScore;
    return PopupMenuItem<bool>(
      value: value,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return PopupMenuButton<bool>(
      tooltip: 'Urutkan peringkat',
      initialValue: sortByScore,
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 6),
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      itemBuilder: (context) => [
        _item(context, true, 'Skor tertinggi'),
        _item(context, false, 'Durasi tercepat'),
      ],
      child: Container(
        height: 50,
        constraints: BoxConstraints(minWidth: 110 * scale),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              sortByScore ? 'Skor' : 'Durasi',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15 * scale,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_downward_rounded,
                size: 20, color: colors.onSurface),
          ],
        ),
      ),
    );
  }
}

class _HeaderLabels extends StatelessWidget {
  const _HeaderLabels({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = TextStyle(
      fontSize: 12 * scale,
      fontWeight: FontWeight.w600,
      color: colors.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _rowHorizontalPadding + 1),
      child: Row(
        // Area label
        children: [
          SizedBox(
            width: _rankColumnWidth * scale,
            child: Text('Peringkat', textAlign: TextAlign.center, style: style),
          ),

          const SizedBox(width: 8),

          Expanded(child: Text('Nama', style: style)),

          const SizedBox(width: 8),
          SizedBox(
            width: _statColumnWidth * scale,
            child: Text('Statistik', textAlign: TextAlign.end, style: style),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events,
                size: 50 * scale, color: colors.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'Belum ada pengguna yang menyelesaikan latihan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13 * scale,
                height: 1.4,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.rank,
    required this.name,
    required this.result,
    required this.scoreMode,
    required this.isCurrentUser,
    required this.scale,
  });

  final int rank;
  final String name;
  final QuizResult result;
  final bool scoreMode;
  final bool isCurrentUser;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = isCurrentUser ? colors.primary : theme.dividerColor;

    final percentage = _formatPercentage(result.percentage);
    final duration = _formatDuration(result.durationSeconds);
    final statistic = scoreMode ? percentage : duration;
    final secondaryStatistic = scoreMode ? duration : percentage;

    return Container(
      constraints: BoxConstraints(minHeight: 52 * scale),
      padding: EdgeInsets.symmetric(
        horizontal: _rowHorizontalPadding,
        vertical: 7 * scale,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border.all(color: accent, width: isCurrentUser ? 1.4 : 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _rankColumnWidth * scale,
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  minWidth: 32 * scale,
                  minHeight: 30 * scale,
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border.all(
                    color: isCurrentUser ? colors.primary : theme.dividerColor,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$rank.',
                  style: TextStyle(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5 * scale,
                fontWeight: isCurrentUser ? FontWeight.w700 : FontWeight.w500,
                color: colors.onSurface,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: _statColumnWidth * scale,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  statistic,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12.5 * scale,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  secondaryStatistic,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10.5 * scale,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDuration(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final remainingSeconds = seconds % 60;
  return '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}:'
      '${remainingSeconds.toString().padLeft(2, '0')}';
}

String _formatPercentage(double percentage) {
  final rounded = double.parse(percentage.toStringAsFixed(1));
  return '${rounded == rounded.roundToDouble() ? rounded.toInt() : rounded}%';
}