import 'package:ac_smart/services/login_service.dart';
import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier {
  fazerLogin(BuildContext context) {
    LoginService().fetchLogin(context);
  }
}
