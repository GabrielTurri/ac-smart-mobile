import 'package:ac_smart/viewmodels/homepage_viewmodel.dart';
import 'package:ac_smart/views/atividade/ui/app_bar.dart';
import 'package:ac_smart/views/atividade/ui/app_drawer.dart';
import 'package:ac_smart/viewmodels/login_viewmodel.dart';
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
      appBar: const ACSmartAppBar(
        title: 'Dashboard',
      ),
      drawer: appDrawer(),
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
                      'Boas vindas, $nomeUsuario',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Nome do curso',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
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
              const SizedBox(height: 26),
              Container(
                decoration: dashboardPanelDecoration(),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          LoginProvider().fazerLogin(context);
                        },
                        style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xff476988),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: const Text("Fazer Login"),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => _logout(context),
                        style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xff476988),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: const Text("Fazer Logout"),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xff476988),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Entregar AC's"),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          context.push('/activities');
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xff476988),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Reprovadas'),
                      ),
                    )
                  ],
                ),
              )
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
