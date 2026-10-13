import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/design.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../home/paramedic_home_page.dart';
import '../../notifications/notifications_history_page.dart';

class AmbulanceMainScaffold extends StatefulWidget {
  const AmbulanceMainScaffold({super.key});

  @override
  State<AmbulanceMainScaffold> createState() => _AmbulanceMainScaffoldState();
}

class _AmbulanceMainScaffoldState extends State<AmbulanceMainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AmbulanceHomePage(),
    const NotificationsHistoryPage(showHistory: true),
    const NotificationsHistoryPage(showHistory: false),
    const _AmbulanceProfilePlaceholder(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: NC.surface,
          selectedItemColor: NC.primary,
          unselectedItemColor: NC.textLow,
          selectedLabelStyle: NC.label(12),
          unselectedLabelStyle: NC.label(12),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home_rounded),
              label: l10n.homeTab,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history_outlined),
              activeIcon: const Icon(Icons.history_rounded),
              label: l10n.historyTab,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.notifications_outlined),
              activeIcon: const Icon(Icons.notifications_rounded),
              label: l10n.notificationsTab,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline_rounded),
              activeIcon: const Icon(Icons.person_rounded),
              label: l10n.profileTab,
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbulanceProfilePlaceholder extends StatelessWidget {
  const _AmbulanceProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    final user = (context.watch<AuthCubit>().state as AuthAuthenticated).user;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: NC.base,
      appBar: AppBar(
        title: Text(l10n.profileTab),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: NC.critical),
            onPressed: () {
              context.read<AuthCubit>().signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<AuthCubit>().checkAuthStatus();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: NC.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: NC.primary, width: 2),
                ),
                child: const Icon(Icons.person_rounded, size: 60, color: NC.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(user.fullName, style: NC.display(20)),
            Text(user.email ?? user.phone ?? '', style: NC.body(14)),
            const SizedBox(height: 32),
            GlassCard(
              child: Column(
                children: [
                  _ProfileItem(
                    icon: Icons.badge_outlined,
                    label: 'الرقم الوظيفي',
                    value: user.id.length > 8 
                        ? user.id.substring(0, 8).toUpperCase()
                        : user.id.toUpperCase(),
                  ),
                  const Divider(),
                  _ProfileItem(
                    icon: Icons.car_crash,
                    label: 'رقم المركبة',
                    value: user.currentAmbulanceId ?? 'غير محدد',
                  ),
                ],
              ),
            ),


            ]
        ),
      ),
    ));
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: NC.textMid, size: 20),
          const SizedBox(width: 12),
          Text(label, style: NC.body(14)),
          const Spacer(),
          Text(value, style: NC.label(14, color: NC.textHigh)),
        ],
      ),
    );
  }
}
