import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';

class MvpStore {
  static const String baseUrl = AuthService.baseUrl;
  static const _lotsKey = 'chaincacao_mvp_lots_v1';
  static const _scanHistoryKey = 'chaincacao_scan_history_v1';
  static const _exportsKey = 'chaincacao_exports_v1';

  static Future<List<Map<String, dynamic>>> getLots() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No token');

      final response = await http.get(
        Uri.parse('$baseUrl/lots/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final normalized = data.map((item) {
          final map = Map<String, dynamic>.from(item);
          return {
            'lotId': map['lot_id'],
            'farmerId': map['farmer']?['farmer_id'] ?? '',
            'farmerName': map['farmer_name'] ?? '',
            'farmerPhone': map['farmer_phone'] ?? '',
            'cooperativeName': map['cooperative_name'] ?? '',
            'weightDeclared': map['weight_declared'] ?? 0.0,
            'weightVerified': map['weight_verified'] ?? 0.0,
            'cultureType': map['culture_type'] ?? 'Cacao',
            'status': map['status'] ?? 'REGISTERED',
            'gps': map['gps_coordinates'] ?? '',
            'region': 'Plateaux, Togo', // Default
            'registeredAt': _formatDate(map['registered_at']),
            'blockchainHash': map['blockchain_hash'] ?? '',
            'photoUrl': map['photo'] ?? '',
            'history': (map['transfers'] as List? ?? []).map((transfer) {
              return {
                'step': transfer['notes'] ?? '',
                'actor': transfer['to_actor'] ?? '',
                'date': _formatDate(transfer['transferred_at']),
                'status': 'REGISTERED', // Default
                'hash': transfer['blockchain_hash'] ?? '',
              };
            }).toList(),
          };
        }).toList();
        return normalized;
      } else {
        throw Exception('API error');
      }
    } catch (e) {
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_lotsKey);
      if (raw == null) {
        await prefs.setString(_lotsKey, jsonEncode(_seedLots));
        return _cloneLots(_seedLots);
      }

      final decoded = jsonDecode(raw) as List;
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    }
  }

  static Future<Map<String, dynamic>?> getLot(String lotId) async {
    final lots = await getLots();
    for (final lot in lots) {
      if ((lot['lotId'] as String).toUpperCase() == lotId.toUpperCase()) {
        return lot;
      }
    }
    return null;
  }

  static Future<void> saveLot(Map<String, dynamic> updatedLot) async {
    final lots = await getLots();
    final index = lots.indexWhere((lot) => lot['lotId'] == updatedLot['lotId']);
    if (index >= 0) {
      lots[index] = updatedLot;
    } else {
      lots.add(updatedLot);
    }
    await _saveLots(lots);
  }

  static Future<Map<String, dynamic>> validateLot({
    required String lotId,
    required double weightVerified,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No token');

      final response = await http.post(
        Uri.parse('$baseUrl/lots/$lotId/transfer/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'weight_verified': weightVerified,
          'from_actor': 'FARMER',
          'to_actor': 'COOPERATIVE',
          'notes': 'Réception cooperative',
        }),
      );

      if (response.statusCode == 200) {
        // After transfer, get the updated lot
        final updatedLot = await getLot(lotId);
        if (updatedLot != null) {
          return updatedLot;
        }
        throw Exception('Failed to get updated lot');
      } else {
        throw Exception('API error: ${response.body}');
      }
    } catch (e) {
      // Fallback to local validation
      final lots = await getLots();
      final index = lots.indexWhere((lot) => lot['lotId'] == lotId);
      if (index < 0) {
        throw StateError('Lot introuvable');
      }

      final lot = Map<String, dynamic>.from(lots[index]);
      final declared = (lot['weightDeclared'] as num).toDouble();
      final diff = ((declared - weightVerified) / declared).abs();
      final hash = _buildHash(lotId, DateTime.now().millisecondsSinceEpoch);
      final status = diff > 0.05 ? 'FRAUD_ALERT' : 'VALIDATED';

      lot['weightVerified'] = weightVerified;
      lot['status'] = status;
      lot['blockchainHash'] = hash;
      lot['lastTransferAt'] = _formatNow();
      lot['history'] = [
        ...List<Map<String, dynamic>>.from(lot['history'] ?? const []),
        {
          'step': 'Reception cooperative',
          'actor': 'CAPRK Kpalime',
          'date': _formatNow(),
          'status': status,
          'hash': hash,
        },
      ];

      lots[index] = lot;
      await _saveLots(lots);
      return lot;
    }
  }

  static Future<List<String>> getScanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_scanHistoryKey);
    return raw ?? const [];
  }

  static Future<void> addScan(String lotId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getScanHistory();
    final next = [lotId, ...current.where((item) => item != lotId)].take(5);
    await prefs.setStringList(_scanHistoryKey, next.toList());
  }

  static Future<List<Map<String, dynamic>>> getExports() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_exportsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  static Future<Map<String, dynamic>> recordExport({
    required String certificateId,
    required List<Map<String, dynamic>> lots,
    required double totalKg,
  }) async {
    final export = {
      'certificateId': certificateId,
      'lotIds': lots.map((lot) => lot['lotId']).toList(),
      'totalKg': totalKg,
      'createdAt': _formatNow(),
      'destination': 'Union Europeenne',
    };
    final exports = await getExports();
    exports.insert(0, export);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_exportsKey, jsonEncode(exports));
    return export;
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lotsKey);
    await prefs.remove(_scanHistoryKey);
    await prefs.remove(_exportsKey);
  }

  static Future<void> _saveLots(List<Map<String, dynamic>> lots) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lotsKey, jsonEncode(lots));
  }

  static List<Map<String, dynamic>> _cloneLots(
    List<Map<String, dynamic>> lots,
  ) {
    return lots.map((lot) => Map<String, dynamic>.from(lot)).toList();
  }

  static String _formatNow() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$day/$month/${now.year} - $hour:$minute';
  }

  static String _formatDate(String? dateString) {
    if (dateString == null) return _formatNow();
    try {
      final date = DateTime.parse(dateString);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day/$month/${date.year} - $hour:$minute';
    } catch (e) {
      return dateString;
    }
  }

  static String _buildHash(String lotId, int timestamp) {
    final source = utf8.encode('$lotId-$timestamp-chaincacao');
    final folded = source.fold<int>(0, (value, byte) => value * 31 + byte);
    final hex = folded.abs().toRadixString(16).padLeft(40, '0');
    return '0x${hex.substring(0, 40)}';
  }

  static final List<Map<String, dynamic>> _seedLots = [
    {
      'lotId': 'TG-2026-0471',
      'farmerId': 'CAPRK-0047',
      'farmerName': 'Koami Agbeko',
      'farmerPhone': '+228 90 12 45 78',
      'cooperativeName': 'CAPRK Kpalime',
      'weightDeclared': 250.0,
      'weightVerified': 0.0,
      'cultureType': 'Cacao',
      'status': 'REGISTERED',
      'gps': '6.8913 N, 0.6502 E',
      'region': 'Plateaux, Togo',
      'registeredAt': '09 Mai 2026 - 08:32',
      'blockchainHash': '0x72c5B32758000C6B6CbA364Cb4ef53aEF92948dc',
      'photoUrl': '',
      'history': [
        {
          'step': 'Enregistrement du lot',
          'actor': 'Koami Agbeko',
          'date': '09 Mai 2026 - 08:32',
          'status': 'REGISTERED',
          'hash': '0x72c5B32758000C6B6CbA364Cb4ef53aEF92948dc',
        },
      ],
    },
    {
      'lotId': 'TG-2026-0469',
      'farmerId': 'CAPRK-0031',
      'farmerName': 'Akosua Mensah',
      'farmerPhone': '+228 91 22 10 04',
      'cooperativeName': 'CAPRK Kpalime',
      'weightDeclared': 350.0,
      'weightVerified': 310.0,
      'cultureType': 'Cacao',
      'status': 'FRAUD_ALERT',
      'gps': '6.8900 N, 0.6489 E',
      'region': 'Plateaux, Togo',
      'registeredAt': '09 Mai 2026 - 07:15',
      'blockchainHash': '0x9A3F1C220000000000000000000000000000B71e',
      'photoUrl': '',
      'history': [
        {
          'step': 'Enregistrement du lot',
          'actor': 'Akosua Mensah',
          'date': '09 Mai 2026 - 07:15',
          'status': 'REGISTERED',
          'hash': '0x9A3F1C220000000000000000000000000000B71e',
        },
      ],
    },
    {
      'lotId': 'TG-2026-0468',
      'farmerId': 'CAPRK-0028',
      'farmerName': 'Mensah Koffi',
      'farmerPhone': '+228 92 82 33 12',
      'cooperativeName': 'CAPRK Kpalime',
      'weightDeclared': 180.0,
      'weightVerified': 178.0,
      'cultureType': 'Cacao',
      'status': 'VALIDATED',
      'gps': '6.8945 N, 0.6521 E',
      'region': 'Plateaux, Togo',
      'registeredAt': '08 Mai 2026 - 16:45',
      'blockchainHash': '0x4D8E2A110000000000000000000000000000C93f',
      'photoUrl': '',
      'history': [
        {
          'step': 'Enregistrement du lot',
          'actor': 'Mensah Koffi',
          'date': '08 Mai 2026 - 16:45',
          'status': 'REGISTERED',
          'hash': '0x4D8E2A110000000000000000000000000000C93f',
        },
        {
          'step': 'Reception cooperative',
          'actor': 'CAPRK Kpalime',
          'date': '08 Mai 2026 - 18:00',
          'status': 'VALIDATED',
          'hash': '0x4D8E2A110000000000000000000000000000C93f',
        },
      ],
    },
  ];
}
