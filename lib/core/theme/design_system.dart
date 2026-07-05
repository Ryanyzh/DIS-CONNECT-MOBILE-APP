import 'package:flutter/material.dart';

// ── Brand gradient ─────────────────────────────────────────────────────────────
// Linear 135°: #9A32F8 → #6A2FF3 → #4C39F2 → #1D4BEB → #1D67F5 → #247DF9

class AppGradients {
  AppGradients._();

  static const LinearGradient brand = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: [0.0, 0.25, 0.45, 0.70, 0.90, 1.0],
    colors: [
      Color(0xFF9A32F8),
      Color(0xFF6A2FF3),
      Color(0xFF4C39F2),
      Color(0xFF1D4BEB),
      Color(0xFF1D67F5),
      Color(0xFF247DF9),
    ],
  );

  static const LinearGradient brandDiagonal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.25, 0.45, 0.70, 0.90, 1.0],
    colors: [
      Color(0xFF9A32F8),
      Color(0xFF6A2FF3),
      Color(0xFF4C39F2),
      Color(0xFF1D4BEB),
      Color(0xFF1D67F5),
      Color(0xFF247DF9),
    ],
  );
}

class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color brandViolet    = Color(0xFF9A32F8); // gradient start
  static const Color brandPurple    = Color(0xFF6A2FF3); // primary dark
  static const Color brandIndigo    = Color(0xFF4C39F2); // primary
  static const Color brandRoyal     = Color(0xFF1D4BEB); // royal blue
  static const Color brandBright    = Color(0xFF1D67F5); // bright blue
  static const Color brandElectric  = Color(0xFF247DF9); // gradient end

  // Semantic aliases (used by AppDecorations / AppButtonStyles)
  static const Color primary       = brandIndigo;
  static const Color primaryDark   = brandPurple;
  static const Color primaryDeeper = brandViolet;

  // Light tints (backgrounds for chips, badges, selected states)
  static const Color primaryBg     = Color(0xFFF0ECFF); // very light purple
  static const Color primaryBgMid  = Color(0xFFE4DCFF); // light purple
  static const Color primaryBorder = Color(0xFFCDC1FF); // purple border

  // ── Legacy aliases (keep for backward compat in screens) ─────────────────
  static const Color wiseGreen   = brandViolet;
  static const Color wiseActive  = primaryBgMid;
  static const Color wiseNeutral = Color(0xFFD9D0FF);
  static const Color wisePale    = primaryBg;

  static const Color canvas     = Color(0xFFFFFFFF);
  static const Color canvasSoft = Color(0xFFF3F0FF); // replaces greenish tint

  static const Color ink     = Color(0xFF0E0F0C);
  static const Color inkDeep = Color(0xFF1D4BEB);  // replaces dark green
  static const Color body    = Color(0xFF454745);
  static const Color mute    = Color(0xFF868685);

  static const Color positive      = brandIndigo;
  static const Color positiveDeep  = brandPurple; // replaces #054D28
  static const Color positiveLight = primaryBg;

  static const Color warning        = Color(0xFFFFD11A);
  static const Color warningDeep    = Color(0xFFB86700);
  static const Color warningContent = Color(0xFF4A3B1C);

  static const Color negative       = Color(0xFFD03238);
  static const Color negativeDeep   = Color(0xFFA72027);
  static const Color negativeDarkest = Color(0xFFA7000D);
  static const Color negativeBg     = Color(0xFF320707);

  static const Color orange = Color(0xFFFFC091);
  static const Color cyan   = Color(0xFF38C8FF);
}

class AppSpacing {
  AppSpacing._();

  static const double xxs  = 2;
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 24;
  static const double xxl  = 32;
  static const double xxxl = 48;
}

class AppBorderRadius {
  AppBorderRadius._();

