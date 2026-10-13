import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════
// NAJDA V3 — Design System (Light Edition)
// Direction: Clean, medical-grade, accessible.
// Navy/White base with high-contrast electric accents.
// ═══════════════════════════════════════════════════════════════════

class NC {
  NC._();

  // ── Palette (Light Mode Focused) ───────────────────────────────────
  static const Color base        = Color(0xFFF8FAFC); // background
  static const Color surface     = Color(0xFFFFFFFF); // surface
  static const Color card        = Color(0xFFFFFFFF); // card bg
  static const Color cardBorder  = Color(0xFFE2E8F0); // subtle border
  static const Color overlay     = Color(0xFFF1F5F9); // hover/pressed

  static const Color primary     = Color(0xFF007AFF); // classic medical blue
  static const Color primaryDim  = Color(0xFF0056B3); // muted blue
  static const Color critical    = Color(0xFFE11D48); // vivid red
  static const Color criticalDim = Color(0xFF9F1239); // muted red
  static const Color warning     = Color(0xFFF59E0B); // amber
  static const Color success     = Color(0xFF10B981); // emerald green

  static const Color textHigh    = Color(0xFF0F172A); // primary text
  static const Color textMid     = Color(0xFF475569); // secondary text
  static const Color textLow     = Color(0xFF94A3B8); // disabled/hint

  // ── Gradients ──────────────────────────────────────────────────────
  static const LinearGradient bgGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
  );

  static const LinearGradient primaryGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF007AFF), Color(0xFF0056B3)],
  );

  static const LinearGradient criticalGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE11D48), Color(0xFF9F1239)],
  );

  static const LinearGradient successGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient cardGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF378ADD), Color(0xFF185FA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Typography ─────────────────────────────────────────────────────
  static const String font = 'PlusJakartaSans';

  static TextStyle display(double size, {Color? color, FontWeight? weight}) =>
      TextStyle(
        fontFamily: font,
        fontSize: size,
        fontWeight: weight ?? FontWeight.w800,
        color: color ?? textHigh,
        letterSpacing: -0.5,
      );

  static TextStyle body(double size, {Color? color, FontWeight? weight}) =>
      TextStyle(
        fontFamily: font,
        fontSize: size,
        fontWeight: weight ?? FontWeight.w400,
        color: color ?? textMid,
        height: 1.6,
      );

  static TextStyle label(double size, {Color? color, FontWeight? weight}) =>
      TextStyle(
        fontFamily: font,
        fontSize: size,
        fontWeight: weight ?? FontWeight.w600,
        color: color ?? textHigh,
        letterSpacing: 0.2,
      );

  static TextStyle inputText() => const TextStyle(
        fontFamily: font,
        color: textHigh,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      );
}

// ═══════════════════════════════════════════════════════════════════
// THEME
// ═══════════════════════════════════════════════════════════════════
class NajdaTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: NC.font,
    brightness: Brightness.light,
    scaffoldBackgroundColor: NC.base,
    colorScheme: const ColorScheme.light(
      primary: NC.primary,
      secondary: NC.success,
      error: NC.critical,
      surface: NC.surface,
      onPrimary: Colors.white,
      onSurface: NC.textHigh,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: NC.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: NC.display(17, weight: FontWeight.w700),
      iconTheme: const IconThemeData(color: NC.textHigh),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: NC.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: NC.cardBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: NC.cardBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: NC.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: NC.critical),
      ),
      hintStyle: TextStyle(
        fontFamily: NC.font,
        color: NC.textLow,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        fontFamily: NC.font,
        color: NC.textMid,
        fontSize: 14,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: NC.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        textStyle: NC.label(16),
      ),
    ),
    dividerTheme: const DividerThemeData(
        color: NC.cardBorder, thickness: 1, space: 1),
  );
}

// ═══════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════

/// Professional card with subtle shadow and border
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double radius;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.radius = 18,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: NC.surface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor ?? NC.cardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Gradient button
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final LinearGradient gradient;
  final IconData? icon;
  final double height;
  final bool loading;

  const GradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.gradient = NC.primaryGrad,
    this.icon,
    this.height = 56,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: loading
              ? const LinearGradient(colors: [NC.textLow, NC.textLow])
              : gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: loading
              ? null
              : [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
              ],
              Text(label,
                  style: NC.label(16, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Status badge — high visibility
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (color, label) = _resolve(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: NC.label(11, color: color, weight: FontWeight.w700)),
    );
  }

  (Color, String) _resolve(String s) {
    switch (s) {
      case 'pending':
      case 'pending_assignment':
        return (NC.warning, 'قيد الانتظار');
      case 'assigned':
        return (NC.primary, 'مُعيَّن');
      case 'on_mission':
      case 'in_progress':
      case 'OnMission':
        return (NC.success, 'في الطريق');
      case 'arrived':
        return (const Color(0xFF00C2FF), 'وصل للمريض');
      case 'to_hospital':
      case 'onTheWayToHospital':
        return (const Color(0xFFBB86FC), 'للمستشفى');
      case 'completed':
        return (NC.success, 'مكتمل');
      case 'cancelled':
      case 'duplicate':
        return (NC.textLow, 'ملغى');
      default:
        return (NC.textLow, s);
    }
  }
}

/// Empty state
class NajdaEmpty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const NajdaEmpty(
      {super.key, required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: NC.overlay,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: NC.textLow),
          ),
          const SizedBox(height: 20),
          Text(title, style: NC.display(16), textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!,
                style: NC.body(13), textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

/// Loading spinner
class NajdaSpinner extends StatelessWidget {
  final String? label;
  const NajdaSpinner({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(NC.primary),
            strokeWidth: 2.5,
          ),
          if (label != null) ...[
            const SizedBox(height: 16),
            Text(label!, style: NC.body(14)),
          ],
        ],
      ),
    );
  }
}

/// Section header
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: NC.display(15)),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!, style: NC.label(13, color: NC.primary)),
          ),
      ],
    );
  }
}
