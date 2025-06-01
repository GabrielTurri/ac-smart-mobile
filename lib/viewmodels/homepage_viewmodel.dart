import 'package:flutter/material.dart';
import 'package:ac_smart/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomepageProvider with ChangeNotifier {
  late PageController pageController = PageController(initialPage: 0);
  int currentPage = 0;
  int currentSelectedNavigation = 0;

  String nomeUsuario = 'Login não efetuado';
  User? user;

  HomepageProvider() {
    // Load user data when provider is created
    loadUserFromPrefs();
  }

  // Method to set the user object
  void setUser(User newUser) {
    user = newUser;
    nomeUsuario = '${user!.name} ${user!.surname}';
    notifyListeners();
  }

  Future<String> lerNomeUsuario() async {
    final prefs = await SharedPreferences.getInstance();

    nomeUsuario = (prefs.getString('token') == null)
        ? 'Login não efetuado'
        : '${prefs.getString("userName")} ${prefs.getString("userSurname")}';

    notifyListeners();
    return nomeUsuario;
  }

  // Load user data from SharedPreferences
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      // If we have a userId, we can try to load user data from API
      // For now, we'll create a basic user object with the stored data
      final userName = prefs.getString('userName') ?? '';
      final userSurname = prefs.getString('userSurname') ?? '';

      // Update the nomeUsuario
      nomeUsuario = '$userName $userSurname';

      // Notify listeners that data has changed
      notifyListeners();
    }
  }

  // Get user information
  User? getUser() {
    return user;
  }

  setPaginaAtual(pagina) {
    currentPage = pagina;
    notifyListeners();
  }

  loadUserData(BuildContext context) async {
    lerNomeUsuario();

    loadUserFromPrefs();

    notifyListeners();
  }
}
