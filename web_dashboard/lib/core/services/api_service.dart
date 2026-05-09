import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lot_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.chaincacao.tg';

  // Pour la démo — données simulées
  static const String demoBaseUrl = 'http://localhost:8000';

  static Future<Lot?> getLot(String lotId) async {
    try {
      final response = await http.get(
        Uri.parse('$demoBaseUrl/api/lots/public/$lotId/'),
      );
      if (response.statusCode == 200) {
        return Lot.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<Lot>> getCooperativeLots(String cooperativeId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$demoBaseUrl/api/cooperatives/$cooperativeId/lots/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Lot.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> validateLot(
    String lotId,
    double weightVerified,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$demoBaseUrl/api/lots/$lotId/transfer/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'weight_verified': weightVerified,
          'from_actor': 'FARMER',
          'to_actor': 'COOPERATIVE',
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$demoBaseUrl/api/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}