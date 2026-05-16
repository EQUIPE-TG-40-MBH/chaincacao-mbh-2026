import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EntityAccount {
  final String entityName;
  final String email;
  final String password;
  final String role;
  final String phone;
  final String registrationId;
  final String createdAt;
  final String? token;

  const EntityAccount({
    required this.entityName,
    required this.email,
    required this.password,
    required this.role,
    required this.phone,
    required this.registrationId,
    required this.createdAt,
    this.token,
  });

  String get roleLabel {
    return switch (role) {
      'cooperative' => 'Cooperative',
      'exportateur' => 'Exportateur',
      'verificateur' => 'Verificateur',
      _ => role,
    };
  }

  String get homeRoute {
    return switch (role) {
      'cooperative' => '/cooperative/lots',
      'exportateur' => '/exporter/dashboard',
      'verificateur' => '/regulator/dashboard',
      'importateur' => '/importer/reception',
      _ => '/',
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'entityName': entityName,
      'email': email,
      'password': password,
      'role': role,
      'phone': phone,
      'registrationId': registrationId,
      'createdAt': createdAt,
      'token': token,
    };
  }

  factory EntityAccount.fromJson(Map<String, dynamic> json) {
    return EntityAccount(
      entityName: json['entityName'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'] ?? '',
      registrationId: json['registrationId'] ?? '',
      createdAt: json['createdAt'] ?? '',
      token: json['token'],
    );
  }
}

class AuthService {
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'https://chaincacao-api.onrender.com/api');
  static const _accountsKey = 'chaincacao_entity_accounts_v1';
  static const _currentEmailKey = 'email';
  static const _currentRoleKey = 'role';
  static const _currentNameKey = 'entity_name';
  static const _currentRegistrationIdKey = 'registration_id'; // Nouvelle clé
  static const _tokenKey = 'token';


  static Future<List<EntityAccount>> getAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_accountsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((item) => EntityAccount.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<EntityAccount> register({
    required String entityName,
    required String email,
    required String password,
    required String role,
    required String phone,
    required String registrationId,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final accounts = await getAccounts();
    if (accounts.any((account) => account.email == normalizedEmail)) {
      throw StateError('Un compte existe deja avec cet email.');
    }

    final now = DateTime.now();
    final account = EntityAccount(
      entityName: entityName.trim(),
      email: normalizedEmail,
      password: password,
      role: role,
      phone: phone.trim(),
      registrationId: registrationId.trim(),
      createdAt:
          '${now.day.toString().padLeft(2, '0')}/'
          '${now.month.toString().padLeft(2, '0')}/${now.year}',
    );
    accounts.add(account);
    await _saveAccounts(accounts);
    await _setSession(account);
    return account;
  }

  static Future<EntityAccount?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final account = EntityAccount(
          entityName: data['name'] ?? '',
          email: email.trim().toLowerCase(),
          password: password, // Note: in real app, don't store password
          role: data['role'] ?? '',
          phone: '', // Backend doesn't return phone
          registrationId: data['cooperative_id'] ?? '',
          createdAt: DateTime.now().toString(),
          token: data['token'],
        );
        await _setSession(account);
        return account;
      } else {
        // En ligne, on refuse si le backend dit non
        return null;
      }
    } catch (e) {
      // Pas de serveur = Pas d'accès (Comportement réel)
      return null;
    }
  }

  static Future<EntityAccount?> currentAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_currentEmailKey);
    final role = prefs.getString(_currentRoleKey);
    final name = prefs.getString(_currentNameKey);
    final registrationId = prefs.getString(_currentRegistrationIdKey); // Récupérer l'ID
    final token = prefs.getString(_tokenKey);

    if (email == null || role == null || name == null || token == null || registrationId == null) {
      return null;
    }

    // Reconstruct from prefs for API logins
    return EntityAccount(
      entityName: name,
      email: email,
      password: '', // Not stored for API accounts
      role: role,
      phone: '',
      registrationId: registrationId,
      createdAt: DateTime.now().toString(),
      token: token,
    );
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_currentEmailKey);
    await prefs.remove(_currentRoleKey);
    await prefs.remove(_currentNameKey);
    await prefs.remove(_currentRegistrationIdKey); // Supprimer l'ID aussi
  }

  static Future<void> _saveAccounts(List<EntityAccount> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _accountsKey,
      jsonEncode(accounts.map((account) => account.toJson()).toList()),
    );
  }

  static Future<void> _setSession(EntityAccount account) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, account.token ?? 'mvp-token-${account.role}');
    await prefs.setString(_currentEmailKey, account.email);
    await prefs.setString(_currentRoleKey, account.role);
    await prefs.setString(_currentNameKey, account.entityName);
    await prefs.setString(_currentRegistrationIdKey, account.registrationId); // Sauvegarder l'ID
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}
