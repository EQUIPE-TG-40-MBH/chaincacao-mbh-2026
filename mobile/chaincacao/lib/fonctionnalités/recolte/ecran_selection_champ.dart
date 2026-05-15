// lib/fonctionnalités/recolte/ecran_selection_champ.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../configuration/theme.dart';
import '../../configuration/routage.dart';
import '../../modeles/champ.dart';

class EcranSelectionChamp extends StatefulWidget {
  const EcranSelectionChamp({super.key});

  @override
  State<EcranSelectionChamp> createState() => _EcranSelectionChampState();
}

class _EcranSelectionChampState extends State<EcranSelectionChamp> {
  Champ? _champChoisi;

  // TODO : remplacer par producteur.champsPrives depuis AuthService
  // GET /api/farmers/{id}/ → champs de l'agriculteur connecté
  final List<Champ> _champs = [
    Champ(
      id: 'CH-001',
      nom: 'Champ de Kpalimé Nord',
      latitude: 6.191601,
      longitude: 1.147932,
      rayonCloture: 500,
      estCollectif: false,
      superficieHa: 2.5,
    ),
    Champ(
      id: 'CH-002',
      nom: 'Champ Bas-fond Est',
      latitude: 6.17504,
      longitude: 0.21367,
      rayonCloture: 750,
      estCollectif: false,
      superficieHa: 1.8,
    ),
    Champ(
      id: 'CH-003',
      nom: 'Parcelle Familiale',
      latitude: 6.9102,
      longitude: 0.6289,
      rayonCloture: 80,
      estCollectif: false,
      superficieHa: 0.9,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: CCCouleurs.feuilleClaire,
          appBar: AppBar(
            backgroundColor: CCCouleurs.feuilleClaire,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: GestureDetector(
              onTap: () => context.push(CCRoutes.accueil),
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
              'Choisir un champ',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: CCCouleurs.vertProfond,
              ),
            ),
          ),

          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Sous-titre
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Text(
                  'Sélectionnez le champ dans lequel vous\neffectuez la récolte aujourd\'hui.',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: CCCouleurs.grisTexte,
                    height: 1.5,
                  ),
                ),
              ),

              // ── État vide
              if (_champs.isEmpty)
                _EtatVide()
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    itemCount: _champs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _CarteChamp(
                      champ: _champs[i],
                      estChoisi: _champChoisi?.id == _champs[i].id,
                      onTap: () => setState(() => _champChoisi = _champs[i]),
                    ),
                  ),
                ),
            ],
          ),

          // ── Bouton confirmer fixe en bas
          bottomNavigationBar: _BoutonConfirmer(
            champChoisi: _champChoisi,
            onConfirmer: _confirmer,
          ),
        ),
      ],
    );
  }

  void _confirmer() {
    if (_champChoisi == null) return;
    context.push(CCRoutes.verificationGps, extra: _champChoisi);
  }
}

// ─── Carte champ
class _CarteChamp extends StatelessWidget {
  final Champ champ;
  final bool estChoisi;
  final VoidCallback onTap;

  const _CarteChamp({
    required this.champ,
    required this.estChoisi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: estChoisi ? CCCouleurs.vertProfond : CCCouleurs.blanc,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: estChoisi ? CCCouleurs.limeVif : CCCouleurs.feuilleGrise,
            width: estChoisi ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: estChoisi
                  ? CCCouleurs.vertProfond.withOpacity(0.2)
                  : Colors.black.withOpacity(0.04),
              blurRadius: estChoisi ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Icône champ
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: estChoisi
                    ? CCCouleurs.limeVif.withOpacity(0.15)
                    : CCCouleurs.succesClair,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.landscape_rounded,
                color: estChoisi ? CCCouleurs.limeVif : CCCouleurs.vertForet,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),

            // ── Infos champ
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    champ.nom,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: estChoisi
                          ? CCCouleurs.blanc
                          : CCCouleurs.vertProfond,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Superficie
                      _PillInfo(
                        icone: Icons.square_foot_rounded,
                        label: champ.superficieFormatee,
                        estChoisi: estChoisi,
                      ),
                      const SizedBox(width: 8),
                      // Rayon géofencing
                      _PillInfo(
                        icone: Icons.radar_rounded,
                        label: champ.rayonFormate,
                        estChoisi: estChoisi,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Check animé ───────────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: estChoisi ? CCCouleurs.limeVif : Colors.transparent,
                border: Border.all(
                  color: estChoisi
                      ? CCCouleurs.limeVif
                      : CCCouleurs.feuilleGrise,
                  width: 2,
                ),
              ),
              child: estChoisi
                  ? const Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: CCCouleurs.vertProfond,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pill info (superficie, rayon)
class _PillInfo extends StatelessWidget {
  final IconData icone;
  final String label;
  final bool estChoisi;

  const _PillInfo({
    required this.icone,
    required this.label,
    required this.estChoisi,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icone,
          size: 12,
          color: estChoisi
              ? CCCouleurs.feuilleClaire.withOpacity(0.65)
              : CCCouleurs.grisTexte,
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: estChoisi
                ? CCCouleurs.feuilleClaire.withOpacity(0.65)
                : CCCouleurs.grisTexte,
          ),
        ),
      ],
    );
  }
}

// ─── Bouton confirmer
class _BoutonConfirmer extends StatelessWidget {
  final Champ? champChoisi;
  final VoidCallback onConfirmer;

  const _BoutonConfirmer({
    required this.champChoisi,
    required this.onConfirmer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: CCCouleurs.blanc,
        border: Border(top: BorderSide(color: CCCouleurs.feuilleGrise)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Champ sélectionné — feedback visuel
          if (champChoisi != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: CCCouleurs.succesClair,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: CCCouleurs.vertForet,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      champChoisi!.nom,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CCCouleurs.vertForet,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Bouton
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: champChoisi != null
                    ? CCCouleurs.vertProfond
                    : CCCouleurs.feuilleGrise,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: champChoisi != null ? 6 : 0,
                shadowColor: CCCouleurs.vertProfond.withOpacity(0.25),
              ),
              onPressed: champChoisi != null ? onConfirmer : null,
              child: Text(
                'Confirmer ce champ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: champChoisi != null
                      ? CCCouleurs.limeVif
                      : CCCouleurs.grisTexte,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── État vide
class _EtatVide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Icon(
                Icons.landscape_outlined,
                size: 72,
                color: const Color.fromARGB(255, 176, 209, 157),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Aucun champ enregistré',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: CCCouleurs.grisTexte,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Contactez votre coopérative pour\nenregistrer vos champs.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: CCCouleurs.grisTexte,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
