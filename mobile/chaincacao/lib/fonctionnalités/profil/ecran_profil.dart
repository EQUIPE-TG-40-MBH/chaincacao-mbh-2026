// lib/fonctionnalités/profil/ecran_profil.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../configuration/theme.dart';
import '../../configuration/constantes.dart';
import '../../configuration/routage.dart';
import '../../composants/bouton_audio_aide.dart';
import '../../services/service_audio.dart';

class EcranProfil extends StatefulWidget {
  const EcranProfil({super.key});

  @override
  State<EcranProfil> createState() => _EcranProfilState();
}

class _EcranProfilState extends State<EcranProfil> {
  String _langue = 'fr';

  // TODO : remplacer par AuthService.producteurConnecte
  final _nom = 'Koami Agbéko';
  final _cooperative = 'Coopérative de Kpalimé';
  final _telephone = '+228 90 00 00 00';

  static const _langues = [
    ('fr', '🇫🇷', 'Français'),
    ('ewe', '🇹🇬', 'Éwé'),
    ('kab', '🇹🇬', 'Kabiyè'),
  ];

  // Tutoriels par thème
  static const _tutoriels = [
    _Tutoriel(
      theme: 'Démarrage',
      titre: 'Comment utiliser ChainCacao',
      description: 'Présentation générale de l\'application',
      icone: Icons.play_circle_rounded,
      duree: '1 min 05 sec',
      youtubeIds: {
        'fr': 'GsK6F0ErLdc',
        'ewe': 'METTRE_ID_ICI',
        'kab': 'METTRE_ID_ICI',
      },
    ),
    _Tutoriel(
      theme: 'Récolte',
      titre: 'Enregistrer une récolte',
      description: 'De la sélection du champ à la confirmation',
      icone: Icons.grass_rounded,
      duree: '1 min 03 sec',
      youtubeIds: {
        'fr': 'YSpeAkIozjQ',
        'ewe': 'METTRE_ID_ICI',
        'kab': 'METTRE_ID_ICI',
      },
    ),
    _Tutoriel(
      theme: 'Qualité',
      titre: 'Faire un bon diagnostic',
      description: 'Évaluer la maturité, santé et humidité',
      icone: Icons.health_and_safety_rounded,
      duree: '1 min',
      youtubeIds: {
        'fr': 'YSpeAkIozjQ',
        'ewe': 'METTRE_ID_ICI',
        'kab': 'METTRE_ID_ICI',
      },
    ),
    _Tutoriel(
      theme: 'Traçabilité',
      titre: 'Comprendre le QR code',
      description: 'À quoi sert votre QR code de récolte',
      icone: Icons.qr_code_rounded,
      duree: '1 min 32 sec',
      youtubeIds: {
        'fr': 'zeOt-6GDb00',
        'ewe': 'METTRE_ID_ICI',
        'kab': 'METTRE_ID_ICI',
      },
    ),
    _Tutoriel(
      theme: 'GPS',
      titre: 'La vérification GPS',
      description: 'Pourquoi être dans son champ est obligatoire',
      icone: Icons.gps_fixed_rounded,
      duree: '2 min',
      youtubeIds: {
        'fr': 'METTRE_ID_ICI',
        'ewe': 'METTRE_ID_ICI',
        'kab': 'METTRE_ID_ICI',
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    _chargerLangue();
  }

  Future<void> _chargerLangue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _langue = prefs.getString(CCStockage.langue) ?? 'fr');
  }

  Future<void> _changerLangue(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(CCStockage.langue, code);
    setState(() => _langue = code);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Langue mise à jour',
          style: GoogleFonts.dmSans(color: CCCouleurs.vertProfond),
        ),
        backgroundColor: CCCouleurs.limeVif,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _deconnecter() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Se déconnecter ?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: CCCouleurs.vertProfond,
          ),
        ),
        content: Text(
          'Vous devrez vous reconnecter avec votre QR code ou identifiant.',
          style: GoogleFonts.dmSans(color: CCCouleurs.grisTexte),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Annuler',
              style: GoogleFonts.dmSans(color: CCCouleurs.grisTexte),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CCCouleurs.erreur,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Déconnecter',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                color: CCCouleurs.blanc,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirme == true) {
      // TODO : AuthService.logout() — effacer token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(CCStockage.token);
      if (!mounted) return;
      context.go(CCRoutes.connexion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initiales = _nom
        .trim()
        .split(' ')
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: CCCouleurs.feuilleClaire,
          appBar: AppBar(
            backgroundColor: CCCouleurs.feuilleClaire,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: GestureDetector(
              onTap: () => context.go(CCRoutes.accueil),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CCCouleurs.blanc,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: CCCouleurs.feuilleGrise),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: CCCouleurs.vertProfond,
                  size: 18,
                ),
              ),
            ),
            title: Text(
              'Mon profil',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: CCCouleurs.vertProfond,
              ),
            ),
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header profil ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CCCouleurs.vertProfond,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CCCouleurs.vertForet,
                          border: Border.all(
                            color: CCCouleurs.limeVif,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initiales,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: CCCouleurs.limeVif,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Infos
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nom,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: CCCouleurs.blanc,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _cooperative,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: CCCouleurs.feuilleClaire.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _telephone,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: CCCouleurs.limeVif.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Section langue ────────────────────────────────────────
                _TitreSection(titre: 'Langue', icone: Icons.language_rounded),
                const SizedBox(height: 12),
                ..._langues.map((l) {
                  final (code, drapeau, label) = l;
                  final estActif = _langue == code;
                  return GestureDetector(
                    onTap: () => _changerLangue(code),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: estActif
                            ? CCCouleurs.vertProfond
                            : CCCouleurs.blanc,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: estActif
                              ? CCCouleurs.vertProfond
                              : CCCouleurs.feuilleGrise,
                          width: estActif ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(drapeau, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              label,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: estActif
                                    ? CCCouleurs.limeVif
                                    : CCCouleurs.vertProfond,
                              ),
                            ),
                          ),
                          if (estActif)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: CCCouleurs.limeVif,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: CCCouleurs.vertProfond,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 28),

                // ── Section tutoriels ─────────────────────────────────────
                _TitreSection(
                  titre: 'Tutoriels vidéo',
                  icone: Icons.play_lesson_rounded,
                ),
                const SizedBox(height: 12),
                ..._tutoriels.map(
                  (t) => _CarteTutoriel(tutoriel: t, langue: _langue),
                ),
                const SizedBox(height: 28),

                // ── Déconnexion ───────────────────────────────────────────
                _TitreSection(
                  titre: 'Compte',
                  icone: Icons.manage_accounts_rounded,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _deconnecter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CCCouleurs.erreurClair,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: CCCouleurs.erreur.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: CCCouleurs.erreur.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: CCCouleurs.erreur,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Se déconnecter',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: CCCouleurs.erreur,
                                ),
                              ),
                              Text(
                                'Vous serez redirigé vers la connexion',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: CCCouleurs.erreur.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: CCCouleurs.erreur,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        BoutonAudioGuide(cleAudio: ServiceAudio.profil),
      ],
    );
  }
}

