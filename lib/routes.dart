import 'package:ac_smart/pages/activities.dart';
import 'package:ac_smart/pages/home_page.dart';
import 'package:ac_smart/pages/login.dart';
import 'package:ac_smart/pages/ui/activity_details.dart';
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
                final id = int.parse(state.pathParameters['id']!);
                return ActivityDetails(activityId: id);
              },
            )
          ]),
      GoRoute(
        path: '/login',
        builder: (context, state) => const ACSMartLogin(),
      ),
      GoRoute(
        path: '/activities/new',
        builder: (context, state) => const ActivityDetails(),
      ),
    ],
  );
  GoRouter get router => _router;
}
