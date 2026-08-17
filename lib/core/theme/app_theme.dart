import 'package:flutter/material.dart';

/// Najda Design System — mirrors the web dashboard palette
class NajdaColors {
  NajdaColors._();

  // Core Brand
  static const Color navy       = Color(0xFF0C2340);
  static const Color primary    = Color(0xFF185FA5);
  static const Color accent     = Color(0xFF378ADD);
  static const Color critical   = Color(0xFFE24B4A);

  // Neutrals
  static const Color surface    = Color(0xFFF5F7FA);
  static const Color cardBg     = Color(0xFFFFFFFF);
  static const Color border     = Color(0xFFE2E8F0);
  static const Color textPrimary   = Color(0xFF0C2340);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted     = Color(0xFF94A3B8);

  // Status
  static const Color success    = Color(0xFF22C55E);
  static const Color warning    = Color(0xFFF59E0B);
  static const Color info       = Color(0xFF378ADD);

  // Gradients
  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0C2340), Color(0xFF185FA5)],
  );

  static const LinearGradient criticalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE24B4A), Color(0xFFC0392B)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF185FA5), Color(0xFF378ADD)],
  );
}

class NajdaTheme {
  NajdaTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: NajdaColors.primary,
        secondary: NajdaColors.accent,
        error: NajdaColors.critical,
        surface: NajdaColors.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: NajdaColors.textPrimary,
      ),
      scaffoldBackgroundColor: NajdaColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: NajdaColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: NajdaColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: NajdaColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NajdaColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NajdaColors.primary,
          side: const BorderSide(color: NajdaColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: NajdaColors.primary,
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NajdaColors.cardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NajdaColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NajdaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NajdaColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NajdaColors.critical),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NajdaColors.critical, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Cairo',
          color: NajdaColors.textSecondary,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Cairo',
          color: NajdaColors.textMuted,
          fontSize: 14,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: NajdaColors.cardBg,
        selectedItemColor: NajdaColors.primary,
        unselectedItemColor: NajdaColors.textMuted,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: NajdaColors.surface,
        selectedColor: NajdaColors.primary.withOpacity(0.12),
        labelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: NajdaColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: NajdaColors.border,
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: NajdaColors.textPrimary),
        displayMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: NajdaColors.textPrimary),
        displaySmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: NajdaColors.textPrimary),
        headlineLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 24, color: NajdaColors.textPrimary),
        headlineMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 20, color: NajdaColors.textPrimary),
        headlineSmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 18, color: NajdaColors.textPrimary),
        titleLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 16, color: NajdaColors.textPrimary),
        titleMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 14, color: NajdaColors.textPrimary),
        titleSmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w500, fontSize: 12, color: NajdaColors.textPrimary),
        bodyLarge: TextStyle(fontFamily: 'Cairo', fontSize: 16, color: NajdaColors.textPrimary),
        bodyMedium: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: NajdaColors.textPrimary),
        bodySmall: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: NajdaColors.textSecondary),
        labelLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 14, color: NajdaColors.textPrimary),
        labelMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w500, fontSize: 12, color: NajdaColors.textSecondary),
        labelSmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w500, fontSize: 11, color: NajdaColors.textMuted),
      ),
    );
  }
}

// ─── Shared UI Helpers ──────────────────────────────────────────────────────

/// Status badge used across citizen history & paramedic views
class NajdaStatusBadge extends StatelessWidget {
  final String status;
  const NajdaStatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (color, label) = _resolve(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  (Color, String) _resolve(String s) {
    switch (s) {
      case 'pending':           return (NajdaColors.warning, 'قيد الانتظار');
      case 'pending_assignment':return (NajdaColors.warning, 'قيد التعيين');
      case 'assigned':          return (NajdaColors.info, 'مُعيَّن');
      case 'in_progress':       return (NajdaColors.primary, 'جارٍ');
      case 'OnMission':         return (NajdaColors.primary, 'في مهمة');
      case 'arrived':           return (NajdaColors.accent, 'وصل');
      case 'onTheWayToHospital':return (const Color(0xFF9C27B0), 'للمستشفى');
      case 'completed':         return (NajdaColors.success, 'مكتمل');
      case 'available':         return (NajdaColors.success, 'متاح');
      case 'unavailable':       return (NajdaColors.textMuted, 'غير متاح');
      case 'cancelled':         return (NajdaColors.critical, 'ملغى');
      case 'duplicate':         return (NajdaColors.textMuted, 'مكرر');
      default:                  return (NajdaColors.textMuted, s);
    }
  }
}

/// Gradient card used in home screen quick-actions
class NajdaGradientCard extends StatelessWidget {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final double? iconSize;

  const NajdaGradientCard({
    super.key,
    required this.gradient,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: iconSize ?? 32),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Simple info card (white with border)
class NajdaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const NajdaCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NajdaColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NajdaColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Loading overlay
class NajdaLoader extends StatelessWidget {
  final String? message;
  const NajdaLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(NajdaColors.primary),
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: NajdaColors.textSecondary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty state widget
class NajdaEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const NajdaEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: NajdaColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: NajdaColors.primary.withOpacity(0.6)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: NajdaColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: NajdaColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
