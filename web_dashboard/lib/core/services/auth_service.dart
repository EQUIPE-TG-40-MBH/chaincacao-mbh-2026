import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class EntityAccount {
  final String entityName;
  final String email;
  final String password;
  final String role;
  final String phone;
  final String registrationId;
  final String createdAt;

  const EntityAccount({
    required this.entityName,
    required this.email,
    required this.password,
    required this.role,
    required this.phone,
    required this.registrationId,
    required this.createdAt,
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
      'cooperative' => '/cooperative',
      'exportateur' => '/exportateur',
      'verificateur' => '/verifier',
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
    );
  }
}

class AuthService {
  static const _accountsKey = 'chaincacao_entity_accounts_v1';
  static const _currentEmailKey = 'email';
  static const _currentRoleKey = 'role';
  static const _currentNameKey = 'entity_name';
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
    final normalizedEmail = email.trim().toLowerCase();
    final accounts = await getAccounts();
    for (final account in accounts) {
      if (account.email == normalizedEmail && account.password == password) {
        await _setSession(account);
        return account;
      }
    }
    return null;
  }

  static Future<EntityAccount?> currentAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_currentEmailKey);
    if (email == null) return null;
    final accounts = await getAccounts();
    for (final account in accounts) {
      if (account.email == email) return account;
    }
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_currentEmailKey);
    await prefs.remove(_currentRoleKey);
    await prefs.remove(_currentNameKey);
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
    await prefs.setString(_tokenKey, 'mvp-token-${account.role}');
    await prefs.setString(_currentEmailKey, account.email);
    await prefs.setString(_currentRoleKey, account.role);
    await prefs.setString(_currentNameKey, account.entityName);
  }
}
