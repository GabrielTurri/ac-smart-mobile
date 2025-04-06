import 'package:ac_smart/pages/activities.dart';
import 'package:ac_smart/pages/dashboard.dart';
import 'package:ac_smart/pages/login.dart';
import 'package:ac_smart/pages/reproved_activities.dart';
import 'package:ac_smart/pages/ui/activity_details.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final _router = GoRouter(routes: [
  ShellRoute(
      routes: [
        GoRoute(
          path: '/',
          // path: '/profile/:userid?filter=xyz',
          builder: (context, state) => const Dashboard(),
          // ProfileScreen(
          //  userId: state.params['userId'],
          //  userId: state.queryParams[filter]
          // )
        ),
        GoRoute(
          path: '/activities',
          builder: (context, state) => const Activities(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const ACSMartLogin(),
        ),
        GoRoute(
          path: '/activities/new',
          builder: (context, state) => const ActivityDetails(),
        ),
      ],
      builder: (context, state, child) {
        return HomePage();
      })
]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AC Smart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({super.key});

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
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/login');
        },
        label: const Icon(
          Icons.note_add,
          color: Colors.white,
        ),
        backgroundColor: const Color(0xff043565),
      ),
      body: PageView(
        controller: pageController,
        children: [
          Dashboard(),
          Activities(),
          ReprovedActivities(),
        ],
        onPageChanged: setPaginaAtual,
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
          destinations: const [
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
              icon: Icon(Icons.cancel_schedule_send_outlined,
                  color: Colors.white),
              selectedIcon:
                  Icon(Icons.cancel_schedule_send, color: Colors.white),
              label: 'Reprovadas',
            ),
          ],
          selectedIndex: currentPage,
        ),
      ),
    );
  }
}
