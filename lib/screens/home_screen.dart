import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../state/app_controller.dart';
import 'session_info_screen.dart';
import '../widgets/leaderboard_button.dart';
import '../widgets/theme_toggle_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _maximumNameLength = 40;
  static const double _bottomBarHeight = 93;
  final TextEditingController _nameController = TextEditingController();
  String? _nameError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged(String value) {
    setState(() {
      if (_nameError != null && value.trim().length >= 3) {
        _nameError = null;
      }
    });
  }

  Future<void> _enter() async {
    final error = widget.controller.validateName(_nameController.text);
    if (error != null) {
      setState(() => _nameError = error);
      return;
    }

    setState(() {
      _nameError = null;
      _isSubmitting = true;
    });

    try {
      final user = await widget.controller.enterName(_nameController.text);
      if (!mounted || user == null) return;

      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => SessionInfoScreen(controller: widget.controller),
        ),
      );

      // Kolom nama dikosongkan ketika pengguna kembali ke Beranda.
      if (mounted) {
        setState(() {
          _nameController.clear();
          _nameError = null;
        });
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _openLeaderboard() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Leaderboard akan dibuat pada tahap berikutnya.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final contentBottomInset = math.max(0.0, keyboardInset - _bottomBarHeight);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: contentBottomInset),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 600;

                    // Area logo aplikasi
                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        isWide ? 32 : 20,
                        60,
                        isWide ? 32 : 20,
                        30,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(child: _logoPill(context, isDarkMode)),
                              const SizedBox(height: 50),
                              Text(
                                'Aplikasi Latihan Soal Pilihan Berganda',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Tingkatkan pemahaman, pantau perkembangan, dan lampaui batasan.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  height: 1.4,
                                  fontSize: 13,
                                ),
                              ),

                              // Area kolom nama pengguna
                              const SizedBox(height: 35),
                              Text(
                                'Nama pengguna',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _nameController,
                                maxLength: _maximumNameLength,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.done,
                                onChanged: _onNameChanged,
                                onSubmitted: (_) => _enter(),
                                decoration: InputDecoration(
                                  hintText: 'Masukkan nama Anda',
                                  prefixIcon: const Icon(
                                    Icons.person_outline_rounded,
                                    size: 18,
                                  ),
                                  counterText: '',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: _nameError == null
                                          ? theme.dividerColor
                                          : colors.error,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: _nameError == null
                                          ? colors.primary
                                          : colors.error,
                                      width: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),

                              // Pesan error dan penghitung karakter berada pada satu baris.
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _nameError == null
                                        ? const SizedBox.shrink()
                                        : Text(
                                            _nameError!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(color: colors.error),
                                          ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_nameController.text.length}/$_maximumNameLength',
                                    textAlign: TextAlign.right,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),

                              // Area tombol Masuk
                              Center(
                                child: SizedBox(
                                  width: 135,
                                  height: 40,
                                  child: FilledButton(
                                    onPressed: _isSubmitting ? null : _enter,
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            width: 25,
                                            height: 25,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Masuk',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Area bawah untuk bagian tombol
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 8, 25, 35),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LeaderboardButton(
                    compact: true,
                    onPressed: _openLeaderboard,
                  ),
                  ThemeToggleButton(
                    controller: widget.controller,
                    compact: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoPill(BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.08 : 0.10),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              isDarkMode ? colors.onSurface : const Color(0xFF222A43),
              BlendMode.srcIn,
            ),
            child: Image.asset(
              'assets/images/logo.png',
              width: 52,
              height: 52,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            'Drill Exe',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.onSurface,
              fontSize: 45,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}