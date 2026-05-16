import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: AuthService.baseUrl,
  );

  // Pour accéder aux médias (QR codes, photos) sans passer par /api/
  static const String serverUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: 'https://chaincacao-api.onrender.com',
  );

  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Authorization': 'Bearer ${token ?? ''}',
      'Content-Type': 'application/json',
    };
  }

  // Méthode pour les appels API publics (sans token d'authentification)
  static Future<Map<String, dynamic>?> getPublicLot(String lotId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lots/public/$lotId/'), // Utilise l'endpoint public
        headers: {'Content-Type': 'application/json'}, // Pas d'Authorization header
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ===== LOTS =====
  static Future<List<Map<String, dynamic>>> getLots() async {
    try {
      final token = await AuthService.getToken();
      if (token == 'demo-token-bypass') {
        // Retourne des données fictives pour la démo sans backend
        return _getMockLots();
      }

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/lots/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Données de test pour le mode démo sans backend
  static List<Map<String, dynamic>> _getMockLots() {
    return [
      {
        'lot_id': 'TGO-2026-00124',
        'farmer_name': 'Abalo Koffi',
        'culture_type': 'Cacao Forastero',
        'weight_declared': 150.0,
        'weight_verified': 148.5,
        'status': 'VALIDATED',
        'registered_at': '2026-05-08T10:30:00Z',
        'gps_latitude': 7.1855,
        'gps_longitude': 0.6123,
        'blockchain_hash': '0x72c5...53aEF',
      },
      {
        'lot_id': 'TGO-2026-00125',
        'farmer_name': 'Yao Mensah',
        'culture_type': 'Cacao Criollo',
        'weight_declared': 85.0,
        'weight_verified': null,
        'status': 'REGISTERED',
        'registered_at': '2026-05-09T08:15:00Z',
        'gps_latitude': 7.1922,
        'gps_longitude': 0.6055,
        'blockchain_hash': null,
      },
    ];
  }

  static Future<Map<String, dynamic>?> getLot(String lotId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/lots/$lotId/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createLot({
    required String farmerId,
    required String cooperativeId,
    required String cultureType,
    required double weightDeclared,
    required double gpsLatitude,
    required double gpsLongitude,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/lots/'),
        headers: headers,
        body: jsonEncode({
          'farmer': farmerId,
          'cooperative': cooperativeId,
          'culture_type': cultureType,
          'weight_declared': weightDeclared,
          'gps_latitude': gpsLatitude,
          'gps_longitude': gpsLongitude,
        }),
      );
      if (response.statusCode == 201) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> transferLot({
    required String lotId,
    required double? weightVerified,
    required String fromActor,
    required String toActor,
    required String notes,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{
        'from_actor': fromActor,
        'to_actor': toActor,
        'notes': notes,
      };
      if (weightVerified != null) {
        body['weight_verified'] = weightVerified;
      }
      final response = await http.post(
        Uri.parse('$baseUrl/lots/$lotId/transfer/'),
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ===== FARMERS =====
  static Future<List<Map<String, dynamic>>> getFarmers({String? cooperativeId}) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/farmers/';
      if (cooperativeId != null) {
        url += '?cooperative=$cooperativeId';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createFarmer({
    required String firstName,
    required String lastName,
    required String phone,
    required String cooperativeId,
    required double gpsLatitude,
    required double gpsLongitude,
    required String region,
    required String village,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/farmers/'),
        headers: headers,
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'cooperative': cooperativeId,
          'gps_latitude': gpsLatitude,
          'gps_longitude': gpsLongitude,
          'region': region,
          'village': village,
          'language': 'fr',
        }),
      );
      if (response.statusCode == 201) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateFarmer(
    int farmerId, {
    required String firstName,
    required String lastName,
    required String phone,
    required String cooperativeId,
    required double gpsLatitude,
    required double gpsLongitude,
    required String region,
    required String village,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/farmers/$farmerId/'),
        headers: headers,
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'cooperative': cooperativeId,
          'gps_latitude': gpsLatitude,
          'gps_longitude': gpsLongitude,
          'region': region,
          'village': village,
        }),
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> deleteFarmer(int farmerId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/farmers/$farmerId/'),
        headers: headers,
      );
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  // ===== COOPERATIVES =====
  static Future<Map<String, dynamic>?> getCooperative(String cooperativeId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/cooperatives/$cooperativeId/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getCooperativeDashboard(String cooperativeId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/cooperatives/$cooperativeId/dashboard/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getCooperativeProfile(String cooperativeId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/cooperatives/$cooperativeId/profile/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateCooperativeProfile(
    String cooperativeId, {
    required String name,
    required String region,
    required String contactEmail,
    required String contactPhone,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/cooperatives/$cooperativeId/profile/'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'region': region,
          'contact_email': contactEmail,
          'contact_phone': contactPhone,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> registerCooperativeHarvest({
    required String cooperativeId,
    required double weightDeclared,
    required String cultureType,
    required double gpsLatitude,
    required double gpsLongitude,
    required String harvestDate,
    required String notes,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/lots/cooperative/register/'),
        headers: headers,
        body: jsonEncode({
          'cooperative_id': cooperativeId,
          'weight_declared': weightDeclared,
          'culture_type': cultureType,
          'gps_latitude': gpsLatitude,
          'gps_longitude': gpsLongitude,
          'harvest_date': harvestDate,
          'notes': notes,
        }),
      );
      if (response.statusCode == 201) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> mergeLots(List<String> lotIds) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/lots/merge/'),
        headers: headers,
        body: jsonEncode({'lot_ids': lotIds}),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> generateEudrCertificate(List<String> lotIds) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/certificates/eudr/'),
        headers: headers,
        body: jsonEncode({'lot_ids': lotIds}),
      );
      if (response.statusCode == 201) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> emailLotsCsv({
    required String cooperativeId,
    String? startDate,
    String? endDate,
    bool detailed = false,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/lots/export/email/'),
        headers: headers,
        body: jsonEncode({
          'cooperative_id': cooperativeId,
          'start_date': startDate,
          'end_date': endDate,
          'detailed': detailed,
        }),
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
