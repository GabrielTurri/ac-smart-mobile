import 'package:ac_smart/viewmodels/homepage_viewmodel.dart';
import 'package:ac_smart/views/atividade/ui/app_bar.dart';
import 'package:ac_smart/views/atividade/ui/app_drawer.dart';
import 'package:ac_smart/viewmodels/login_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  Dashboard({super.key});
  late String nomeUsuario;
  late HomepageProvider homepageProvider;

  @override
  Widget build(BuildContext context) {
    homepageProvider = context.read<HomepageProvider>();
    nomeUsuario = context.watch<HomepageProvider>().nomeUsuario;
    
    // Carregar informações do usuário se ainda não estiverem carregadas
    homepageProvider.carregarUsuario();

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
                    Text(
                      homepageProvider.currentUser != null 
                          ? homepageProvider.currentUser!.course.courseName
                          : 'Nome do curso',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text('Entregues', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              homepageProvider.currentUser != null 
                                  ? '${homepageProvider.currentUser!.totalApprovedHours} horas'
                                  : '0 horas',
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Restantes', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              homepageProvider.currentUser != null 
                                  ? '${homepageProvider.currentUser!.course.requiredHours - homepageProvider.currentUser!.totalApprovedHours} horas'
                                  : '0 horas',
                            ),
                          ],
                        ),
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
                        onPressed: () async {
                          final loginProvider = Provider.of<LoginProvider>(context, listen: false);
                          await loginProvider.fazerLogin(context);
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
