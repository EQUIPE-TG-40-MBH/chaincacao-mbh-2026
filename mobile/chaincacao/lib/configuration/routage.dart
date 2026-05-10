// lib/configuration/routage.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// ─── 1. NOMS DES ROUTES ───────────────────────────────────────────────────
class CCRoutes {
  CCRoutes._();

  // Connexion (publiques)
  static const connexion   = '/connexion';
  static const scanProfil  = '/connexion/scan-profil';
  static const saisieId    = '/connexion/saisie-id';

  // Espace agriculteur (protégées)
  static const accueil     = '/accueil';
  static const scanSac     = '/recolte/scan-sac';
  static const pesee       = '/recolte/pesee';
  static const mesScans    = '/historique';
}