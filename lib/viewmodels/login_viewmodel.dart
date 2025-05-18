import 'dart:convert';
import 'package:ac_smart/viewmodels/atividades_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginProvider extends ChangeNotifier {
  Map<String, dynamic> loginBody() {
    return {
      'email': 'bruno.costa@humanitae.br',
      'senha': 'abcd=1234',
      'tipo': 'aluno'
    };
  }

  fazerLogin(BuildContext context) async {
    final Uri url = Uri.parse('http://10.0.2.2:5000/api/auth/login');

    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': 'bruno.costa@humanitae.br',
        'senha': 'abcd=1234',
        'tipo': 'aluno'
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

      // Map atividades = data['activities'];

      // Provider.of<AtividadeProvider>(context, listen: false).setAtividades(atividades);

      await prefs.setString('token', data['token']);
      await prefs.setString('userId', userId);
      await prefs.setString('userName', userName);

      // Aqui você pode salvar os dados localmente também se quiser
    } else {
      throw Exception(
        'Falha ao realizar login. Status: ${response.statusCode}. Response body: ${response.body}',
      );
    }
  }
}
