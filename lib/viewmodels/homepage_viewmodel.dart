import 'package:flutter/material.dart';
import 'package:ac_smart/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomepageProvider with ChangeNotifier {
  late PageController pageController = PageController(initialPage: 0);
  int currentPage = 0;
  int currentSelectedNavigation = 0;

  String nomeUsuario = 'Login não efetuado';
  User? currentUser;
  
  bool get isLoggedIn => currentUser != null;

  Future<String> lerNomeUsuario() async {
    final prefs = await SharedPreferences.getInstance();

    nomeUsuario = (prefs.getString('token') == null)
        ? 'Login não efetuado'
        : '${prefs.getString("userName")} ${prefs.getString("userSurname")}';

    notifyListeners();
    return nomeUsuario;
  }
  
  void setCurrentUser(User user) {
    currentUser = user;
    nomeUsuario = '${user.name} ${user.surname}';
    notifyListeners();
  }
  
  Future<void> carregarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token != null) {
      // Tentar recuperar as informações do usuário do SharedPreferences
      // Isso é apenas um fallback, o ideal é que o objeto User já tenha sido definido pelo login
      if (currentUser == null) {
        // Aqui poderíamos fazer uma chamada à API para obter os dados completos do usuário
        // Por enquanto, apenas atualizamos o nome do usuário
        nomeUsuario = '${prefs.getString("userName")} ${prefs.getString("userSurname")}';
        notifyListeners();
      }
    } else {
      currentUser = null;
      nomeUsuario = 'Login não efetuado';
      notifyListeners();
    }
  }

  setPaginaAtual(pagina) {
    currentPage = pagina;
    notifyListeners();
  }
}
