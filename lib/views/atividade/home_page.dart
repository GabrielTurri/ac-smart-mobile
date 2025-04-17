import 'package:ac_smart/models/activity.dart';
import 'package:ac_smart/viewmodels/homepage_viewmodel.dart';
import 'package:ac_smart/views/atividade/atividades.dart';
import 'package:ac_smart/views/atividade/dashboard.dart';
import 'package:ac_smart/viewmodels/atividades_viewmodel.dart';
import 'package:ac_smart/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    HomepageProvider homepage = context.watch<HomepageProvider>();
    HomepageProvider homepageProvider = context.read<HomepageProvider>();

    List<Activity> atividades = context.watch<AtividadeProvider>().atividades;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/new_activity');
        },
        icon: const Icon(
          Icons.note_add,
          color: Colors.white,
        ),
        label: const Text(
          'Nova Atividade',
          style: TextStyle(color: Colors.white),
        ),
        tooltip: 'Criar atividade',
        backgroundColor: const Color(0xff043565),
      ),
      body: PageView(
        controller: homepage.pageController,
        onPageChanged: homepageProvider.setPaginaAtual,
        children: const [
          Dashboard(),
          Activities(),
          Activities(isReproved: true),
        ],
      ),
      bottomNavigationBar:
          ACSmartNavigationBar(homepage: homepage, atividades: atividades),
    );
  }
}
