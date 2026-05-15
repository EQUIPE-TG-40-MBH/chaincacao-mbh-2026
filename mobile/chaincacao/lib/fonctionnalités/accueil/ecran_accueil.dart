// lib/fonctionnalités/accueil/ecran_accueil.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../configuration/theme.dart';
import '../../configuration/routage.dart';
import '../../composants/bouton_audio_aide.dart';
import '../../services/service_audio.dart';

class EcranAccueil extends StatefulWidget {
  const EcranAccueil({super.key});

  @override
  State<EcranAccueil> createState() => _EcranAccueilState();
}

class _EcranAccueilState extends State<EcranAccueil> {
  // ── TODO : Remplacer par AuthService.agriculteurConnecte quand API prête
  final _agriculteur = _DonneesAgriculteur(
    nom: 'Koami Agbéko',
    cooperative: 'Coopérative de Kpalimé', // null si pas de coopérative
    photoUrl: null,
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: CCCouleurs.feuilleClaire,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header(agriculteur: _agriculteur)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 100),
                sliver: SliverList(
                  // Dans SliverList → delegate → children
                  delegate: SliverChildListDelegate([
                    _SectionActions(), // ← ajouter ici
                    const SizedBox(height: 28),
                    _SectionMesRecoltes(),
                  ]),
                ),
              ),
            ],
          ),
        ),
        // Bouton audio d'aide flottant
        BoutonAudioGuide(cleAudio: ServiceAudio.accueil),
      ],
    );
  }
}

// ─── Header simplifié
class _Header extends StatelessWidget {
  final _DonneesAgriculteur agriculteur;
  const _Header({required this.agriculteur});

  String get _salutation {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour 👋';
    if (h < 18) return 'Bon après-midi 👋';
    return 'Bonsoir 👋';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CCCouleurs.vertProfond,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Row(
            children: [
              // ── Avatar initiales / photo
              // TODO : afficher la vraie photo depuis agriculteur.photoUrl
              _AvatarAgriculteur(
                photoUrl: agriculteur.photoUrl,
                nom: agriculteur.nom,
              ),
              const SizedBox(width: 14),

              // ── Nom + coopérative
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _salutation,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: CCCouleurs.feuilleClaire.withOpacity(0.65),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      agriculteur.nom,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: CCCouleurs.blanc,
                        letterSpacing: -0.3,
                      ),
                    ),

                    // ── Coopérative — masquée si null
                    // TODO : brancher sur agriculteur.cooperative depuis l'API
                    if (agriculteur.cooperative != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: CCCouleurs.limeVif,
                              size: 13,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                agriculteur.cooperative!,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: CCCouleurs.feuilleClaire.withOpacity(
                                    0.65,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // ── Cloche notifications
              // TODO : afficher un badge rouge si nouvelles notifications
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: CCCouleurs.blanc.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_rounded,
                  color: CCCouleurs.limeVif,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => context.push(CCRoutes.profil),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: CCCouleurs.blanc.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: CCCouleurs.limeVif,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Avatar
class _AvatarAgriculteur extends StatelessWidget {
  final String? photoUrl;
  final String nom;
  const _AvatarAgriculteur({this.photoUrl, required this.nom});

  @override
  Widget build(BuildContext context) {
    final initiales = nom
        .trim()
        .split(' ')
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: CCCouleurs.limeVif, width: 2),
        color: CCCouleurs.vertForet,
        // TODO : charger l'image réseau quand photoUrl disponible
        image: photoUrl != null
            ? DecorationImage(image: NetworkImage(photoUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: photoUrl == null
          ? Center(
              child: Text(
                initiales,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: CCCouleurs.limeVif,
                ),
              ),
            )
          : null,
    );
  }
}

// ─── Section récoltes
class _SectionMesRecoltes extends StatelessWidget {
  // TODO : remplacer par LotService.mesLots depuis l'API Jacques
  // GET /api/lots/ — retourne la liste des lots de l'agriculteur connecté
  final _recoltes = const [
    // _DonneesRecolte(
    //   id: 'LOT-2024-001',
    //   poids: 120,
    //   statut: 'certifie',
    //   date: 'Aujourd\'hui',
    //   culture: 'Cacao',
    // ),
    // _DonneesRecolte(
    //   id: 'LOT-2024-002',
    //   poids: 85,
    //   statut: 'transit',
    //   date: 'Hier',
    //   culture: 'Cacao',
    // ),
    // _DonneesRecolte(
    //   id: 'LOT-2024-003',
    //   poids: 200,
    //   statut: 'attente',
    //   date: '09 Mai',
    //   culture: 'Cacao',
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mes récoltes',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: CCCouleurs.vertProfond,
                letterSpacing: -0.2,
              ),
            ),
            GestureDetector(
              onTap: () => context.go(CCRoutes.mesScans),
              child: Text(
                'Voir tout',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CCCouleurs.vertForet,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Liste ou état vide
        if (_recoltes.isEmpty)
          _EtatVide()
        else
          ..._recoltes.map((r) => _CarteRecolte(recolte: r)),
      ],
    );
  }
}

// ─── Carte récolte
class _CarteRecolte extends StatelessWidget {
  final _DonneesRecolte recolte;
  const _CarteRecolte({required this.recolte});

