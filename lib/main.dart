import 'package:ac_smart/viewmodels/atividades_viewmodel.dart';
import 'package:ac_smart/viewmodels/homepage_viewmodel.dart';
import 'package:ac_smart/viewmodels/login_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:ac_smart/routes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        return FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const MaterialApp(home: CircularProgressIndicator());
            }

            final token = snapshot.data!.getString('token') ?? '';
            return MyApp(token: token);
          },
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.token});

  final String token;

  get _router => Routes(token: token).router;
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
