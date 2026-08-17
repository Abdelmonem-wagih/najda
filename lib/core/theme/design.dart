import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════
// NAJDA V2 — Design System
// Direction: Medical-grade dark command center. Navy-black base,
// electric teal accent, critical red for emergencies.
// Signature: Frosted glass cards over dark gradient backgrounds.
// ═══════════════════════════════════════════════════════════════════

class NC {
  NC._();

  // ── Palette ────────────────────────────────────────────────────────
  static const Color base        = Color(0xFF050F1A); // near-black navy
  static const Color surface     = Color(0xFF0B1929); // dark navy
  static const Color card        = Color(0xFF0F2236); // card bg
  static const Color cardBorder  = Color(0xFF1E3A52); // subtle border
  static const Color overlay     = Color(0xFF162D44); // hover/pressed

  static const Color primary     = Color(0xFF00C2FF); // electric teal/cyan
  static const Color primaryDim  = Color(0xFF006D8F); // muted teal
  static const Color critical    = Color(0xFFFF3B55); // vivid red
  static const Color criticalDim = Color(0xFF7A1120); // muted red
  static const Color warning     = Color(0xFFFFB800); // amber
  static const Color success     = Color(0xFF00E096); // mint green

  static const Color textHigh    = Color(0xFFF0F7FF); // primary text
  static const Color textMid     = Color(0xFF8FAEC8); // secondary text
  static const Color textLow     = Color(0xFF3D6280); // disabled/hint

  // ── Gradients ──────────────────────────────────────────────────────
  static const LinearGradient bgGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF050F1A), Color(0xFF081624)],
  );

  static const LinearGradient primaryGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C2FF), Color(0xFF0074FF)],
  );

  static const LinearGradient criticalGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF3B55), Color(0xFFD4003C)],
  );

  static const LinearGradient successGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00E096), Color(0xFF00A86B)],
  );

  static const LinearGradient cardGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F2236), Color(0xFF0B1929)],
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
        fontFamily: 'PlusJakartaSans',
        color: Color(0xFFF0F7FF),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      );
}

// ═══════════════════════════════════════════════════════════════════
// THEME
// ═══════════════════════════════════════════════════════════════════
class NajdaTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    fontFamily: NC.font,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: NC.base,
    colorScheme: const ColorScheme.dark(
      primary: NC.primary,
      secondary: NC.success,
      error: NC.critical,
      surface: NC.surface,
      onPrimary: NC.base,
      onSurface: NC.textHigh,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: NC.display(17, weight: FontWeight.w700),
      iconTheme: const IconThemeData(color: NC.textHigh),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0F2236),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1E3A52), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1E3A52), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF00C2FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF3B55)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF3B55), width: 1.5),
      ),
      hintStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        color: Color(0xFF3D6280),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        color: Color(0xFF8FAEC8),
        fontSize: 14,
      ),
      errorStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        color: Color(0xFFFF3B55),
        fontSize: 12,
      ),
      prefixIconColor: Color(0xFF00C2FF),
      suffixIconColor: Color(0xFF3D6280),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: NC.primary,
        foregroundColor: NC.base,
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

/// Glassmorphism card with dark base
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
          gradient: NC.cardGrad,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor ?? NC.cardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Gradient button (full-width or custom size)
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
              color: gradient.colors.first.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
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
              valueColor: AlwaysStoppedAnimation(NC.textHigh),
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: NC.base, size: 20),
                const SizedBox(width: 10),
              ],
              Text(label,
                  style: NC.label(16,
                      color: gradient == NC.criticalGrad
                          ? Colors.white
                          : NC.base)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Status badge — dark variant
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (color, label) = _resolve(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
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
      case 'in_progress':
      case 'OnMission':
        return (NC.success, 'جارٍ');
      case 'arrived':
        return (NC.primary, 'وصل');
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
              color: NC.card,
              shape: BoxShape.circle,
              border: Border.all(color: NC.cardBorder),
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