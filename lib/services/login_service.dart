import 'dart:convert';
import 'package:ac_smart/models/user_model.dart';
import 'package:ac_smart/services/service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginService {
  String baseUrl = Service().url;

  Future<User?> fetchLogin(BuildContext context) async {
    final Uri url = Uri.parse('$baseUrl/api/auth/login');

    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': 'bruno.costa@humanitae.br',
        'senha': 'teste',
        'tipo': 'aluno'
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();

      // Salvar o token e outras informações básicas no SharedPreferences
      await prefs.setString('token', data['token']);
      
      // Criar um objeto User a partir dos dados da resposta
      User user = User.fromJson(data['usuario']);
      
      // Salvar informações do usuário no SharedPreferences para acesso rápido
      await prefs.setString('userId', user.id);
      await prefs.setString('userName', user.name);
      await prefs.setString('userSurname', user.surname);
      
      // Retornar o objeto User completo
      return user;
    } else {
      throw Exception(
        'Falha ao realizar login. Status: ${response.statusCode}. Response body: ${response.body}',
      );
    }
  }
}
