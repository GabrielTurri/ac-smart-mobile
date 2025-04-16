import 'package:ac_smart/models/activity.dart';
import 'package:ac_smart/viewmodels/atividades_viewmodel.dart';
import 'package:ac_smart/views/atividade/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomepageProvider with ChangeNotifier {
  HomepageProvider({required this.atividadeProvider});

  final AtividadeProvider atividadeProvider;

  List<Activity> get atividades => atividadeProvider.atividades;

  late PageController pageController = PageController(initialPage: 0);
  int currentPage = 0;
  int currentSelectedNavigation = 0;

  setPaginaAtual(pagina) {
    currentPage = pagina;
    notifyListeners();
  }

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
      selectedIcon: const Icon(Icons.cancel_schedule_send, color: Colors.white),
      label: 'Reprovadas',
    ),
  ];
}
