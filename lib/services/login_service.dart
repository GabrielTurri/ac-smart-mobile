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
  String baseUrl = Service().url;
  String backupUrl = Service().backupUrl;

  Future<void> fetchLogin(BuildContext context, String tipo, String email, String senha) async {
    final Uri url = Uri.parse('$baseUrl/api/auth/login');

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'senha': senha,
          'tipo': tipo
        }),
      ).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      
      // Create User object from API response
      final userJson = data['usuario'];
      final User user = User.fromJson(userJson);
      
      // Update HomepageProvider with the user object
      final homepageProvider = Provider.of<HomepageProvider>(context, listen: false);
      homepageProvider.setUser(user);
      
      // Store necessary information in SharedPreferences
      await prefs.setString('token', data['token']);
      await prefs.setString('userId', user.id);
      await prefs.setString('userName', user.name);
      await prefs.setString('userSurname', user.surname);
    } else {
      throw Exception(
        'Falha ao realizar login. Status: ${response.statusCode}. Response body: ${response.body}',
      );
    }
    } catch (e) {
      if (e is TimeoutException) {
        // Se ocorrer timeout, tenta com a URL de backup
        final Uri backupUrlPath = Uri.parse('$backupUrl/api/auth/login');
        var backupResponse = await http.post(
          backupUrlPath,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': email,
            'senha': senha,
            'tipo': tipo
          }),
        );
        
        if (backupResponse.statusCode == 200) {
          final data = jsonDecode(backupResponse.body);
          final prefs = await SharedPreferences.getInstance();
          
          // Create User object from API response
          final userJson = data['usuario'];
          final User user = User.fromJson(userJson);
          
          // Update HomepageProvider with the user object
          final homepageProvider = Provider.of<HomepageProvider>(context, listen: false);
          homepageProvider.setUser(user);
          
          // Store necessary information in SharedPreferences
          await prefs.setString('token', data['token']);
          await prefs.setString('userId', user.id);
          await prefs.setString('userName', user.name);
          await prefs.setString('userSurname', user.surname);
        } else {
          throw Exception(
            'Falha ao realizar login (backup). Status: ${backupResponse.statusCode}. Response body: ${backupResponse.body}',
          );
        }
      } else {
        throw Exception('Falha ao realizar login: $e');
      }
    }
  }
}
