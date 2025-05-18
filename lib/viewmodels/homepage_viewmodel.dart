import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomepageProvider with ChangeNotifier {
  late PageController pageController = PageController(initialPage: 0);
  int currentPage = 0;
  int currentSelectedNavigation = 0;

  String nomeUsuario = 'Login não efetuado';

  Future<String> lerNomeUsuario() async {
    final prefs = await SharedPreferences.getInstance();

    nomeUsuario = (prefs.getString('token') == null)
        ? 'Login não efetuado'
        : '${prefs.getString("userName")} ${prefs.getString("userSurname")}';

    notifyListeners();
    return nomeUsuario;
  }

  setPaginaAtual(pagina) {
    currentPage = pagina;
    notifyListeners();
  }
}
