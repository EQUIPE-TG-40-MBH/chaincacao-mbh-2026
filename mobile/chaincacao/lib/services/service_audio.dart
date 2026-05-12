import 'package:just_audio/just_audio.dart';

class ServiceAudio {
  final AudioPlayer _lecteur = AudioPlayer();

  static const String splash = 'splash';
  static const String selectionLangue = 'selection_langue';
  static const String connexion = 'connexion';
  static const String accueil = 'accueil';
  static const String scanSac = 'scan_sac';
  static const String pesee = 'pesee';

  Future<void> jouer(String cle, {required String langue}) async {
    final chemin = 'assets/audio/$langue/$cle.mp3';
    
    try {
      await _lecteur.stop();
      await _lecteur.setAsset(chemin);
      await _lecteur.play();
    } catch (e) {
      print("Erreur audio : Fichier $chemin introuvable.");
    }
  }

  Future<void> arreter() async => await _lecteur.stop();

  void dispose() => _lecteur.dispose();
}