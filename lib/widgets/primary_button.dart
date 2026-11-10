import 'package:flutter/material.dart';

import '../theme/responsive.dart';

// Tombol utama, yaitu Masuk, Mulai, dan Lanjut
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final s = context.rs;
    return Center(
      child: SizedBox(
        width: 135 * s,
        height: 40 * s,
        child: FilledButton(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20 * s),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12 * s),
            ),
          ),
          child: loading
              ? SizedBox(
                  width: 25 * s,
                  height: 25 * s,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}