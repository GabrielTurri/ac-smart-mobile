import 'package:ac_smart/models/user_model.dart';
import 'package:ac_smart/services/login_service.dart';
import 'package:ac_smart/viewmodels/homepage_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginProvider extends ChangeNotifier {
  User? currentUser;
  bool isLoading = false;
  String? errorMessage;

  bool get isLoggedIn => currentUser != null;

  Future<bool> fazerLogin(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    try {
      // Obter o usuário do serviço de login
      currentUser = await LoginService().fetchLogin(context);
      
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
      return false;
    }
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }
}
