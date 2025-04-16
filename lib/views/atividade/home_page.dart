import 'package:ac_smart/models/activity.dart';
import 'package:ac_smart/viewmodels/homepage_viewmodel.dart';
import 'package:ac_smart/views/atividade/atividades.dart';
import 'package:ac_smart/views/atividade/dashboard.dart';
import 'package:ac_smart/viewmodels/atividades_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    HomepageProvider homepage = context.watch<HomepageProvider>();
    HomepageProvider pagina = context.read<HomepageProvider>();

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
        onPageChanged: pagina.setPaginaAtual,
        children: const [
          Dashboard(),
          Activities(),
          Activities(isReproved: true),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? const TextStyle(color: Color(0xffFF9432))
              : const TextStyle(color: Colors.white),
        )),
        child: NavigationBar(
          backgroundColor: const Color(0xff043565),
          indicatorColor: const Color(0xffFF9432),
          onDestinationSelected: (pagina) {
            homepage.pageController.animateToPage(
              pagina,
              duration: const Duration(milliseconds: 400),
              curve: Curves.ease,
            );
          },
          destinations: pagina.destinationsList,
          selectedIndex: homepage.currentPage,
        ),
      ),
    );
  }
}
