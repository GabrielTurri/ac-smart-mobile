import 'package:ac_smart/services/login_service.dart';
import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier {
  Future<bool> fazerLogin({
    required BuildContext context,
    required String tipo,
    required String email,
    required String senha,
  }) async {
    try {
      await LoginService().fetchLogin(context, tipo, email, senha);
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }
}
