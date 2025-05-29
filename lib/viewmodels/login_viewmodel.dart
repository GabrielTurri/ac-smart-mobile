import 'package:ac_smart/services/login_service.dart';
import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier {
  fazerLogin(
    BuildContext context, {
    String? tipo,
    String? email,
    String? senha,
  }) {
    String emailLogin = email ?? 'bruno.costa@humanitae.br';
    String senhaLogin = senha ?? 'abcd=1234';
    String tipoLogin = tipo ?? 'aluno';

    LoginService().fetchLogin(context, tipoLogin, emailLogin, senhaLogin);
  }
}
