import 'dart:convert';
import 'package:ac_smart/models/user_model.dart';
import 'package:ac_smart/services/service.dart';
import 'package:ac_smart/viewmodels/homepage_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserService {
  String baseUrl = Service().url;

  Future<User?> fetchUserData(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');

      if (token == null || userId == null) {
        return null;
      }

      final Uri url = Uri.parse('$baseUrl/api/users/$userId');

      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Create User object from API response
        final User user = User.fromJson(data['user']);
        
        // Update HomepageProvider with the user object
        final homepageProvider = Provider.of<HomepageProvider>(context, listen: false);
        homepageProvider.setUser(user);
        
        return user;
      } else {
        print('Failed to load user data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
}
