import 'dart:async';
import 'dart:convert';
import 'package:ac_smart/models/activity_model.dart';
import 'package:ac_smart/services/service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AtividadeService {
  final String baseUrl = Service.url;
  final String backupUrl = Service.backupUrl;

  Future<List<Activity>> fetchAtividades() async {
    var prefs = await SharedPreferences.getInstance();
    String studentId = prefs.getString('userId')!;
    String token = prefs.getString('token')!;
    var url = Uri.parse('$baseUrl/api/atividades/aluno/$studentId');

    try {
      var response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        final List<dynamic> atividadesJson = jsonData['atividades'];
        return atividadesJson.map((json) => Activity.fromJson(json)).toList();
      } else {
        throw Exception(
          'Erro ao consultar atividades: ${response.statusCode}\n ${response.body}.',
        );
      }
    } catch (e) {
      if (e is TimeoutException) {
        // Se ocorrer timeout, tenta com a URL de backup
        var backupUrlPath =
            Uri.parse('$backupUrl/api/atividades/aluno/$studentId');
        var backupResponse = await http.get(backupUrlPath, headers: {
          'Authorization': 'Bearer $token',
        });

        if (backupResponse.statusCode == 200) {
          final Map<String, dynamic> jsonData = jsonDecode(backupResponse.body);
          final List<dynamic> atividadesJson = jsonData['atividades'];
          return atividadesJson.map((json) => Activity.fromJson(json)).toList();
        } else {
          throw Exception(
            'Erro ao consultar atividades (backup): ${backupResponse.statusCode}\n ${backupResponse.body}.',
          );
        }
      } else {
        throw Exception('Erro ao consultar atividades: $e');
      }
    }
  }

  Future<Activity> fetchAtividade(id) async {
    var prefs = await SharedPreferences.getInstance();

    String token = prefs.getString('token')!;
    var url = Uri.parse('$baseUrl/api/atividades/$id');

    try {
      var response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final Map<String, dynamic> atividadeJson = data['atividade'];

        debugPrint('Atividade: $atividadeJson.');
        return Activity.fromJson(atividadeJson);
      } else {
        throw Exception(
            'Erro ao consultar atividade: ${response.statusCode}\n ${response.body}.');
      }
    } catch (e) {
      if (e is TimeoutException) {
        // Se ocorrer timeout, tenta com a URL de backup
        var backupUrlPath = Uri.parse('$backupUrl/api/atividades/$id');
        var backupResponse = await http.get(backupUrlPath, headers: {
          'Authorization': 'Bearer $token',
        });

        if (backupResponse.statusCode == 200) {
          final data = jsonDecode(backupResponse.body);
          final Map<String, dynamic> atividadeJson = data['atividade'];
          debugPrint('Atividade (backup): $atividadeJson.');
          return Activity.fromJson(atividadeJson);
        } else {
          throw Exception(
              'Erro ao consultar atividade (backup): ${backupResponse.statusCode}\n ${backupResponse.body}.');
        }
      } else {
        throw Exception('Erro ao consultar atividade: $e');
      }
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

    try {
      var response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint(data['mensagem']);
      } else {
        throw Exception(
            'Erro ao incluir atividade: ${response.statusCode}\n ${response.body}.');
      }
    } catch (e) {
      if (e is TimeoutException) {
        // Se ocorrer timeout, tenta com a URL de backup
        var backupUrlPath = Uri.parse('$backupUrl/api/atividades/');
        var backupResponse = await http.post(
          backupUrlPath,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: body,
        );

        if (backupResponse.statusCode == 201) {
          final data = jsonDecode(backupResponse.body);
          debugPrint(data['mensagem']);
        } else {
          throw Exception(
              'Erro ao incluir atividade (backup): ${backupResponse.statusCode}\n ${backupResponse.body}.');
        }
      } else {
        throw Exception('Erro ao incluir atividade: $e');
      }
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

    try {
      var response = await http
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        debugPrint(data['mensagem']);
      } else {
        throw Exception(
            'Erro ao alterar atividade: ${response.statusCode}\n ${response.body}.');
      }
    } catch (e) {
      if (e is TimeoutException) {
        // Se ocorrer timeout, tenta com a URL de backup
        var backupUrlPath =
            Uri.parse('$backupUrl/api/atividades/${atividade.id}');
        var backupResponse = await http.put(
          backupUrlPath,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: body,
        );

        if (backupResponse.statusCode == 200) {
          final data = jsonDecode(backupResponse.body);
          debugPrint(data['mensagem']);
        } else {
          throw Exception(
              'Erro ao alterar atividade (backup): ${backupResponse.statusCode}\n ${backupResponse.body}.');
        }
      } else {
        throw Exception('Erro ao alterar atividade: $e');
      }
    }
  }

  Future<void> deleteAtividade(id) async {
    var prefs = await SharedPreferences.getInstance();

    String token = prefs.getString('token')!;
    var url = Uri.parse('$baseUrl/api/atividades/$id');

    try {
      var response = await http.delete(url, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        debugPrint(response.body);
      } else {
        throw Exception(
            'Erro ao excluir atividade: ${response.statusCode}\n ${response.body}.');
      }
    } catch (e) {
      if (e is TimeoutException) {
        // Se ocorrer timeout, tenta com a URL de backup
        var backupUrlPath = Uri.parse('$backupUrl/api/atividades/$id');
        var backupResponse = await http.delete(backupUrlPath, headers: {
          'Authorization': 'Bearer $token',
        });

        if (backupResponse.statusCode == 200) {
          debugPrint(backupResponse.body);
        } else {
          throw Exception(
              'Erro ao excluir atividade (backup): ${backupResponse.statusCode}\n ${backupResponse.body}.');
        }
      } else {
        throw Exception('Erro ao excluir atividade: $e');
      }
    }
  }

  Future<void> rejectAtividade({
    required id,
    required String observation,
  }) async {
    var prefs = await SharedPreferences.getInstance();

    String token = prefs.getString('token')!;
    var url = Uri.parse('$baseUrl/api/atividades/$id/reject');

    try {
      var response = await http
          .put(url,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: json.encode({"observation": observation}))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        debugPrint(response.body);
      } else {
        throw Exception(
            'Erro ao rejeitar atividade: ${response.statusCode}\n ${response.body}.');
      }
    } catch (e) {
      if (e is TimeoutException) {
        // Se ocorrer timeout, tenta com a URL de backup
        var backupUrlPath = Uri.parse('$backupUrl/api/atividades/$id/reject');
        var backupResponse = await http.put(backupUrlPath,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({"observation": observation}));

        if (backupResponse.statusCode == 200) {
          debugPrint(backupResponse.body);
        } else {
          throw Exception(
              'Erro ao rejeitar atividade (backup): ${backupResponse.statusCode}\n ${backupResponse.body}.');
        }
      } else {
        throw Exception('Erro ao rejeitar atividade: $e');
      }
    }
  }
}
