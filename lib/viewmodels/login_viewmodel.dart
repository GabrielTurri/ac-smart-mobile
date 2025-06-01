import 'package:ac_smart/services/login_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider extends ChangeNotifier {
  Future<bool> fazerLogin({
    required String tipo,
    required String email,
    required String senha,
  }) async {
    try {
      if (email.isEmpty || senha.isEmpty) {
        return false;
      }

      final result = await LoginService().fetchLogin(tipo, email, senha);
      if (result) {
        notifyListeners(); // Notify when login is successful
      }
      return result;
    } catch (e) {
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
    notifyListeners(); // Notify when logging out
  }
}
