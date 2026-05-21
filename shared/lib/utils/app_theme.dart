import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// WTF Assessment — premium design system.
/// Guru = midnight blue, Trainer = vivid red.
class AppTheme {
  const AppTheme._();

  static const _fontFamily = 'Roboto';

  // ── Shared base ──────────────────────────────────────────────────────────

  static ThemeData _base({
    required Color seed,
    bool dark = false,
  }) {
    final cs = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: dark ? Brightness.dark : Brightness.light,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: dark ? const Color(0xFF0E0E12) : const Color(0xFFF8FAFC),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF16161E) : cs.surface,
        foregroundColor: dark ? Colors.white : cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: Colors.black12,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: dark ? Colors.white : cs.onSurface,
        ),
        systemOverlayStyle: dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: dark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.07),
          ),
        ),
        color: dark ? const Color(0xFF1C1C26) : Colors.white,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: dark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: seed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          color: dark
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.35),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: seed),
          foregroundColor: seed,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(
          color: dark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.08),
        ),
        backgroundColor: dark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        labelStyle: TextStyle(
          fontSize: 13,
          color: dark ? Colors.white70 : Colors.black87,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      dividerTheme: DividerThemeData(
        color: dark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.08),
        space: 0,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: dark ? const Color(0xFF2A2A38) : Colors.black87,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: dark ? const Color(0xFF16161E) : Colors.white,
        selectedItemColor: seed,
        unselectedItemColor: dark
            ? Colors.white.withValues(alpha: 0.4)
            : Colors.black.withValues(alpha: 0.4),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
            fontSize: 11.5, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11.5),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),
    );
  }

  // ── Guru: dark blue, dark mode ────────────────────────────────────────────

  static ThemeData get guru => _base(
    seed: AppColors.guruPrimary,
    dark: true,
  );

  // ── Trainer: vivid red/coral, dark mode ──────────────────────────────────

  static ThemeData get trainer => _base(
    seed: AppColors.trainerPrimary,
    dark: true,
  );
}
