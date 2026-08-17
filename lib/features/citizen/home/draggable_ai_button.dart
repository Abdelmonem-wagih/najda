import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/route/app_routes.dart';
import '../../../core/theme/design.dart';

// ─── Global route notifier ────────────────────────────────────────
// Updated by [NajdaRouteObserver] so DraggableAiButton can react to
// route changes without being rebuilt by the whole widget tree.
final ValueNotifier<String?> currentRouteNotifier = ValueNotifier<String?>(null);

class NajdaRouteObserver extends NavigatorObserver {
  void _update(Route? route) {
    currentRouteNotifier.value = route?.settings.name;
  }

  @override
  void didPush(Route route, Route? previousRoute) => _update(route);
  @override
  void didPop(Route route, Route? previousRoute) => _update(previousRoute);
  @override
  void didReplace({Route? newRoute, Route? oldRoute}) => _update(newRoute);
  @override
  void didRemove(Route route, Route? previousRoute) => _update(previousRoute);
}

/// Draggable AI assistant button — floats over all citizen screens.
/// Automatically hides itself when the AI chat page is open.
/// User can drag it anywhere on screen; tap opens AiChatPage.
class DraggableAiButton extends StatefulWidget {
  const DraggableAiButton({super.key});

  @override
  State<DraggableAiButton> createState() => _DraggableAiButtonState();
}

class _DraggableAiButtonState extends State<DraggableAiButton>
    with SingleTickerProviderStateMixin {
  double _right = 20;
  double _bottom = 100;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ValueListenableBuilder<String?>(
      valueListenable: currentRouteNotifier,
      builder: (_, route, child) {
        // Hide when user is already on the AI chat page
        if (route == AppRoutes.aiChat) return const SizedBox.shrink();
        return child!;
      },
      child: Positioned(
        right: _right,
        bottom: _bottom,
        child: GestureDetector(
          // Drag to reposition
          onPanUpdate: (d) {
            setState(() {
              _right = (_right - d.delta.dx).clamp(0.0, size.width - 64);
              _bottom = (_bottom - d.delta.dy).clamp(0.0, size.height - 64);
            });
          },
          // Tap to open chat
          onTap: () {
            AppRouter.navigatorKey.currentState?.pushNamed(AppRoutes.aiChat);
          },
          child: ScaleTransition(
            scale: _pulse,
            child: SvgPicture.asset(
              'assets/svg/chatBot.svg',
              width: 80,
              height: 80,
            ),
          ),
        ),
      ),
    );
  }
}
