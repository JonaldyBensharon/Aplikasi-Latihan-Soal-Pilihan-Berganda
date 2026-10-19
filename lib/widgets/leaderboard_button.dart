import 'package:flutter/material.dart';

class LeaderboardButton extends StatelessWidget {
  const LeaderboardButton({
    super.key,
    required this.onPressed,
    this.compact = false,
  });

  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return IconButton(
      tooltip: 'Buka leaderboard',
      onPressed: onPressed,
      icon: Icon(Icons.view_list_rounded, size: 30, color: colors.onSurface),
      style: IconButton.styleFrom(
        backgroundColor: colors.surface,
        side: BorderSide(color: theme.dividerColor),
        minimumSize: compact ? const Size(50, 50) : const Size(60, 60),
        maximumSize: compact ? const Size(65, 65) : null,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(compact ? 12 : 15),
        ),
      ),
    );
  }
}