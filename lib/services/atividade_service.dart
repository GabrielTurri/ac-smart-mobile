import 'dart:convert';
import 'package:ac_smart/models/activity_model.dart';
import 'package:ac_smart/services/service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AtividadeService {
  String baseUrl = Service().url;

  Future<List<Activity>> fetchAtividades() async {
    var prefs = await SharedPreferences.getInstance();
    String studentId = prefs.getString('userId')!;
    String token = prefs.getString('token')!;
    var url = Uri.parse('$baseUrl/api/atividades/aluno/$studentId');

    var response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      final List<dynamic> atividadesJson = jsonData['atividades'];
      return atividadesJson.map((json) => Activity.fromJson(json)).toList();
    } else {
      throw Exception(
        'Erro ao consultar atividades: ${response.statusCode}\n ${response.body}.',
      );
    }
  }

  Future<Activity> fetchAtividade(id) async {
    var prefs = await SharedPreferences.getInstance();

    String token = prefs.getString('token')!;
    var url = Uri.parse('$baseUrl/api/atividades/$id');

    var response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final Map<String, dynamic> atividadeJson = data['atividade'];

      debugPrint('Atividade: $atividadeJson.');
      return Activity.fromJson(atividadeJson);
    } else {
      throw Exception(
          'Erro ao consultar atividade: ${response.statusCode}\n ${response.body}.');
    }
  }

  Future<void> includeAtividade(Activity atividade) async {
    var prefs = await SharedPreferences.getInstance();

    String token = prefs.getString('token')!;
    var url = Uri.parse('$baseUrl/api/atividades/');

    Map data = {
      'title': atividade.titulo,
      'description': atividade.descricao,
      'requested_hours': atividade.horasSolicitadas,
      'completion_date': atividade.dataAtividade,
      'student_id': prefs.getString('userId')
    };
    var body = json.encode(data);

    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );
    if (response.statusCode == 200) {
      debugPrint(data['mensagem']);
    } else {
      throw Exception(
          'Erro ao incluir atividade: ${response.statusCode}\n ${response.body}.');
    }
  }

  Future<void> updateAtividade(Activity atividade) async {
    var prefs = await SharedPreferences.getInstance();

    String token = prefs.getString('token')!;
    var url = Uri.parse('$baseUrl/api/atividades/${atividade.id}');
    atividade.dataAtividade = atividade.dataAtividade;

    Map data = {
      'title': atividade.titulo,
      'description': atividade.descricao,
      'requested_hours': atividade.horasSolicitadas,
      'data': atividade.dataAtividade,
    };
    var body = json.encode(data);

    var response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      debugPrint(data['mensagem']);
    } else {
      throw Exception(
          'Erro ao alterar atividade: ${response.statusCode}\n ${response.body}.');
    }
  }
}
