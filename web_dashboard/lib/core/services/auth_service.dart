import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Supposons que EntityAccount est défini quelque part, par exemple:
class EntityAccount {
  final String entityName;
  final String email;
  final String password; // Ne devrait pas être stocké en prod
  final String role;
  final String phone;
  final String registrationId;
  final String createdAt;
  final String token;
  final String homeRoute; // Ajouté pour faciliter la navigation

  EntityAccount({
    required this.entityName,
    required this.email,
    required this.password,
    required this.role,
    required this.phone,
    required this.registrationId,
    required this.createdAt,
    required this.token,
  }) : homeRoute = _getHomeRouteForRole(role);

  /// Retourne un nom lisible pour le rôle (utilisé dans l'UI)
  String get roleLabel {
    switch (role) {
      case 'cooperative': return 'Coopérative';
      case 'exportateur': return 'Exportateur';
      case 'ccfcc': return 'CCFCC (Qualité)';
      case 'otr': return 'OTR (Douanes)';
      case 'verificateur': return 'Vérificateur';
      case 'importateur': return 'Importateur';
      default: return role[0].toUpperCase() + role.substring(1);
    }
  }

  static String _getHomeRouteForRole(String role) {
    switch (role) {
      case 'cooperative': return '/cooperative';
      case 'exportateur': return '/exportateur';
      case 'ccfcc': return '/ccfcc';
      case 'otr': return '/otr';
      case 'verificateur': return '/verifier';
      case 'importateur': return '/importer/reception';
      default: return '/';
    }
  }

  Map<String, dynamic> toJson() => {
        'entityName': entityName,
        'email': email,
        'role': role,
        'phone': phone,
        'registrationId': registrationId,
        'createdAt': createdAt,
        'token': token,
      };

  factory EntityAccount.fromJson(Map<String, dynamic> json) => EntityAccount(
        entityName: json['entityName'],
        email: json['email'],
        password: '', // Ne pas charger le mot de passe
        role: json['role'],
        phone: json['phone'],
        registrationId: json['registrationId'],
        createdAt: json['createdAt'],
        token: json['token'],
      );
}

class AuthService {
  static const String _sessionKey = 'current_session';

  /// URL de base de l'API (utilisée par MvpStore et ApiClient)
  static const String baseUrl = 'https://chaincacao-api.onrender.com/api';

  /// Récupère le compte actuellement connecté (utilisé par AuthGate et les Dashboards)
  static Future<EntityAccount?> currentAccount() => getSession();

  static Future<void> setGuestSession(EntityAccount account) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(account.toJson()));
  }

  static Future<EntityAccount?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionString = prefs.getString(_sessionKey);
    if (sessionString != null) {
      return EntityAccount.fromJson(jsonDecode(sessionString));
    }
    return null;
  }

  static Future<String?> getToken() async {
    final session = await getSession();
    return session?.token;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  static Future<bool> isLoggedIn() async {
    return (await getSession()) != null;
  }

  static Future<bool> hasRequiredRole(String requiredRole) async {
    final session = await getSession();
    return session?.role == requiredRole;
  }

  // Méthode de simulation de login (pour le hackathon)
  static Future<EntityAccount?> login(String email, String password) async {
    // Ici, tu ferais un appel API réel
    await Future.delayed(const Duration(seconds: 1)); // Simule un délai réseau

    // Logique de simulation pour le hackathon
    if (email == 'export@chaincacao.tg' && password == '1234') {
      final account = EntityAccount(
        entityName: 'ChainCacao Export',
        email: email,
        password: password,
        role: 'exportateur',
        phone: '+22890000000',
        registrationId: 'EXP-TG-001',
        createdAt: DateTime.now().toIso8601String(),
        token: 'fake-export-token',
      );
      await setGuestSession(account); // Réutilise setGuestSession pour stocker
      return account;
    }
    return null;
  }

  /// Méthode d'inscription simulée pour le MVP
  static Future<EntityAccount?> register({
    required String entityName,
    required String email,
    required String password,
    required String role,
    required String phone,
    required String registrationId,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulation réseau
    final account = EntityAccount(
      entityName: entityName,
      email: email,
      password: password,
      role: role,
      phone: phone,
      registrationId: registrationId,
      createdAt: DateTime.now().toIso8601String(),
      token: 'reg-token-${DateTime.now().millisecondsSinceEpoch}',
    );
    await setGuestSession(account);
    return account;
  }
}