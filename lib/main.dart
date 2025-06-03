import 'package:ac_smart/viewmodels/atividades_viewmodel.dart';
import 'package:ac_smart/viewmodels/homepage_viewmodel.dart';
import 'package:ac_smart/viewmodels/login_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:ac_smart/routes.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AtividadeProvider()),
        ChangeNotifierProvider(create: (context) => HomepageProvider()),
        ChangeNotifierProvider(create: (context) => LoginProvider()),
      ],
      child: const TokenWrapper(),
    ),
  );
}

class TokenWrapper extends StatelessWidget {
  const TokenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
      builder: (context, loginProvider, _) {
        final isLogged = context.watch<LoginProvider>().isLoggedIn;
        return MyApp(isLoggedIn: isLogged);
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  get _router => Routes(isLoggedIn: isLoggedIn).router;
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
