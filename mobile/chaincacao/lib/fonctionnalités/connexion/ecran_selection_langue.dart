// lib/fonctionnalités/connexion/ecran_selection_langue.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../configuration/theme.dart';
import '../../configuration/constantes.dart';
import '../../configuration/routage.dart';
import '../../services/service_audio.dart';

class EcranSelectionLangue extends StatefulWidget {
  const EcranSelectionLangue({super.key});

  @override
  State<EcranSelectionLangue> createState() => _EcranSelectionLangueState();
}

class _EcranSelectionLangueState extends State<EcranSelectionLangue> {
  final ServiceAudio _audio = ServiceAudio();
  String? _choisie;

  static const _langues = [
    _Langue(code: 'fr', label: 'Français', sousTitre: 'Langue officielle', drapeau: '🇫🇷'),
    _Langue(code: 'ewe', label: 'Éwé', sousTitre: 'National', drapeau: '🇹🇬'),
    _Langue(code: 'kab', label: 'Kabiyè', sousTitre: 'National', drapeau: '🇹🇬'),
    _Langue(code: 'akp', label: 'Akposso', sousTitre: 'National', drapeau: '🇹🇬'),
  ];

  @override
  void initState() {
    super.initState();
    _audio.jouer('selection_langue', langue: 'fr');
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CCCouleurs.vertProfond,
      body: Stack(
        children: [
          // 1. Fond avec une légère texture ou dégradé (inspiré de ton image)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [CCCouleurs.vertProfond, Color(0xFF012220)],
              ),
            ),
          ),

          CustomScrollView(
            // BouncingScrollPhysics donne cette sensation "sensible" au toucher
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              // 3. Panneau blanc interactif
              SliverToBoxAdapter(
                child: Container(
                  // S'assure que le panneau occupe tout l'espace restant
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 90,
                  ),
                  decoration: const BoxDecoration(
                    color: CCCouleurs.feuilleClaire,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sélectionnez votre langue',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: CCCouleurs.vertProfond,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tia gbe siwo wòle · Cɛ kɩtɩŋ wɛ',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: CCCouleurs.grisTexte.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      ..._langues.map((l) => _CarteLangue(
                        langue: l,
                        estChoisie: _choisie == l.code,
                        onTap: () async {
                          setState(() => _choisie = l.code);
                          await _audio.jouer('selection_langue', langue: l.code);
                        },
                      )),

                      const SizedBox(height: 24),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _audio.jouer('selection_langue', langue: _choisie ?? 'fr'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.volume_up_rounded, color: CCCouleurs.vertForet),
                          label: Text(
                            'Écouter à nouveau',
                            style: GoogleFonts.dmSans(
                              color: CCCouleurs.vertForet,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 4. Bouton Continuer avec une ombre plus prononcée
          Positioned(
            bottom: 35,
            left: 24,
            right: 24,
            child: AnimatedSlide(
              offset: _choisie != null ? Offset.zero : const Offset(0, 0.2),
              duration: const Duration(milliseconds: 300),
              child: AnimatedOpacity(
                opacity: _choisie != null ? 1.0 : 0.0, // Cache le bouton si rien n'est choisi
                duration: const Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: CCCouleurs.vertProfond.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CCCouleurs.vertProfond,
                      foregroundColor: CCCouleurs.limeVif,
                      minimumSize: const Size.fromHeight(62),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 0,
                    ),
                    onPressed: _choisie != null ? _continuer : null,
                    child: Text(
                      'Continuer',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _continuer() async {
    if (_choisie == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(CCStockage.langue, _choisie!);
    if (!mounted) return;
    context.go(CCRoutes.connexion);
  }
}

// ─── Widget carte langue 
class _CarteLangue extends StatelessWidget {
  final _Langue      langue;
  final bool         estChoisie;
  final VoidCallback onTap;

  const _CarteLangue({
    required this.langue,
    required this.estChoisie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: estChoisie ? CCCouleurs.vertProfond : CCCouleurs.blanc,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: estChoisie ? CCCouleurs.limeVif : CCCouleurs.feuilleGrise,
            width: estChoisie ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: estChoisie
                  ? CCCouleurs.vertProfond.withOpacity(0.2)
                  : Colors.black.withOpacity(0.04),
              blurRadius: estChoisie ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Drapeau
            Text(langue.drapeau, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 16),

            // Nom + sous-titre
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    langue.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: estChoisie
                          ? CCCouleurs.limeVif
                          : CCCouleurs.vertProfond,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    langue.sousTitre,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: estChoisie
                          ? CCCouleurs.feuilleClaire.withOpacity(0.65)
                          : CCCouleurs.grisTexte,
                    ),
                  ),
                ],
              ),
            ),

            // Cercle check animé
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: estChoisie ? CCCouleurs.limeVif : Colors.transparent,
                border: Border.all(
                  color: estChoisie
                      ? CCCouleurs.limeVif
                      : CCCouleurs.feuilleGrise,
                  width: 2,
                ),
              ),
              child: estChoisie
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
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

// ─── Modèle interne 
class _Langue {
  final String code;
  final String label;
  final String sousTitre;
  final String drapeau;

  const _Langue({
    required this.code,
    required this.label,
    required this.sousTitre,
    required this.drapeau,
  });
}