import 'package:ac_smart/viewmodels/homepage_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatelessWidget {
  Dashboard({super.key});
  late String nomeUsuario;
  late HomepageProvider homepageProvider;

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navegar para a tela de login e remover as rotas anteriores
    // ignore: use_build_context_synchronously
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    homepageProvider = context.read<HomepageProvider>();
    nomeUsuario = context.watch<HomepageProvider>().nomeUsuario;
    homepageProvider.lerNomeUsuario();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff043565),
        leading: IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            )),
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      // drawer: appDrawer(),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      'Boas vindas, $nomeUsuario!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: dashboardPanelDecoration(),
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              width: 1, color: const Color(0xff496F93)),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(100))),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('Entregues'),
                        Text('Restantes'),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration dashboardPanelDecoration() {
    return BoxDecoration(
      border: Border.all(
        width: 1,
        color: const Color(0xff496F93),
      ),
      color: const Color(0xffF7FBFF),
      borderRadius: BorderRadius.circular(24),
    );
  }
}
