import 'package:flutter/material.dart';
import '../state/app_controller.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({
    super.key,
    required this.controller,
    this.compact = false,
  });

  final AppController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final isDarkMode = controller.isDarkMode;
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        return IconButton(
          tooltip: isDarkMode ? 'Aktifkan light mode' : 'Aktifkan dark mode',
          onPressed: controller.toggleTheme,
          icon: Icon(
            isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: compact ? 30 : 30,
            color: colors.onSurface,
          ),
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
      },
    );
  }
}
