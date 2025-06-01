import 'package:ac_smart/models/user_model.dart';
import 'package:ac_smart/services/login_service.dart';
import 'package:ac_smart/viewmodels/homepage_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider extends ChangeNotifier {
  User? currentUser;
  bool isLoading = false;
  String? errorMessage;

  bool get isLoggedIn => currentUser != null;

  Future<bool> fazerLogin({
    required BuildContext context,
    required String tipo,
    required String email,
    required String senha,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    try {
      if (email.isEmpty || senha.isEmpty) {
        errorMessage = 'Email e senha são obrigatórios';
        isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Obter o usuário do serviço de login
      currentUser = await LoginService().fetchLogin(tipo, email, senha);
      
      // Se o login foi bem-sucedido, atualizar o HomepageProvider
      if (currentUser != null) {
        final homepageProvider = Provider.of<HomepageProvider>(context, listen: false);
        homepageProvider.setCurrentUser(currentUser!);
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = 'Falha ao realizar login';
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<void> fazerLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', '');
    await prefs.setString('userId', '');
    await prefs.setString('userName', '');
    await prefs.setString('userSurname', '');
    currentUser = null;
    notifyListeners(); // Notify when logging out
  }
}
