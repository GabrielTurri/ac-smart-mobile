import 'dart:convert';
import 'package:ac_smart/services/service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginService {
  String baseUrl = Service().url;

  Future<void> fetchLogin(
      BuildContext context, String? tipo, String? email, String? senha) async {
    final Uri url = Uri.parse('$baseUrl/api/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'senha': senha,
        'tipo': tipo,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();

      String userId = data['usuario']['_id'];
      String userName = data['usuario']['name'];
      String userEmail = data['usuario']['email'];
      int horas_aprovadas = data['usuario']['total_approved_hours'];
      int horas_solicitadas = data['usuario']['total_pending_hours'];

      await prefs.setString('token', data['token']);
      await prefs.setString('userId', userId);
      await prefs.setString('userName', userName);
      await prefs.setString('userSurname', data['usuario']['surname']);
    } else {
      throw Exception(
        'Falha ao realizar login. Status: ${response.statusCode}. Response body: ${response.body}',
      );
    }
  }
}
