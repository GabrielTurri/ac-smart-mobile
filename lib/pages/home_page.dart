import 'package:ac_smart/models/activity.dart';
import 'package:ac_smart/pages/activities.dart';
import 'package:ac_smart/pages/dashboard.dart';
import 'package:ac_smart/pages/reproved_activities.dart';
import 'package:ac_smart/pages/view_model/vm_activities.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController pageController = PageController(initialPage: 0);
  int currentPage = 0;
  int currentSelectedNavigation = 0;

  setPaginaAtual(pagina) {
    setState(() {
      currentPage = pagina;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Activity> atividades = context.watch<AtividadeProvider>().atividades;

    final destinationsList = [
      const NavigationDestination(
        icon: Icon(Icons.dashboard_outlined, color: Colors.white),
        selectedIcon: Icon(Icons.dashboard, color: Colors.white),
        label: 'Dashboard',
      ),
      const NavigationDestination(
        icon: Icon(Icons.view_list_outlined, color: Colors.white),
        selectedIcon: Icon(Icons.view_list, color: Colors.white),
        label: 'Minhas ACs',
      ),
      NavigationDestination(
        icon: Badge.count(
          count: atividades.where((a) => a.status == "Reprovada").length,
          backgroundColor: const Color(0xffFF9432),
          child: const Icon(Icons.cancel_schedule_send_outlined,
              color: Colors.white),
        ),
        selectedIcon:
            const Icon(Icons.cancel_schedule_send, color: Colors.white),
        label: 'Reprovadas',
      ),
    ];
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // context.push('/activities/new');
          Activity novaAtividade = Activity(
            id: Provider.of<AtividadeProvider>(context, listen: false)
                    .atividades
                    .last
                    .id +
                1,
            descricao: 'Teste inserção atividade',
            horasSolicitadas: 4,
            status: 'Aprovada',
            dataAtividade: DateTime(2025, 04),
          );
          context.read<AtividadeProvider>().adicionarAtividade(novaAtividade);
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
        controller: pageController,
        onPageChanged: setPaginaAtual,
        children: const [
          Dashboard(),
          Activities(),
          ReprovedActivities(),
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
            pageController.animateToPage(
              pagina,
              duration: const Duration(milliseconds: 400),
              curve: Curves.ease,
            );
          },
          destinations: destinationsList,
          selectedIndex: currentPage,
        ),
      ),
    );
  }
}
