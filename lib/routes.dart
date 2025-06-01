import 'package:ac_smart/models/activity_model.dart';
import 'package:ac_smart/views/atividade/atividades.dart';
import 'package:ac_smart/views/atividade/editar_atividade.dart';
import 'package:ac_smart/views/atividade/home_page.dart';
import 'package:ac_smart/views/login.dart';
import 'package:ac_smart/views/atividade/nova_atividade.dart';
import 'package:go_router/go_router.dart';

class Routes {
  final String token;
  late final GoRouter _router;

  Routes({required this.token}) {
    _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              token.isEmpty ? const ACSMartLogin() : const HomePage(),
        ),
        GoRoute(
            path: '/activities',
            builder: (context, state) => const Activities(),
            routes: [
              GoRoute(
                path: 'details',
                builder: (context, state) {
                  final atividade = state.extra as Activity;
                  return EditarAtividade(atividade: atividade);
                },
              ),
            ]),
        GoRoute(
          path: '/new_activity',
          builder: (context, state) => const InserirAtividade(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const ACSMartLogin(),
        ),
      ],
    );
  }

  GoRouter get router => _router;
}
