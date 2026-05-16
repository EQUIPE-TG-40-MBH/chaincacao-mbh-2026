// lib/services/service_audio.dart

import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../configuration/constantes.dart';

class ServiceAudio {
  final AudioPlayer _lecteur = AudioPlayer();

  // ── Clés des écrans ──────────────────────────────────────────────────────
  static const connexion          = 'connexion';
  static const selectionLangue    = 'selection_langue';
  static const accueil            = 'accueil';
  static const selectionChamp     = 'selection_champ';
  static const verificationGps    = 'verification_gps';
  static const diagnosticMaturite = 'diagnostic_maturite';
  static const diagnosticSante    = 'diagnostic_sante';
  static const diagnosticHumidite = 'diagnostic_humidite';
  static const diagnosticPhotos   = 'diagnostic_photos';
  static const mesScans           = 'mes_scans';
  static const profil             = 'profil';

  // ── Jouer l'audio d'un écran ─────────────────────────────────────────────
  Future<void> jouer(String cle, {required String langue}) async {
  final chemin = 'assets/audio/$langue/$cle.mp3';
  print('🔊 Lecture : $chemin');
  try {
    await _lecteur.stop();
    await _lecteur.setAsset(chemin);
    await _lecteur.play();
    print('✅ OK');
  } catch (e) {
    print('❌ Erreur : $e');
  }
}

  // ── Jouer automatiquement selon la langue stockée ─────────────────────────
  Future<void> jouerAuto(String cle) async {
    final prefs  = await SharedPreferences.getInstance();
    final langue = prefs.getString(CCStockage.langue) ?? 'fr';
    await jouer(cle, langue: langue);
  }

  // ── Arrêter ───────────────────────────────────────────────────────────────
  Future<void> arreter() async {
    await _lecteur.stop();
  }

  // ── Rejouer ───────────────────────────────────────────────────────────────
  Future<void> rejouer() async {
    await _lecteur.seek(Duration.zero);
    await _lecteur.play();
  }

  // ── État lecture ──────────────────────────────────────────────────────────
  bool get enLecture =>
      _lecteur.playerState.playing;

  // ── Stream état pour le bouton animé ─────────────────────────────────────
  Stream<PlayerState> get etatStream => _lecteur.playerStateStream;

  void dispose() => _lecteur.dispose();
}