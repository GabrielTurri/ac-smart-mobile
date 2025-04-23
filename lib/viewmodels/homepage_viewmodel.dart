import 'package:ac_smart/models/activity_model.dart';
import 'package:ac_smart/viewmodels/atividades_viewmodel.dart';
import 'package:ac_smart/views/atividade/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomepageProvider with ChangeNotifier {
  late PageController pageController = PageController(initialPage: 0);
  int currentPage = 0;
  int currentSelectedNavigation = 0;

  setPaginaAtual(pagina) {
    currentPage = pagina;
    notifyListeners();
  }
}
