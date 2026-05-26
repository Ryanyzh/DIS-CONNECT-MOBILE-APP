import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color wiseGreen = Color(0xFF9FE870);
  static const Color wiseActive = Color(0xFFCDFFAD);
  static const Color wiseNeutral = Color(0xFFC5EDAB);
  static const Color wisePale = Color(0xFFE2F6D5);

  static const Color canvas = Color(0xFFFFFFFF);
  static const Color canvasSoft = Color(0xFFE8EBE6);

  static const Color ink = Color(0xFF0E0F0C);
  static const Color inkDeep = Color(0xFF163300);
  static const Color body = Color(0xFF454745);
  static const Color mute = Color(0xFF868685);

  static const Color positive = Color(0xFF2EAD4B);
  static const Color positiveDeep = Color(0xFF054D28);

  static const Color warning = Color(0xFFFFD11A);
  static const Color warningDeep = Color(0xFFB86700);
  static const Color warningContent = Color(0xFF4A3B1C);

  static const Color negative = Color(0xFFD03238);
  static const Color negativeDeep = Color(0xFFA72027);
  static const Color negativeDarkest = Color(0xFFA7000D);
  static const Color negativeBg = Color(0xFF320707);

  static const Color orange = Color(0xFFFFC091);
  static const Color cyan = Color(0xFF38C8FF);
}

class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

class AppBorderRadius {
  AppBorderRadius._();

  static const double wiseSm = 8;
  static const double wiseMd = 12;
  static const double wiseLg = 16;
  static const double wiseXl = 24;
  static const double wisePill = 9999;
}

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  static const TextStyle displayMega = TextStyle(
    fontSize: 126,
    height: 0.85,
    fontWeight: FontWeight.w900,
    color: AppColors.ink,
  );

  static const TextStyle displayXxl = TextStyle(
    fontSize: 96,
    height: 0.85,
    fontWeight: FontWeight.w900,
    color: AppColors.ink,
  );

  static const TextStyle displayXl = TextStyle(
    fontSize: 64,
    height: 0.85,
    fontWeight: FontWeight.w900,
    color: AppColors.ink,
  );

  static const TextStyle displayLg = TextStyle(
    fontSize: 47,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
  );

  static const TextStyle displayMd = TextStyle(
    fontSize: 40,
    height: 0.85,
    fontWeight: FontWeight.w900,
    color: AppColors.ink,
  );

  static const TextStyle displaySm = TextStyle(
    fontSize: 32,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const TextStyle displayXs = TextStyle(
    fontSize: 24,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const TextStyle bodyLg = TextStyle(
    fontSize: 20,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.body,
  );

  static const TextStyle bodyMd = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.body,
  );

  static const TextStyle bodySm = TextStyle(
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.body,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w400,
    color: AppColors.mute,
  );
}

class AppDecorations {
  AppDecorations._();

  static InputDecoration field({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.positiveDeep),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.canvasSoft,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseLg),
        borderSide: const BorderSide(color: Color(0xFFE3E7E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseLg),
        borderSide: const BorderSide(color: Color(0xFFE3E7E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseLg),
        borderSide: const BorderSide(color: AppColors.positiveDeep, width: 1.8),
      ),
      labelStyle: const TextStyle(color: AppColors.body),
    );
  }
}

class AppButtonStyles {
  AppButtonStyles._();

  static final ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.positiveDeep,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.wiseXl),
    ),
    textStyle: AppTypography.bodyMd.copyWith(
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
  );

  static final ButtonStyle outlined = OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.wiseXl),
    ),
    side: const BorderSide(color: Color(0xFFD8DBD6)),
    foregroundColor: AppColors.ink,
    backgroundColor: AppColors.canvas,
    textStyle: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
  );
}
