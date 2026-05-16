import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../configuration/constantes.dart';
import '../configuration/theme.dart';
import '../modeles/champ.dart';

import '../fonctionnalités/connexion/ecran_splash.dart';
import '../fonctionnalités/connexion/ecran_selection_langue.dart';
import '../fonctionnalités/connexion/ecran_connexion.dart';
import '../fonctionnalités/accueil/ecran_accueil.dart';
import '../fonctionnalités/profil/ecran_profil.dart';
import '../fonctionnalités/recolte/ecran_selection_champ.dart';
import '../fonctionnalités/recolte/ecran_diagnostic_recolte.dart';
import '../fonctionnalités/recolte/ecran_verification_gps.dart';
import '../fonctionnalités/connexion/ecran_scan_profil.dart';
import '../fonctionnalités/connexion/ecran_saisie_id.dart';
import '../fonctionnalités/recolte/ecran_scan_sac.dart';
import '../fonctionnalités/recolte/ecran_pesee.dart';
import '../fonctionnalités/historique/ecran_mes_scans.dart';
import '../services/service_gps.dart';

// ───NOMS DES ROUTES
class CCRoutes {
  CCRoutes._();

  // Connexion (publiques)
  static const splash = '/splash';
  static const selectionLangue = '/selection-langue';
  static const connexion = '/connexion';
  static const scanProfil = '/connexion/scan-profil';
  static const saisieId = '/connexion/saisie-id';
  static const profil = '/profil';

  // Espace agriculteur (protégées)
  static const accueil = '/accueil';
  static const selectionChamp = '/recolte/selection-champ';
  static const verificationGps = '/recolte/verification-gps';
  static const diagnosticRecolte = '/recolte/diagnostic';
  static const scanSac = '/recolte/scan-sac';
  static const pesee = '/recolte/pesee';
  static const mesScans = '/historique';
}

// ─── GUARD
Future<String?> _gardeRedirection(
  BuildContext context,
  GoRouterState state,
) async {
  final prefs = await SharedPreferences.getInstance();
  final langue = prefs.getString(CCStockage.langue);
  final token = prefs.getString(CCStockage.token);
  final localisation = state.matchedLocation;

  // Routes accessibles sans connexion
  const publiques = [
    CCRoutes.splash,
    CCRoutes.selectionLangue,
    CCRoutes.connexion,
    CCRoutes.scanProfil,
    CCRoutes.saisieId,
  ];

  final estPublique = publiques.contains(localisation);

  // Pas de langue → sélection de langue
  if (langue == null && localisation != CCRoutes.selectionLangue) {
    return CCRoutes.selectionLangue;
  }

  // Pas de token sur une route protégée → connexion
  if (token == null && !estPublique) {
    return CCRoutes.connexion;
  }

  // // Déjà connecté sur une route publique → accueil
  if (token != null && estPublique && localisation != CCRoutes.splash) {
    return CCRoutes.accueil;
  }

  return null; // Pas de redirection
}

// ─── 3. ROUTER
class CCRoutage {
  CCRoutage._();

  static final router = GoRouter(
    initialLocation: CCRoutes.splash,
    redirect: _gardeRedirection,
    routes: [
      // ── Splash
      GoRoute(path: CCRoutes.splash, builder: (_, __) => const EcranSplash()),

      // ── Sélection de langue
      GoRoute(
        path: CCRoutes.selectionLangue,
        builder: (_, __) => const EcranSelectionLangue(),
      ),

      // // ── Connexion
      GoRoute(
        path: CCRoutes.connexion,
        builder: (_, __) => const EcranConnexion(),
        routes: [
          GoRoute(
            path: 'scan-profil',
            builder: (_, __) => const EcranScanProfil(),
          ),
          GoRoute(path: 'saisie-id', builder: (_, __) => const EcranSaisieId()),
        ],
      ),

      // ── Accueil (protégé)
      GoRoute(path: CCRoutes.accueil, builder: (_, __) => const EcranAccueil()),

      GoRoute(path: CCRoutes.profil, builder: (_, __) => const EcranProfil()),

      GoRoute(
        path: CCRoutes.selectionChamp,
        builder: (_, __) => const EcranSelectionChamp(),
      ),

      // Verification gps
      GoRoute(
        path: CCRoutes.verificationGps,
        builder: (context, state) {
          final champ = state.extra as Champ;
          return EcranVerificationGps(champ: champ);
        },
      ),

      // Diagnostic récolte (protégé)
      GoRoute(
        path: CCRoutes.diagnosticRecolte,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map) {
            return EcranDiagnosticRecolte(
              champ: extra['champ'] as Champ,
              gpsForced: extra['gps_forced'] as bool? ?? false,
              gpsResultat: extra['gps_resultat'] as ResultatGps?,
            );
          }
          return EcranDiagnosticRecolte(champ: extra as Champ);
        },
      ),

      // // ── Récolte (protégé)
      GoRoute(path: CCRoutes.scanSac, builder: (_, __) => const EcranScanSac()),
      GoRoute(
        path: CCRoutes.pesee,
        builder: (context, state) {
          // L'ID du sac scanné est passé en extra depuis EcranScanSac
          final idSac = state.extra as String? ?? '';
          return EcranPesee(idSac: idSac);
        },
      ),

      // ── Historique (protégé)
      GoRoute(
        path: CCRoutes.mesScans,
        builder: (_, __) => const EcranMesScans(),
      ),
    ],

    // Page d'erreur
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: CCCouleurs.vertProfond,
      body: Center(
        child: Text(
          'Page introuvable',
          style: TextStyle(color: CCCouleurs.feuilleClaire),
        ),
      ),
    ),
  );
}
