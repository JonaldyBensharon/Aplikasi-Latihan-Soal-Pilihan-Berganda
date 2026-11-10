import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import '../theme/responsive.dart';
import 'leaderboard_button.dart';
import 'theme_toggle_button.dart';

// Tombol pada area bawah layar, yaitu peringkat dan tema
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    required this.controller,
    this.maxWidth = 520,
  });

  final AppController controller;
  final double maxWidth;

  // Tinggi total bar yang dipakai Beranda untuk menghitung inset keyboard
  static double heightFor(double s) => 8 + 30 + 5 * s + 50 * s;

  @override
  Widget build(BuildContext context) {
    final s = context.rs;
    return Padding(
      padding: EdgeInsets.fromLTRB(25 * s, 8, 25 * s, 30 + 5 * s),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth * s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LeaderboardButton(compact: true, controller: controller),
              ThemeToggleButton(controller: controller, compact: true),
            ],
          ),
        ),
      ),
    );
  }
}