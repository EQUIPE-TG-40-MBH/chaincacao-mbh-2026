import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../configuration/constantes.dart';

class ServiceApiChainCacao {
  ServiceApiChainCacao._();

  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://chaincacao-api.onrender.com/api',
  );

  static Future<bool> connecterProducteur(String farmerId) async {
    final normalizedFarmerId = farmerId.trim().toUpperCase();
    final token = await _loginDemoFarmer();
    if (token == null) return false;

    var farmer = await _getFarmerByQr(normalizedFarmerId);
    farmer ??= await _createDemoDataThenFind(normalizedFarmerId);
    if (farmer == null) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(CCStockage.token, token);
    await prefs.setString(CCStockage.agriculteurId, farmer['farmer_id'] as String);
    await prefs.setInt(CCStockage.agriculteurPk, farmer['id'] as int);
    await prefs.setInt(CCStockage.cooperativePk, farmer['cooperative'] as int);
    await prefs.setString(
      CCStockage.agriculteurNom,
      farmer['full_name'] as String? ?? normalizedFarmerId,
    );
    return true;
  }

  static Future<Map<String, dynamic>?> creerLot({
    required double weightDeclared,
    required String cultureType,
    required double gpsLatitude,
    required double gpsLongitude,
    required bool gpsForced,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(CCStockage.token);
    final farmerPk = prefs.getInt(CCStockage.agriculteurPk);
    final cooperativePk = prefs.getInt(CCStockage.cooperativePk);

    if (token == null || farmerPk == null || cooperativePk == null) {
      return null;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/lots/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'farmer': farmerPk,
        'cooperative': cooperativePk,
        'weight_declared': weightDeclared,
        'culture_type': cultureType,
        'gps_latitude': gpsLatitude,
        'gps_longitude': gpsLongitude,
        'gps_forced': gpsForced,
      }),
    );

    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    return null;
  }

  static Future<String?> _loginDemoFarmer() async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': 'kodjo@chaincacao.tg',
        'password': 'demo123',
      }),
    );
    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['token'] as String?;
  }

  static Future<Map<String, dynamic>?> _createDemoDataThenFind(
    String farmerId,
  ) async {
    await http.post(Uri.parse('$baseUrl/auth/demo-data/'));
    return _getFarmerByQr(farmerId);
  }

  static Future<Map<String, dynamic>?> _getFarmerByQr(String farmerId) async {
    final response = await http.get(Uri.parse('$baseUrl/farmers/qr/$farmerId/'));
    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Map<String, dynamic>.from(data['farmer'] as Map);
  }
}
