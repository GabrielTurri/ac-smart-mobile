import 'package:ac_smart/viewmodels/atividades_viewmodel.dart';
import 'package:ac_smart/viewmodels/homepage_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:ac_smart/routes.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AtividadeProvider()),
        ChangeNotifierProxyProvider<AtividadeProvider, HomepageProvider>(
            create: (context) => HomepageProvider(
                  atividadeProvider: AtividadeProvider(),
                ),
            update: (context, atividadeProvider, previous) =>
                HomepageProvider(atividadeProvider: atividadeProvider))
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  get _router => Routes().router;
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
