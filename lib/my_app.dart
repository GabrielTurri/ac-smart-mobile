import 'package:ac_smart/pages/activities.dart';
import 'package:ac_smart/pages/dashboard.dart';
import 'package:ac_smart/pages/login.dart';
import 'package:ac_smart/pages/reproved_activities.dart';
import 'package:ac_smart/pages/ui/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final _router = GoRouter(routes: [
  ShellRoute(
      routes: [
        GoRoute(
          path: '/',
          // path: '/profle/:userid?filter=xyz',
          builder: (context, state) => const Dashboard(),
          // ProfileScreen(
          //  userId: state.params['userId'],
          //  userId: state.queryParams[filter]
          // )
        ),
        GoRoute(
          path: '/activities',
          builder: (context, state) => Activities(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const ACSMartLogin(),
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

  // void initSate() {
  //   super.initSate();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Icon(
          Icons.note_add,
          color: Colors.white,
        ),
        backgroundColor: const Color(0xff043565),
      ),
      body: PageView(
        controller: pageController,
        children: const [
          Dashboard(),
          Activities(),
          ReprovedActivities(),
        ],
      ),
      bottomNavigationBar:
          ACSmartNavigationBar(currentSelectedNavigation: currentPage),
    );
  }
}
