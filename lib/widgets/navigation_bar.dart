import 'package:ac_smart/models/activity_model.dart';
import 'package:ac_smart/viewmodels/homepage_viewmodel.dart';
import 'package:flutter/material.dart';

class ACSmartNavigationBar extends StatelessWidget {
  const ACSmartNavigationBar({
    super.key,
    required this.homepage,
    required this.atividades,
  });

  final HomepageProvider homepage;
  final List<Activity> atividades;

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
        (Set<WidgetState> states) => states.contains(WidgetState.selected)
            ? const TextStyle(color: Color(0xffFF9432))
            : const TextStyle(color: Colors.white),
      )),
      child: NavigationBar(
        backgroundColor: const Color(0xff043565),
        indicatorColor: const Color(0xffFF9432),
        onDestinationSelected: (pagina) {
          homepage.pageController.animateToPage(
            pagina,
            duration: const Duration(milliseconds: 400),
            curve: Curves.ease,
          );
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, color: Colors.white),
            selectedIcon: Icon(Icons.dashboard, color: Colors.white),
            label: 'Dashboard',
          ),
          const NavigationDestination(
            icon: Icon(Icons.view_list_outlined, color: Colors.white),
            selectedIcon: Icon(Icons.view_list, color: Colors.white),
            label: 'Minhas ACs',
          ),
          NavigationDestination(
            icon: Badge.count(
              count: atividades.where((a) => a.status == "Reprovada").length,
              backgroundColor: const Color(0xffFF9432),
              child: const Icon(Icons.cancel_schedule_send_outlined,
                  color: Colors.white),
            ),
            selectedIcon:
                const Icon(Icons.cancel_schedule_send, color: Colors.white),
            label: 'Reprovadas',
          ),
        ],
        selectedIndex: homepage.currentPage,
      ),
    );
  }
}
