import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import '../theme/responsive.dart';

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
        final s = context.rs;
        final side = (compact ? 50.0 : 60.0) * s;

        return IconButton(
          tooltip: isDarkMode ? 'Aktifkan light mode' : 'Aktifkan dark mode',
          onPressed: controller.toggleTheme,
          icon: Icon(
            isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 30 * s,
            color: colors.onSurface,
          ),
          style: IconButton.styleFrom(
            backgroundColor: colors.surface,
            side: BorderSide(color: theme.dividerColor),
            fixedSize: Size.square(side),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular((compact ? 12 : 15) * s),
            ),
          ),
        );
      },
    );
  }
}