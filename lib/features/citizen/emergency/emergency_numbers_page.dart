import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/design.dart';

// ═══════════════════════════════════════════════════════════════════
// EMERGENCY NUMBERS PAGE  — redesigned premium UI
// ═══════════════════════════════════════════════════════════════════

class EmergencyNumbersPage extends StatelessWidget {
  const EmergencyNumbersPage({super.key});

  static const _numbers = [
    _EmergencyEntry(
      label: 'الإسعاف',
      number: '123',
      icon: Icons.local_hospital_rounded,
      color: Color(0xFFFF3B55),
      subtitle: 'للحوادث والإصابات',
      isPrimary: true,
    ),
    _EmergencyEntry(
      label: 'الشرطة',
      number: '122',
      icon: Icons.shield_rounded,
      color: Color(0xFF378ADD),
      subtitle: 'للجرائم والأمن',
    ),
    _EmergencyEntry(
      label: 'الإطفاء',
      number: '180',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFF97316),
      subtitle: 'للحرائق والإنقاذ',
    ),
    _EmergencyEntry(
      label: 'الدفاع المدني',
      number: '125',
      icon: Icons.security_rounded,
      color: Color(0xFF00E096),
      subtitle: 'للكوارث والإنقاذ',
    ),
    _EmergencyEntry(
      label: 'الطوارئ الموحد',
      number: '112',
      icon: Icons.phone_in_talk_rounded,
      color: Color(0xFF00C2FF),
      subtitle: 'رقم طوارئ عالمي',
    ),
    _EmergencyEntry(
      label: 'نجدة الطفل',
      number: '16000',
      icon: Icons.child_care_rounded,
      color: Color(0xFFBB86FC),
      subtitle: 'لحماية الطفل',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NC.base,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: NC.card.withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(color: NC.cardBorder),
            ),
            child: const Icon(Icons.arrow_back_ios_rounded,
                color: NC.textHigh, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('أرقام الطوارئ', style: NC.display(18)),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // ── Top spacing for app bar ─────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 110)),

          // ── Hero SOS card ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SosHeroCard(entry: _numbers[0]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Section title ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: NC.primaryGrad,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('أرقام الطوارئ الأخرى',
                      style: NC.label(14, color: NC.textMid)),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          // ── Grid of remaining numbers ───────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _NumberCard(entry: _numbers[i + 1]),
                childCount: _numbers.length - 1,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
            ),
          ),

          // ── Tip banner ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NC.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: NC.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: NC.warning.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.lightbulb_rounded,
                          color: NC.warning, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'اضغط مطولاً على أي رقم لنسخه، أو اضغط للاتصال المباشر',
                        style: NC.body(12, color: NC.textMid),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SOS Hero Card ────────────────────────────────────────────────
class _SosHeroCard extends StatefulWidget {
  final _EmergencyEntry entry;
  const _SosHeroCard({required this.entry});

  @override
  State<_SosHeroCard> createState() => _SosHeroCardState();
}

class _SosHeroCardState extends State<_SosHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _call() async {
    final uri = Uri.parse('tel:${widget.entry.number}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _call,
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: widget.entry.number));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم نسخ ${widget.entry.number}',
                style: NC.body(13, color: NC.textHigh)),
            backgroundColor: NC.surface,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.entry.color,
                widget.entry.color.withOpacity(0.6),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.entry.color.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern circles
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                right: 30,
                bottom: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.35), width: 1.5),
                      ),
                      child: Icon(widget.entry.icon,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.entry.label,
                              style: NC.display(22,
                                  color: Colors.white,
                                  weight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(widget.entry.subtitle,
                              style:
                                  NC.body(13, color: Colors.white70)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.phone_rounded,
                                    color: widget.entry.color, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  widget.entry.number,
                                  style: TextStyle(
                                    fontFamily: NC.font,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: widget.entry.color,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.call_rounded,
                        color: Colors.white54, size: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Regular number card ─────────────────────────────────────────
class _NumberCard extends StatefulWidget {
  final _EmergencyEntry entry;
  const _NumberCard({required this.entry});

  @override
  State<_NumberCard> createState() => _NumberCardState();
}

class _NumberCardState extends State<_NumberCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  Future<void> _call() async {
    final uri = Uri.parse('tel:${widget.entry.number}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: widget.entry.number));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم نسخ ${widget.entry.number}',
                style: NC.body(13, color: NC.textHigh)),
            backgroundColor: NC.surface,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _pressed ? NC.overlay : NC.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _pressed
                  ? widget.entry.color.withOpacity(0.5)
                  : widget.entry.color.withOpacity(0.22),
              width: _pressed ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.entry.color.withOpacity(_pressed ? 0.2 : 0.08),
                blurRadius: _pressed ? 20 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: widget.entry.color.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: widget.entry.color.withOpacity(0.3),
                        width: 1.5),
                  ),
                  child:
                      Icon(widget.entry.icon, color: widget.entry.color, size: 26),
                ),
                const SizedBox(height: 12),

                // Label
                Text(
                  widget.entry.label,
                  style: NC.label(14,
                      color: NC.textHigh, weight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // Subtitle
                Text(
                  widget.entry.subtitle,
                  style: NC.body(10, color: NC.textMid),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Number badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.entry.color.withOpacity(0.25),
                        widget.entry.color.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: widget.entry.color.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone_rounded,
                          color: widget.entry.color, size: 12),
                      const SizedBox(width: 5),
                      Text(
                        widget.entry.number,
                        style: TextStyle(
                          fontFamily: NC.font,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: widget.entry.color,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Data model ───────────────────────────────────────────────────
class _EmergencyEntry {
  final String label;
  final String number;
  final IconData icon;
  final Color color;
  final String subtitle;
  final bool isPrimary;

  const _EmergencyEntry({
    required this.label,
    required this.number,
    required this.icon,
    required this.color,
    required this.subtitle,
    this.isPrimary = false,
  });
}