  static const double wiseSm   = 8;
  static const double wiseMd   = 12;
  static const double wiseLg   = 16;
  static const double wiseXl   = 24;
  static const double wisePill = 9999;
}

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  static const TextStyle displayMega = TextStyle(
    fontSize: 126, height: 0.85, fontWeight: FontWeight.w900, color: AppColors.ink,
  );
  static const TextStyle displayXxl = TextStyle(
    fontSize: 96, height: 0.85, fontWeight: FontWeight.w900, color: AppColors.ink,
  );
  static const TextStyle displayXl = TextStyle(
    fontSize: 64, height: 0.85, fontWeight: FontWeight.w900, color: AppColors.ink,
  );
  static const TextStyle displayLg = TextStyle(
    fontSize: 47, height: 1.5, fontWeight: FontWeight.w400, color: AppColors.ink,
  );
  static const TextStyle displayMd = TextStyle(
    fontSize: 40, height: 0.85, fontWeight: FontWeight.w900, color: AppColors.ink,
  );
  static const TextStyle displaySm = TextStyle(
    fontSize: 32, height: 1.2, fontWeight: FontWeight.w600, color: AppColors.ink,
  );
  static const TextStyle displayXs = TextStyle(
    fontSize: 24, height: 1.3, fontWeight: FontWeight.w600, color: AppColors.ink,
  );
  static const TextStyle bodyLg = TextStyle(
    fontSize: 20, height: 1.5, fontWeight: FontWeight.w400, color: AppColors.body,
  );
  static const TextStyle bodyMd = TextStyle(
    fontSize: 16, height: 1.5, fontWeight: FontWeight.w400, color: AppColors.body,
  );
  static const TextStyle bodySm = TextStyle(
    fontSize: 14, height: 1.45, fontWeight: FontWeight.w400, color: AppColors.body,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12, height: 1.33, fontWeight: FontWeight.w400, color: AppColors.mute,
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
      prefixIcon: Icon(icon, color: AppColors.primaryDark),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.canvasSoft,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseLg),
        borderSide: const BorderSide(color: Color(0xFFE0DAFF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseLg),
        borderSide: const BorderSide(color: Color(0xFFE0DAFF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseLg),
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.8),
      ),
      labelStyle: const TextStyle(color: AppColors.body),
    );
  }
}

class AppButtonStyles {
  AppButtonStyles._();

  static final ButtonStyle outlined = OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.wiseXl),
    ),
    side: const BorderSide(color: Color(0xFFD9D0FF)),
    foregroundColor: AppColors.ink,
    backgroundColor: AppColors.canvas,
    textStyle: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
  );
}

// ── Gradient widgets ──────────────────────────────────────────────────────────

/// Primary call-to-action button with the brand gradient background.
///
/// Two usage patterns:
///
/// **Simple label + icon** (recommended — handles loading state automatically):
/// ```dart
/// GradientButton(
///   onPressed: _submit,
///   loading: _isLoading,
///   icon: Icons.send_rounded,
///   label: 'Submit',
///   loadingLabel: 'Submitting...', // optional — defaults to label
/// )
/// ```
///
/// **Fully custom child** (for complex layouts):
/// ```dart
/// GradientButton(onPressed: _submit, child: MyWidget())
/// ```
///
/// Pass [loading] = true to keep the gradient visible while blocking taps.
/// The button shows a spinner next to [loadingLabel] (or [label]) when loading.
/// Pass [onPressed] = null (with loading = false) for a fully-disabled grey state.
class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;

  // ── Simple API ─────────────────────────────────────────────────────────────
  final IconData? icon;
  final String? label;
  final String? loadingLabel; // shown while loading; defaults to [label]

  // ── Custom content (used when icon/label aren't sufficient) ───────────────
  final Widget? child;

  // ── Shared ─────────────────────────────────────────────────────────────────
  final bool loading;
  final double height;
  final BorderRadius? borderRadius;

  const GradientButton({
    super.key,
    required this.onPressed,
    this.icon,
    this.label,
    this.loadingLabel,
    this.child,
    this.loading = false,
    this.height = 54,
    this.borderRadius,
  }) : assert(label != null || child != null,
            'GradientButton: provide either label or child');

  Widget _buildContent() {
    final textStyle = AppTypography.bodyMd.copyWith(
      fontWeight: FontWeight.w700,
      color: Colors.white,
      fontSize: 15,
    );

    if (loading) {
      final text = loadingLabel ?? label;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          if (text != null) ...[
            const SizedBox(width: 10),
            Text(text, style: textStyle),
          ],
        ],
      );
    }

    // Custom child takes precedence
    if (child != null) {
      return DefaultTextStyle(
        style: textStyle,
        child: IconTheme(
          data: const IconThemeData(color: Colors.white),
          child: child!,
        ),
      );
    }

    // icon + label row
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon!, color: Colors.white, size: 18),
          const SizedBox(width: 8),
        ],
        Text(label!, style: textStyle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius =
        borderRadius ?? BorderRadius.circular(AppBorderRadius.wiseLg);
    final showGradient = onPressed != null || loading;

    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: showGradient ? AppGradients.brand : null,
          color: showGradient ? null : const Color(0xFFCBD5E1),
          borderRadius: radius,
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: radius,
          child: InkWell(
            onTap: loading ? null : onPressed,
            borderRadius: radius,
            splashColor: Colors.white.withValues(alpha: 0.18),
            highlightColor: Colors.white.withValues(alpha: 0.08),
            child: Center(child: _buildContent()),
          ),
        ),
      ),
    );
  }
}

/// Applies the brand gradient as a shader mask over an icon.
/// Use this for AppBar back buttons and other icon-only brand touches.
class GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const GradientIcon({super.key, required this.icon, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => AppGradients.brand.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      blendMode: BlendMode.srcIn,
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}
