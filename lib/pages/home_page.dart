import 'package:ac_smart/pages/activities.dart';
import 'package:ac_smart/pages/dashboard.dart';
import 'package:ac_smart/pages/reproved_activities.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController pageController = PageController(initialPage: 0);

  int currentPage = 0;
  int currentSelectedNavigation = 0;

  setPaginaAtual(pagina) {
    setState(() {
      currentPage = pagina;
    });
  }

  @override
  Widget build(BuildContext context) {
    const destinationsList = [
      NavigationDestination(
        icon: Icon(Icons.dashboard_outlined, color: Colors.white),
        selectedIcon: Icon(Icons.dashboard, color: Colors.white),
        label: 'Dashboard',
      ),
      NavigationDestination(
        icon: Icon(Icons.view_list_outlined, color: Colors.white),
        selectedIcon: Icon(Icons.view_list, color: Colors.white),
        label: 'Minhas ACs',
      ),
      NavigationDestination(
        icon: Icon(Icons.cancel_schedule_send_outlined, color: Colors.white),
        selectedIcon: Icon(Icons.cancel_schedule_send, color: Colors.white),
        label: 'Reprovadas',
      ),
    ];
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/activities/new');
        },
        label: const Icon(
          Icons.note_add,
          color: Colors.white,
        ),
        tooltip: 'Criar atividade',
        backgroundColor: const Color(0xff043565),
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: setPaginaAtual,
        children: const [
          Dashboard(),
          Activities(),
          ReprovedActivities(),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
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
            pageController.animateToPage(
              pagina,
              duration: const Duration(milliseconds: 400),
              curve: Curves.ease,
            );
          },
          destinations: destinationsList,
          selectedIndex: currentPage,
        ),
      ),
    );
  }
}
