import 'package:flutter/material.dart';

import '../../../core/route/app_routes.dart';
import '../../../core/theme/app_colors.dart';

final ValueNotifier<String?> currentRouteNotifier =
    ValueNotifier<String?>(null);

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
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.1).animate(
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
        // Hide button when AI Chat is open
        if (route == AppRoutes.aiChat) return const SizedBox.shrink();
        return child!;
      },
      child: Positioned(
        right: _right,
        bottom: _bottom,
        child: GestureDetector(
          onPanUpdate: (d) {
            setState(() {
              _right = (_right - d.delta.dx).clamp(0.0, size.width - 70);
              _bottom = (_bottom - d.delta.dy).clamp(20.0, size.height - 100);
            });
          },
          onTap: () {
            AppRouter.navigatorKey.currentState?.pushNamed(AppRoutes.aiChat);
          },
          child: ScaleTransition(
            scale: _pulse,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                    color: AppColors.primaryBlue, width: 2),
              ),
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                'assets/svg/bot.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
