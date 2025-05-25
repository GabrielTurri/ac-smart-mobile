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
      var atividades = data['atividades'];
      debugPrint('Atividades: $atividades.');
      return Activity.fromJson(atividadeJson);
    } else {
      throw Exception(
          'Erro ao consultar atividades: ${response.statusCode}\n ${response.body}.');
    }
  }
}
