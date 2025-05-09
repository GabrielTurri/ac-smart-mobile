import 'package:ac_smart/views/atividade/atividades.dart';
import 'package:ac_smart/views/atividade/home_page.dart';
import 'package:ac_smart/views/login.dart';
import 'package:ac_smart/views/atividade/activity_details.dart';
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
                String? id = state.pathParameters['id'];
                id ??= '';
                return ActivityDetails(id: id);
              },
            ),
          ]),
      GoRoute(
        path: '/new_activity',
        builder: (context, state) => const ActivityDetails(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const ACSMartLogin(),
      ),
    ],
  );
  GoRouter get router => _router;
}
