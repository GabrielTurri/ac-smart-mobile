import 'package:ac_smart/pages/activities.dart';
import 'package:ac_smart/pages/home_page.dart';
import 'package:ac_smart/pages/login.dart';
import 'package:ac_smart/pages/activity_details.dart';
import 'package:go_router/go_router.dart';

class Routes {
  final _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        // path: '/profile/:userid?filter=xyz',
        builder: (context, state) => const HomePage(),
        // ProfileScreen(
        //  userId: state.params['userId'],
        //  userId: state.queryParams[filter]
        // )
      ),
      GoRoute(
          path: '/activities',
          builder: (context, state) => const Activities(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id']!);
                return ActivityDetails(id: id);
              },
            ),
            GoRoute(
              path: 'new',
              builder: (context, state) => const ActivityDetails(),
            ),
          ]),
      GoRoute(
        path: '/login',
        builder: (context, state) => const ACSMartLogin(),
      ),
    ],
  );
  GoRouter get router => _router;
}
