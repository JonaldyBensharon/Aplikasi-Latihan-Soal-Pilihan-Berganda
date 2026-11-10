import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import '../theme/responsive.dart';
import 'bottom_action_bar.dart';

// Desain dasar dari layar Sesi Latihan awal, terhenti, dan hasil
class SessionScaffold extends StatelessWidget {
  const SessionScaffold({
    super.key,
    required this.controller,
    required this.children,
    this.showBack = true,
  });

  final AppController controller;
  final List<Widget> children;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final s = context.rs;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 55 * s,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        scrolledUnderElevation: 3,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
        automaticallyImplyLeading: false,
        leadingWidth: 56 * s,
        leading: showBack
            ? IconButton(
                tooltip: 'Kembali ke Beranda',
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back_rounded, size: 28 * s),
              )
            : null,
        centerTitle: true,
        title: Text(
          'Sesi Latihan',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: colors.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(22 * s, 15 * s, 22 * s, 15 * s),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 520 * s),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                ),
              ),
            ),
            BottomActionBar(controller: controller),
          ],
        ),
      ),
    );
  }
}

// Salam dan petunjuk singkat pada bagian atas layar Sesi Latihan.
class SessionGreeting extends StatelessWidget {
  const SessionGreeting({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = context.rs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: colors.onSurface,
          ),
        ),
        SizedBox(height: 8 * s),
        Text(
          message,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.4,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 20 * s),
      ],
    );
  }
}