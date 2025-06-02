import 'package:ac_smart/services/login_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  Future<bool> fazerLogin({
    required BuildContext context,
    required String tipo,
    required String email,
    required String senha,
  }) async {
    try {
      await LoginService().fetchLogin(context, tipo, email, senha);
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isLoggedIn) {
      prefs.remove('token');
      prefs.remove('userId');
      _isLoggedIn = false;
    }
    notifyListeners();
  }
}
