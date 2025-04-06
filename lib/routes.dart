import 'package:ac_smart/pages/activities.dart';
import 'package:ac_smart/pages/dashboard.dart';
import 'package:ac_smart/pages/home_page.dart';
import 'package:ac_smart/pages/login.dart';
import 'package:ac_smart/pages/ui/activity_details.dart';
import 'package:go_router/go_router.dart';

class Routes {
  final _router = GoRouter(
    routes: [
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
            return const HomePage();
          })
    ],
  );
  GoRouter get router => _router;
}
