import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../state/app_controller.dart';
import '../theme/responsive.dart';
import 'session_info_screen.dart';
import 'session_resume_screen.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/primary_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _maximumNameLength = 30;
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

      // Navigasi ke layar lanjutkan sesi latihan bila ada sesi latihan yang terhenti
      final hasPausedSession = widget.controller.pausedSession != null;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => hasPausedSession
              ? SessionResumeScreen(controller: widget.controller)
              : SessionInfoScreen(controller: widget.controller),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final s = context.rs;

    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final contentBottomInset =
        math.max(0.0, keyboardInset - BottomActionBar.heightFor(s));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: contentBottomInset),

                // Area logo aplikasi
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20 * s, 60 * s, 20 * s, 30 * s),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 520 * s),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(child: _logoPill(context, isDarkMode)),
                          SizedBox(height: 50 * s),
                          Text(
                            'Aplikasi Latihan Soal Pilihan Berganda',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 10 * s),
                          Text(
                            'Tingkatkan pemahaman, pantau perkembangan, dan lampaui batasan.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.4,
                              fontSize: 13,
                            ),
                          ),

                          // Area kolom nama pengguna
                          SizedBox(height: 35 * s),
                          Text(
                            'Nama pengguna',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8 * s),
                          TextField(
                            controller: _nameController,
                            maxLength: _maximumNameLength,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            onChanged: _onNameChanged,
                            onSubmitted: (_) => _enter(),
                            decoration: InputDecoration(
                              hintText: 'Masukkan nama Anda',
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                size: 18 * s,
                              ),
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12 * s,
                                vertical: 12 * s,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10 * s),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10 * s),
                                borderSide: BorderSide(
                                  color: _nameError == null
                                      ? theme.dividerColor
                                      : colors.error,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10 * s),
                                borderSide: BorderSide(
                                  color: _nameError == null
                                      ? colors.primary
                                      : colors.error,
                                  width: 1.4,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5 * s),

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
                              SizedBox(width: 8 * s),
                              Text(
                                '${_nameController.text.length}/$_maximumNameLength',
                                textAlign: TextAlign.right,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 40 * s),

                          // Area tombol Masuk
                          PrimaryButton(
                            label: 'Masuk',
                            onPressed: _enter,
                            loading: _isSubmitting,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Area bawah untuk bagian tombol
            BottomActionBar(controller: widget.controller),
          ],
        ),
      ),
    );
  }

  Widget _logoPill(BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = context.rs;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13 * s, vertical: 7 * s),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14 * s),
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
              width: 52 * s,
              height: 52 * s,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 7 * s),
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