  @override
  Widget build(BuildContext context) {
    final config = _configStatut(recolte.statut);

    return GestureDetector(
      // TODO : naviguer vers le détail du lot — context.go(CCRoutes.detailLot, extra: recolte.id)
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            // Icône statut
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: config.couleurFond,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(config.icone, color: config.couleur, size: 24),
            ),
            const SizedBox(width: 14),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recolte.id,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CCCouleurs.vertProfond,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${recolte.culture} · ${recolte.poids} kg · ${recolte.date}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: CCCouleurs.grisTexte,
                    ),
                  ),
                ],
              ),
            ),

            // Badge statut
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: config.couleurFond,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                config.label,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: config.couleur,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ConfigStatut _configStatut(String statut) {
    switch (statut) {
      case 'certifie':
        return _ConfigStatut(
          label: '✓ Certifié',
          icone: Icons.verified_rounded,
          couleur: CCCouleurs.vertForet,
          couleurFond: CCCouleurs.succesClair,
        );
      case 'transit':
        return _ConfigStatut(
          label: '→ Transit',
          icone: Icons.local_shipping_rounded,
          couleur: CCCouleurs.transit,
          couleurFond: CCCouleurs.transitClair,
        );
      default:
        return _ConfigStatut(
          label: '⏳ Attente',
          icone: Icons.hourglass_top_rounded,
          couleur: CCCouleurs.attention,
          couleurFond: CCCouleurs.attentionClair,
        );
    }
  }
}

// ─── État vide
class _EtatVide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Center(
            child: Icon(
              Icons.grass_rounded,
              size: 64,
              color: const Color.fromARGB(255, 177, 211, 157),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Aucune récolte enregistrée',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CCCouleurs.grisTexte,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Appuyez sur + pour ajouter votre première récolte',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: CCCouleurs.grisTexte,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section boutons d'action
class _SectionActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Ajouter une récolte
        Expanded(
          child: GestureDetector(
            onTap: () => context.go(CCRoutes.selectionChamp),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CCCouleurs.vertProfond,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: CCCouleurs.vertProfond.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: CCCouleurs.limeVif.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_circle_rounded,
                      color: CCCouleurs.limeVif,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Texte
                  Text(
                    'Ajouter',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CCCouleurs.blanc,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'une récolte',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: CCCouleurs.feuilleClaire.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // ── Voir mes récoltes
        Expanded(
          child: GestureDetector(
            onTap: () => context.go(CCRoutes.mesScans),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CCCouleurs.blanc,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: CCCouleurs.feuilleGrise),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: CCCouleurs.succesClair,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.list_alt_rounded,
                      color: CCCouleurs.vertForet,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Texte
                  Text(
                    'Voir',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CCCouleurs.vertProfond,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'mes récoltes',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: CCCouleurs.grisTexte,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Modèles internes

class _DonneesAgriculteur {
  final String nom;
  final String? cooperative; // null si pas de coopérative
  final String? photoUrl; // null = afficher les initiales

  const _DonneesAgriculteur({
    required this.nom,
    this.cooperative,
    this.photoUrl,
  });
}

class _DonneesRecolte {
  final String id;
  final double poids;
  final String statut; // 'certifie' | 'transit' | 'attente'
  final String date;
  final String culture; // 'Cacao' | 'Café' | etc.

  const _DonneesRecolte({
    required this.id,
    required this.poids,
    required this.statut,
    required this.date,
    required this.culture,
  });
}

class _ConfigStatut {
  final String label;
  final IconData icone;
  final Color couleur;
  final Color couleurFond;

  const _ConfigStatut({
    required this.label,
    required this.icone,
    required this.couleur,
    required this.couleurFond,
  });
}