// ─── Carte tutoriel ───────────────────────────────────────────────────────
class _CarteTutoriel extends StatelessWidget {
  final _Tutoriel tutoriel;
  final String langue;

  const _CarteTutoriel({required this.tutoriel, required this.langue});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _lancerTutoriel(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CCCouleurs.blanc,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CCCouleurs.feuilleGrise),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: CCCouleurs.succesClair,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                tutoriel.icone,
                color: CCCouleurs.vertForet,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge thème
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: CCCouleurs.vertProfond.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tutoriel.theme,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: CCCouleurs.vertProfond,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tutoriel.titre,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CCCouleurs.vertProfond,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tutoriel.description,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: CCCouleurs.grisTexte,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Durée + play
            Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: CCCouleurs.vertProfond,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: CCCouleurs.limeVif,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tutoriel.duree,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: CCCouleurs.grisTexte,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _lancerTutoriel(BuildContext context) {
    // TODO : lancer la vraie vidéo selon la langue
    // Les vidéos seront dans assets/videos/{langue}/{theme}.mp4
    // ou via une URL distante
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ModalTutoriel(tutoriel: tutoriel, langue: langue),
    );
  }
}

// ─── Modal tutoriel ───────────────────────────────────────────────────────
class _ModalTutoriel extends StatelessWidget {
  final _Tutoriel tutoriel;
  final String langue;

  const _ModalTutoriel({required this.tutoriel, required this.langue});

  String get _nomLangue {
    switch (langue) {
      case 'ewe':
        return 'Éwé';
      case 'kab':
        return 'Kabiyè';
      default:
        return 'Français';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CCCouleurs.blanc,
        borderRadius: BorderRadius.circular(28),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poignée
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CCCouleurs.feuilleGrise,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Icône
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: CCCouleurs.succesClair,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                tutoriel.icone,
                color: CCCouleurs.vertForet,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              tutoriel.titre,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: CCCouleurs.vertProfond,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              tutoriel.description,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: CCCouleurs.grisTexte,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Badge langue
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: CCCouleurs.vertProfond.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Vidéo en $_nomLangue · ${tutoriel.duree}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CCCouleurs.vertProfond,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Zone vidéo — YouTube si disponible, placeholder sinon
            Builder(
              builder: (_) {
                final videoId =
                    tutoriel.youtubeIds[langue] ??
                    tutoriel.youtubeIds['fr']; // fallback français

                // ── Pas encore de vidéo ─────────────────────────────────
                if (videoId == null || videoId == 'METTRE_ID_ICI') {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: CCCouleurs.nuit,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: CCCouleurs.limeVif,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: CCCouleurs.vertProfond,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Vidéo bientôt disponible',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: CCCouleurs.feuilleClaire.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // ── Vidéo YouTube disponible ─────────────────────────────
                final controller = YoutubePlayerController(
                  initialVideoId: videoId,
                  flags: const YoutubePlayerFlags(
                    autoPlay: false,
                    mute: false,
                    loop: false,
                    isLive: false,
                    forceHD: false,
                    enableCaption: false,
                  ),
                );

                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: YoutubePlayer(
                    controller: controller,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: CCCouleurs.limeVif,
                    progressColors: const ProgressBarColors(
                      playedColor: CCCouleurs.limeVif,
                      handleColor: CCCouleurs.vertForet,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Bouton fermer
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CCCouleurs.vertProfond,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Fermer',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: CCCouleurs.limeVif,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Titre section
class _TitreSection extends StatelessWidget {
  final String titre;
  final IconData icone;

  const _TitreSection({required this.titre, required this.icone});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, size: 18, color: CCCouleurs.vertForet),
        const SizedBox(width: 8),
        Text(
          titre,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: CCCouleurs.vertProfond,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

// ─── Modèle tutoriel
class _Tutoriel {
  final String theme;
  final String titre;
  final String description;
  final IconData icone;
  final String duree;
  final Map<String, String> youtubeIds; // langue -> ID vidéo

  const _Tutoriel({
    required this.theme,
    required this.titre,
    required this.description,
    required this.icone,
    required this.duree,
    this.youtubeIds = const {},
  });
}
