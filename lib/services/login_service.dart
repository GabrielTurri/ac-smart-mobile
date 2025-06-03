import 'dart:async';
import 'dart:convert';
import 'package:ac_smart/models/user_model.dart';
import 'package:ac_smart/services/service.dart';
import 'package:ac_smart/viewmodels/homepage_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginService {
  final String _baseUrl = Service.url;
  final String _backupUrl = Service.backupUrl;

  Future<void> fetchLogin(
    BuildContext context,
    String tipo,
    String email,
    String senha,
  ) async {
    final Uri url = Uri.parse('$_baseUrl/api/auth/login');
    final Uri backupUrlPath = Uri.parse('$_backupUrl/api/auth/login');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': email,
              'senha': senha,
              'tipo': tipo,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final User user = User.fromJson(data['usuario']);

        final HomepageProvider homepageProvider =
            Provider.of<HomepageProvider>(context, listen: false);
        homepageProvider.setUser(user);

        await prefs.setString('token', data['token']);
        await prefs.setString('userId', user.id);
      } else {
        throw Exception(
          'Falha ao realizar login. Status: ${response.statusCode}. Response body: ${response.body}',
        );
      }
    } on TimeoutException {
      // Se ocorrer timeout, tenta com a URL de backup
      final response = await http.post(
        backupUrlPath,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'senha': senha,
          'tipo': tipo,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final User user = User.fromJson(data['usuario']);

        final HomepageProvider homepageProvider =
            Provider.of<HomepageProvider>(context, listen: false);
        homepageProvider.setUser(user);

        await prefs.setString('token', data['token']);
        await prefs.setString('userId', user.id);
        await prefs.setString('userName', user.name);
        await prefs.setString('userSurname', user.surname);
      } else {
        throw Exception(
          'Falha ao realizar login (backup). Status: ${response.statusCode}. Response body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Falha ao realizar login: $e');
    }
  }
}
