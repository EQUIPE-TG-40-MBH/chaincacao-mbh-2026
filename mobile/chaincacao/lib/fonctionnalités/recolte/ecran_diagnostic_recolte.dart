// lib/fonctionnalités/recolte/ecran_diagnostic_recolte.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../configuration/theme.dart';
import '../../configuration/routage.dart';
import '../../configuration/constantes.dart';
import '../../modeles/champ.dart';
import '../../services/service_audio.dart';

// ─── Modèle de données du diagnostic ──────────────────────────────────────
class DonneesRecolte {
  // Étape 1 — Maturité
  String? maturite; // 'vert' | 'jaune' | 'rouge'

  // Étape 2 — Santé
  bool? aParasites;
  bool? aMoisissures;
  bool? aTaches;

  // Étape 3 — Humidité
  String? humidite; // 'sec' | 'humide' | 'mouille'
  double? tauxHumidite; // si appareil de mesure disponible

  // Étape 4 — Photo
  List<String> photos = []; // 3 photos max

  // Horodatage automatique
  final DateTime horodatage = DateTime.now();
}

class EcranDiagnosticRecolte extends StatefulWidget {
  final Champ champ;

  const EcranDiagnosticRecolte({super.key, required this.champ});

  @override
  State<EcranDiagnosticRecolte> createState() => _EcranDiagnosticRecolteState();
}

class _EcranDiagnosticRecolteState extends State<EcranDiagnosticRecolte> {
  final PageController _pageCtrl = PageController();
  final DonneesRecolte _donnees = DonneesRecolte();
  final ServiceAudio _audio = ServiceAudio();

  int _etapeActuelle = 0;
  String _langue = 'fr';

  @override
  void initState() {
    super.initState();
    _chargerLangue();
  }

  // Définition des étapes
  static const _etapes = [
    _Etape(
      icone: Icons.color_lens_rounded,
      label: 'Maturité',
      description: 'État de maturité du cacao',
      cleAudio: 'diagnostic_maturite',
    ),
    _Etape(
      icone: Icons.health_and_safety_rounded,
      label: 'Santé',
      description: 'État sanitaire du produit',
      cleAudio: 'diagnostic_sante',
    ),
    _Etape(
      icone: Icons.water_drop_rounded,
      label: 'Humidité',
      description: 'Taux d\'humidité estimé',
      cleAudio: 'diagnostic_humidite',
    ),
    _Etape(
      icone: Icons.camera_alt_rounded,
      label: 'Photo',
      description: 'Photo de contrôle',
      cleAudio: 'diagnostic_photo',
    ),
  ];

  Future<void> _chargerLangue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _langue = prefs.getString(CCStockage.langue) ?? 'fr';
    });
    // Jouer l'audio de la première étape
    _audio.jouer(_etapes[0].cleAudio, langue: _langue);
  }

  void _jouerAudio() =>
      _audio.jouer(_etapes[_etapeActuelle].cleAudio, langue: _langue);

  void _suivant() {
    if (_etapeActuelle < _etapes.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _etapeActuelle++);

      // Jouer l'audio de la nouvelle étape
      Future.delayed(
        const Duration(milliseconds: 400),
        () => _audio.jouer(_etapes[_etapeActuelle].cleAudio, langue: _langue),
      );
    }
  }

  void _precedent() {
    if (_etapeActuelle > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _etapeActuelle--);
    } else {
      context.pop();
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CCCouleurs.feuilleClaire,
      // Bouton audio flottant
      floatingActionButton: _BoutonAudio(onTap: _jouerAudio),
      appBar: AppBar(
        backgroundColor: CCCouleurs.feuilleClaire,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: _precedent,
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
        title: Column(
          children: [
            Text(
              'Diagnostic récolte',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: CCCouleurs.vertProfond,
              ),
            ),
            Text(
              widget.champ.nom,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: CCCouleurs.grisTexte,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 16),

          // ── Progress bar ────────────────────────────────────────────
          _ProgressBar(etapes: _etapes, etapeActuelle: _etapeActuelle),

          const SizedBox(height: 24),

          // ── Contenu des étapes ──────────────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _EtapeMaturite(
                  donnees: _donnees,
                  culture: widget.champ.culture ?? 'Cacao',
                  onSuivant: _suivant,
                ),
                _EtapeSante(
                  donnees: _donnees,
                  culture: widget.champ.culture ?? 'cacao',
                  onSuivant: _suivant,
                ),
                _EtapeHumidite(
                  donnees: _donnees,
                  culture: widget.champ.culture ?? 'cacao',
                  onSuivant: _suivant,
                ),
                _EtapePhoto(
                  donnees: _donnees,
                  culture: widget.champ.culture ?? 'Cacao',
                  champ: widget.champ,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bouton audio flottant ────────────────────────────────────────────────
class _BoutonAudio extends StatelessWidget {
  final VoidCallback onTap;
  const _BoutonAudio({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: CCCouleurs.vertForet,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: CCCouleurs.vertForet.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.volume_up_rounded,
          color: CCCouleurs.limeVif,
          size: 24,
        ),
      ),
    );
  }
}

// ─── Progress bar cercles + icônes ────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final List<_Etape> etapes;
  final int etapeActuelle;

  const _ProgressBar({required this.etapes, required this.etapeActuelle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(etapes.length * 2 - 1, (index) {
          // Indices pairs = cercles, indices impairs = lignes
          if (index.isOdd) {
            // ── Ligne entre 2 cercles ─────────────────────────────────
            final etapeIndex = index ~/ 2;
            final estComplete = etapeIndex < etapeActuelle;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                height: 3,
                decoration: BoxDecoration(
                  color: estComplete
                      ? CCCouleurs.vertForet
                      : CCCouleurs.feuilleGrise,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }

          // ── Cercle de l'étape ─────────────────────────────────────
          final etapeIndex = index ~/ 2;
          final etape = etapes[etapeIndex];
          final estActive = etapeIndex == etapeActuelle;
          final estComplete = etapeIndex < etapeActuelle;

          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: estActive ? 52 : 44,
                height: estActive ? 52 : 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: estComplete
                      ? CCCouleurs.vertForet
                      : estActive
                      ? CCCouleurs.vertProfond
                      : CCCouleurs.blanc,
                  border: Border.all(
                    color: estComplete
                        ? CCCouleurs.vertForet
                        : estActive
                        ? CCCouleurs.vertProfond
                        : CCCouleurs.feuilleGrise,
                    width: 2,
                  ),
                  boxShadow: estActive
                      ? [
                          BoxShadow(
                            color: CCCouleurs.vertProfond.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  estComplete ? Icons.check_rounded : etape.icone,
                  size: estActive ? 26 : 20,
                  color: estComplete || estActive
                      ? CCCouleurs.limeVif
                      : CCCouleurs.grisTexte,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                etape.label,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: estActive ? FontWeight.w700 : FontWeight.w400,
                  color: estActive
                      ? CCCouleurs.vertProfond
                      : estComplete
                      ? CCCouleurs.vertForet
                      : CCCouleurs.grisTexte,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Helper : textes adaptés à la culture ────────────────────────────────
class _TextesCulture {
  final String culture;
  _TextesCulture(this.culture);

  bool get estCacao => culture.toLowerCase() == 'cacao';

  String get produit => estCacao ? 'cabosse' : 'cerise de café';
  String get produits => estCacao ? 'cabosses' : 'cerises de café';
  String get maturiteVert => estCacao
      ? 'Cabosses encore vertes,\nrécolte prématurée'
      : 'Cerises encore vertes,\nnon mûres';
  String get maturiteJaune => estCacao
      ? 'Couleur jaune/orange,\nmaturité optimale'
      : 'Cerises rouges brillantes,\nmaturité optimale';
  String get maturiteRouge => estCacao
      ? 'Cabosses rouges/noires,\nrécolte tardive'
      : 'Cerises noires/fripées,\nsurmaturité';
  String get photoPlans => estCacao
      ? 'Vue d\'ensemble du tas,\ngros plan cabosse,\ncoupe transversale'
      : 'Vue du tas de cerises,\ngros plan couleur,\ngrain après dépulpage';
}

// ─── Étape 1 — Maturité ───────────────────────────────────────────────────
class _EtapeMaturite extends StatefulWidget {
  final DonneesRecolte donnees;
  final String culture;
  final VoidCallback onSuivant;

  const _EtapeMaturite({
    required this.donnees,
    required this.culture,
    required this.onSuivant,
  });

  @override
  State<_EtapeMaturite> createState() => _EtapeMaturiteState();
}

class _EtapeMaturiteState extends State<_EtapeMaturite> {
  late final _TextesCulture _textes;
  @override
  void initState() {
    super.initState();
    _textes = _TextesCulture(widget.culture);
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      _OptionMaturite(
        valeur: 'vert',
        label: 'Pas mûr',
        description: _textes.maturiteVert,
        couleur: const Color(0xFF2D7A2D),
        couleurFond: const Color(0xFFE8F5E8),
        icone: Icons.eco_rounded,
      ),
      _OptionMaturite(
        valeur: 'jaune',
        label: 'Bien mûr',
        description: _textes.maturiteJaune,
        couleur: const Color(0xFFB8860B),
        couleurFond: const Color(0xFFFFF8E1),
        icone: Icons.wb_sunny_rounded,
      ),
      _OptionMaturite(
        valeur: 'rouge',
        label: 'Trop mûr',
        description: _textes.maturiteRouge,
        couleur: const Color(0xFFC0392B),
        couleurFond: const Color(0xFFFDECEC),
        icone: Icons.warning_amber_rounded,
      ),
    ];
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge culture
                _BadgeCulture(culture: widget.culture),
                const SizedBox(height: 16),
                // ── Titre ──────────────────────────────────────────────────
                Text(
                  'État de maturité',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: CCCouleurs.vertProfond,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Quelle est la couleur générale\nde vos ${_textes.produits} ?',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: CCCouleurs.grisTexte,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Options de maturité ─────────────────────────────────────
                ...options.map(
                  (o) => _CarteOptionMaturite(
                    option: o,
                    estChoisi: widget.donnees.maturite == o.valeur,
                    onTap: () =>
                        setState(() => widget.donnees.maturite = o.valeur),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: _BoutonSuivant(
            actif: widget.donnees.maturite != null,
            onTap: widget.onSuivant,
            label: 'Suivant',
          ),
        ),
      ],
    );
  }
}

class _CarteOptionMaturite extends StatelessWidget {
  final _OptionMaturite option;
  final bool estChoisi;
  final VoidCallback onTap;

  const _CarteOptionMaturite({
    required this.option,
    required this.estChoisi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: estChoisi ? option.couleur : CCCouleurs.blanc,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: estChoisi ? option.couleur : CCCouleurs.feuilleGrise,
            width: estChoisi ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: estChoisi
                  ? option.couleur.withOpacity(0.25)
                  : Colors.black.withOpacity(0.04),
              blurRadius: estChoisi ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: estChoisi
                    ? Colors.white.withOpacity(0.2)
                    : option.couleurFond,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                option.icone,
                color: estChoisi ? CCCouleurs.blanc : option.couleur,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),

            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: estChoisi
                          ? CCCouleurs.blanc
                          : CCCouleurs.vertProfond,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option.description,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: estChoisi
                          ? CCCouleurs.blanc.withOpacity(0.8)
                          : CCCouleurs.grisTexte,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Check
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: estChoisi
                    ? CCCouleurs.blanc.withOpacity(0.3)
                    : Colors.transparent,
                border: Border.all(
                  color: estChoisi ? CCCouleurs.blanc : CCCouleurs.feuilleGrise,
                  width: 2,
                ),
              ),
              child: estChoisi
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: CCCouleurs.blanc,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Modèle option maturité ───────────────────────────────────────────────
class _OptionMaturite {
  final String valeur;
  final String label;
  final String description;
  final Color couleur;
  final Color couleurFond;
  final IconData icone;

  const _OptionMaturite({
    required this.valeur,
    required this.label,
    required this.description,
    required this.couleur,
    required this.couleurFond,
    required this.icone,
  });
}

// ─── Étape 2 — Santé ──────────────────────────────────────────────────────
class _EtapeSante extends StatefulWidget {
  final DonneesRecolte donnees;
  final String culture;
  final VoidCallback onSuivant;

  const _EtapeSante({
    required this.donnees,
    required this.culture,
    required this.onSuivant,
  });

  @override
  State<_EtapeSante> createState() => _EtapeSanteState();
}

class _EtapeSanteState extends State<_EtapeSante> {
  late final _TextesCulture _textes;
  @override
  void initState() {
    super.initState();
    _textes = _TextesCulture(widget.culture);
  }

  // Problèmes détectables
  List<_Probleme> get _problemes => [
    _Probleme(
      champ: 'aParasites',
      label: 'Parasites',
      description:
          'Présence d\'insectes, larves\nou vers sur les ${_textes.produits}',
      icone: Icons.pest_control_rounded,
      couleur: const Color(0xFFC0392B),
      couleurFond: const Color(0xFFFDECEC),
    ),
    _Probleme(
      champ: 'aMoisissures',
      label: 'Moisissures',
      description:
          'Traces blanches, grises\nou noires sur les ${_textes.produits}',
      icone: Icons.blur_circular_rounded,
      couleur: const Color(0xFF7D3C98),
      couleurFond: const Color(0xFFF5EEF8),
    ),
    _Probleme(
      champ: 'aTaches',
      label: 'Taches suspectes',
      description:
          'Décolorations anormales\nou lésions sur la ${_textes.produit}',
      icone: Icons.circle_notifications_rounded,
      couleur: const Color(0xFFD97706),
      couleurFond: const Color(0xFFFEF3C7),
    ),
  ];

  bool _getValeur(String champ) {
    switch (champ) {
      case 'aParasites':
        return widget.donnees.aParasites ?? false;
      case 'aMoisissures':
        return widget.donnees.aMoisissures ?? false;
      case 'aTaches':
        return widget.donnees.aTaches ?? false;
      default:
        return false;
    }
  }

  void _setValeur(String champ, bool valeur) {
    setState(() {
      switch (champ) {
        case 'aParasites':
          widget.donnees.aParasites = valeur;
          break;
        case 'aMoisissures':
          widget.donnees.aMoisissures = valeur;
          break;
        case 'aTaches':
          widget.donnees.aTaches = valeur;
          break;
      }
    });
  }

  // Au moins 1 choix fait (oui ou non) sur tous les problèmes
  bool get _estComplet =>
      widget.donnees.aParasites != null &&
      widget.donnees.aMoisissures != null &&
      widget.donnees.aTaches != null;

  // Résumé santé pour feedback visuel
  bool get _aucunProbleme =>
      widget.donnees.aParasites == false &&
      widget.donnees.aMoisissures == false &&
      widget.donnees.aTaches == false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Titre
                Text(
                  'État sanitaire',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: CCCouleurs.vertProfond,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Observez vos cabosses et indiquez\nce que vous voyez.',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: CCCouleurs.grisTexte,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Cartes problèmes ────────────────────────────────────────
                ..._problemes.map(
                  (p) => _CarteProbleme(
                    probleme: p,
                    valeur: _getValeur(p.champ),
                    onChange: (v) => _setValeur(p.champ, v),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Feedback santé globale ──────────────────────────────────
                if (_estComplet)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _aucunProbleme
                          ? CCCouleurs.succesClair
                          : CCCouleurs.attentionClair,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _aucunProbleme
                            ? CCCouleurs.vertForet.withOpacity(0.3)
                            : CCCouleurs.attention.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _aucunProbleme
                              ? Icons.check_circle_rounded
                              : Icons.info_rounded,
                          color: _aucunProbleme
                              ? CCCouleurs.vertForet
                              : CCCouleurs.attention,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _aucunProbleme
                                ? 'Bonne nouvelle ! Aucun problème détecté.'
                                : 'Des problèmes ont été signalés. '
                                      'La coopérative en sera informée.',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _aucunProbleme
                                  ? CCCouleurs.vertForet
                                  : CCCouleurs.attention,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Bouton suivant ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: _BoutonSuivant(
                    actif: _estComplet,
                    onTap: widget.onSuivant,
                    label: 'Suivant',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Carte problème avec toggle Oui/Non ───────────────────────────────────
class _CarteProbleme extends StatelessWidget {
  final _Probleme probleme;
  final bool valeur;
  final Function(bool) onChange;

  const _CarteProbleme({
    required this.probleme,
    required this.valeur,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Icône
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: valeur
                  ? probleme.couleurFond
                  : CCCouleurs.feuilleGrise.withOpacity(0.5),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              probleme.icone,
              color: valeur ? probleme.couleur : CCCouleurs.grisTexte,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Label + description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  probleme.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: CCCouleurs.vertProfond,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  probleme.description,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: CCCouleurs.grisTexte,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Toggle Oui / Non
          Column(
            children: [
              _BoutonToggle(
                label: 'Oui',
                actif: valeur == true,
                couleur: probleme.couleur,
                onTap: () => onChange(true),
              ),
              const SizedBox(height: 6),
              _BoutonToggle(
                label: 'Non',
                actif: valeur == false,
                couleur: CCCouleurs.vertForet,
                onTap: () => onChange(false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Bouton toggle Oui/Non ────────────────────────────────────────────────
class _BoutonToggle extends StatelessWidget {
  final String label;
  final bool actif;
  final Color couleur;
  final VoidCallback onTap;

  const _BoutonToggle({
    required this.label,
    required this.actif,
    required this.couleur,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 30,
        decoration: BoxDecoration(
          color: actif ? couleur : CCCouleurs.feuilleClaire,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: actif ? couleur : CCCouleurs.feuilleGrise),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: actif ? CCCouleurs.blanc : CCCouleurs.grisTexte,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Modèle problème ──────────────────────────────────────────────────────
class _Probleme {
  final String champ;
  final String label;
  final String description;
  final IconData icone;
  final Color couleur;
  final Color couleurFond;

  const _Probleme({
    required this.champ,
    required this.label,
    required this.description,
    required this.icone,
    required this.couleur,
    required this.couleurFond,
  });
}

// ─── Étape 3 — Humidité ───────────────────────────────────────────────────
class _EtapeHumidite extends StatefulWidget {
  final DonneesRecolte donnees;
  final String culture;
  final VoidCallback onSuivant;

  const _EtapeHumidite({
    required this.donnees,
    required this.culture,
    required this.onSuivant,
  });

  @override
  State<_EtapeHumidite> createState() => _EtapeHumiditeState();
}

class _EtapeHumiditeState extends State<_EtapeHumidite> {
  bool _avecAppareil = false; // toggle mesure manuelle vs appareil
  final _controleurTaux = TextEditingController();

  static const _options = [
    _OptionHumidite(
      valeur: 'sec',
      label: 'Sec',
      description: 'Produit bien séché,\nprêt pour stockage',
      icone: Icons.wb_sunny_outlined,
      couleur: Color(0xFFB8860B),
      couleurFond: Color(0xFFFFF8E1),
    ),
    _OptionHumidite(
      valeur: 'humide',
      label: 'Humide',
      description: 'Légèrement humide,\nséchage recommandé',
      icone: Icons.water_outlined,
      couleur: Color(0xFF1D4ED8),
      couleurFond: Color(0xFFEFF6FF),
    ),
    _OptionHumidite(
      valeur: 'mouille',
      label: 'Mouillé',
      description: 'Très humide, risque\nde moisissure élevé',
      icone: Icons.water_drop_rounded,
      couleur: Color(0xFF0E7490),
      couleurFond: Color(0xFFECFEFF),
    ),
  ];

  bool get _estComplet =>
      widget.donnees.humidite != null ||
      (widget.donnees.tauxHumidite != null && widget.donnees.tauxHumidite! > 0);

  @override
  void dispose() {
    _controleurTaux.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Titre ──────────────────────────────────────────────────
                Text(
                  'Taux d\'humidité',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: CCCouleurs.vertProfond,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Estimez l\'état d\'humidité\nde votre récolte.',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: CCCouleurs.grisTexte,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Toggle appareil de mesure ───────────────────────────────
                GestureDetector(
                  onTap: () => setState(() {
                    _avecAppareil = !_avecAppareil;
                    // Reset si on change de mode
                    widget.donnees.humidite = null;
                    widget.donnees.tauxHumidite = null;
                    _controleurTaux.clear();
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _avecAppareil
                          ? CCCouleurs.vertProfond
                          : CCCouleurs.blanc,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _avecAppareil
                            ? CCCouleurs.vertProfond
                            : CCCouleurs.feuilleGrise,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.device_thermostat_rounded,
                          color: _avecAppareil
                              ? CCCouleurs.limeVif
                              : CCCouleurs.grisTexte,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "J'ai un appareil de mesure",
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _avecAppareil
                                  ? CCCouleurs.blanc
                                  : CCCouleurs.nuit,
                            ),
                          ),
                        ),
                        Icon(
                          _avecAppareil
                              ? Icons.toggle_on_rounded
                              : Icons.toggle_off_rounded,
                          color: _avecAppareil
                              ? CCCouleurs.limeVif
                              : CCCouleurs.grisTexte,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Mode appareil : saisie du taux ──────────────────────────
                if (_avecAppareil) ...[
                  Text(
                    'Entrez le taux mesuré (%)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: CCCouleurs.vertProfond,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _controleurTaux,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: CCCouleurs.vertProfond,
                    ),
                    cursorColor: CCCouleurs.vertForet,
                    onChanged: (v) => setState(() {
                      widget.donnees.tauxHumidite = double.tryParse(v);
                    }),
                    decoration: InputDecoration(
                      hintText: 'Ex: 7.5',
                      hintStyle: GoogleFonts.dmSans(
                        fontSize: 22,
                        color: CCCouleurs.grisTexte,
                      ),
                      filled: true,
                      fillColor: CCCouleurs.blanc,
                      suffixText: '%',
                      suffixStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: CCCouleurs.vertForet,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: CCCouleurs.feuilleGrise,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: CCCouleurs.vertForet,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                  ),

                  // ── Mode visuel : Sec / Humide / Mouillé ────────────────────
                ] else ...[
                  Text(
                    'Estimation visuelle',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: CCCouleurs.vertProfond,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: _options
                        .map(
                          (o) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: o != _options.last ? 10 : 0,
                              ),
                              child: _CarteHumidite(
                                option: o,
                                estChoisi: widget.donnees.humidite == o.valeur,
                                onTap: () => setState(
                                  () => widget.donnees.humidite = o.valeur,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: _BoutonSuivant(
            actif: _estComplet,
            onTap: widget.onSuivant,
            label: 'Suivant',
          ),
        ),
      ],
    );
  }
}

// ─── Carte humidité ───────────────────────────────────────────────────────
class _CarteHumidite extends StatelessWidget {
  final _OptionHumidite option;
  final bool estChoisi;
  final VoidCallback onTap;

  const _CarteHumidite({
    required this.option,
    required this.estChoisi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: estChoisi ? option.couleur : CCCouleurs.blanc,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: estChoisi ? option.couleur : CCCouleurs.feuilleGrise,
            width: estChoisi ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: estChoisi
                  ? option.couleur.withOpacity(0.25)
                  : Colors.black.withOpacity(0.04),
              blurRadius: estChoisi ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              option.icone,
              color: estChoisi ? CCCouleurs.blanc : option.couleur,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              option.label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: estChoisi ? CCCouleurs.blanc : CCCouleurs.vertProfond,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              option.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: estChoisi
                    ? CCCouleurs.blanc.withOpacity(0.8)
                    : CCCouleurs.grisTexte,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Modèle option humidité ───────────────────────────────────────────────
class _OptionHumidite {
  final String valeur;
  final String label;
  final String description;
  final IconData icone;
  final Color couleur;
  final Color couleurFond;

  const _OptionHumidite({
    required this.valeur,
    required this.label,
    required this.description,
    required this.icone,
    required this.couleur,
    required this.couleurFond,
  });
}

// ─── Étape 4 — Photo + Confirmation ───────────────────────────────────────
class _EtapePhoto extends StatefulWidget {
  final DonneesRecolte donnees;
  final String culture;
  final Champ champ;

  const _EtapePhoto({
    required this.donnees,
    required this.culture,
    required this.champ,
  });

  @override
  State<_EtapePhoto> createState() => _EtapePhotoState();
}

class _EtapePhotoState extends State<_EtapePhoto> {
  final ImagePicker _picker = ImagePicker();
  bool _enEnvoi = false;
  late final List<_PlanPhoto> _plans;
  late final _TextesCulture _textes;

  @override
  void initState() {
    super.initState();
    _textes = _TextesCulture(widget.culture);
    _plans = _textes.estCacao
        ? [
            _PlanPhoto(
              label: 'Vue d\'ensemble',
              description: 'Photo du tas\nde cabosses',
              icone: Icons.photo_size_select_actual_rounded,
            ),
            _PlanPhoto(
              label: 'Gros plan',
              description: 'Détail d\'une\ncabosse',
              icone: Icons.center_focus_strong_rounded,
            ),
            _PlanPhoto(
              label: 'Coupe transversale',
              description: 'Intérieur\nde la cabosse',
              icone: Icons.cut_rounded,
            ),
          ]
        : [
            _PlanPhoto(
              label: 'Vue d\'ensemble',
              description: 'Photo du tas\nde cerises',
              icone: Icons.photo_size_select_actual_rounded,
            ),
            _PlanPhoto(
              label: 'Gros plan couleur',
              description: 'Détail de la\ncouleur des cerises',
              icone: Icons.center_focus_strong_rounded,
            ),
            _PlanPhoto(
              label: 'Grain dépulpé',
              description: 'Grain après\ndépulpage',
              icone: Icons.grain_rounded,
            ),
          ];

    // Initialiser la liste avec 3 entrées nulles
    if (widget.donnees.photos.isEmpty) {
      widget.donnees.photos = ['', '', ''];
    }
  }

  Future<void> _prendrePhoto(int index) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1024,
      );
      if (image != null) {
        setState(() => widget.donnees.photos[index] = image.path);
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      debugPrint('Erreur capture : $e');
    }
  }

  bool get _auMoinsUnePhoto => widget.donnees.photos.any((p) => p.isNotEmpty);

  bool get _toutesLesPhotos => widget.donnees.photos.every((p) => p.isNotEmpty);

  Future<void> _enregistrer() async {
    setState(() => _enEnvoi = true);

    // TODO : appeler LotService.creerRecolte(widget.donnees, widget.champ)
    // POST /api/lots/ avec toutes les données du diagnostic
    await Future.delayed(const Duration(seconds: 2)); // simulation

    if (!mounted) return;
    setState(() => _enEnvoi = false);

    // Succès → retour accueil avec confirmation
    _afficherSucces();
  }

  void _afficherSucces() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _ModalSucces(
        onTerminer: () {
          context.go(CCRoutes.accueil);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Titre ──────────────────────────────────────────────────
                Text(
                  'Photo de contrôle',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: CCCouleurs.vertProfond,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Prenez une photo de votre récolte\npour prouver la qualité au moment de la cueillette.',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: CCCouleurs.grisTexte,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Zone photo
                // Indicateur progression
                Row(
                  children: [
                    const Icon(
                      Icons.photo_library_rounded,
                      size: 16,
                      color: CCCouleurs.vertForet,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.donnees.photos.where((p) => p.isNotEmpty).length}/3 photos prises',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CCCouleurs.vertForet,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Zones photos scrollables horizontalement
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => _prendrePhoto(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: MediaQuery.of(context).size.width * 0.75,
                        margin: EdgeInsets.only(
                          left: i == 0 ? 0 : 12,
                          right: i == 2 ? 0 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: widget.donnees.photos[i].isNotEmpty
                              ? CCCouleurs.succesClair
                              : CCCouleurs.blanc,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: widget.donnees.photos[i].isNotEmpty
                                ? CCCouleurs.vertForet
                                : CCCouleurs.feuilleGrise,
                            width: widget.donnees.photos[i].isNotEmpty ? 2 : 1,
                          ),
                        ),
                        child: widget.donnees.photos[i].isNotEmpty
                            // Photo prise
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(
                                      File(widget.donnees.photos[i]),
                                      fit: BoxFit.cover,
                                    ),
                                    // Overlay avec bouton supprimer/refaire
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black38,
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 16,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.refresh_rounded,
                                            size: 16,
                                            color: CCCouleurs.vertProfond,
                                          ),
                                          onPressed: () => _prendrePhoto(i),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            // : Column(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            //       const Icon(
                            //         Icons.check_circle_rounded,
                            //         color: CCCouleurs.vertForet,
                            //         size: 48,
                            //       ),
                            //       const SizedBox(height: 10),
                            //       Text(
                            //         'Photo ${i + 1} prise ✓',
                            //         style: GoogleFonts.plusJakartaSans(
                            //           fontSize: 15,
                            //           fontWeight: FontWeight.w700,
                            //           color: CCCouleurs.vertForet,
                            //         ),
                            //       ),
                            //       const SizedBox(height: 4),
                            //       Text(
                            //         _plans[i].label,
                            //         style: GoogleFonts.dmSans(
                            //           fontSize: 12,
                            //           color: CCCouleurs.vertForet.withOpacity(
                            //             0.7,
                            //           ),
                            //         ),
                            //       ),
                            //       TextButton(
                            //         onPressed: () => _prendrePhoto(i),
                            //         child: Text(
                            //           'Reprendre',
                            //           style: GoogleFonts.dmSans(
                            //             fontSize: 12,
                            //             color: CCCouleurs.grisTexte,
                            //           ),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            //   )
                            // Pas encore de photo
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: const BoxDecoration(
                                      color: CCCouleurs.feuilleGrise,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _plans[i].icone,
                                      color: CCCouleurs.grisTexte,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Photo ${i + 1}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: CCCouleurs.vertProfond,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _plans[i].label,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: CCCouleurs.grisTexte,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _plans[i].description,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      color: CCCouleurs.grisTexte,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),

                // Avertissement si pas toutes les photos
                if (_auMoinsUnePhoto && !_toutesLesPhotos)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: CCCouleurs.attention,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Prenez les 3 photos pour une meilleure traçabilité.',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: CCCouleurs.attention,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // ── Horodatage automatique
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: CCCouleurs.vertProfond.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CCCouleurs.vertProfond.withOpacity(0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: CCCouleurs.vertForet,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Horodatage automatique',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: CCCouleurs.vertProfond,
                              ),
                            ),
                            Text(
                              // Heure actuelle formatée
                              '${_formaterDate(DateTime.now())}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: CCCouleurs.vertForet,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: CCCouleurs.succesClair,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Auto',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: CCCouleurs.vertForet,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _auMoinsUnePhoto
                    ? CCCouleurs.vertProfond
                    : CCCouleurs.feuilleGrise,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: _auMoinsUnePhoto ? 6 : 0,
                shadowColor: CCCouleurs.vertProfond.withOpacity(0.25),
              ),
              onPressed: _auMoinsUnePhoto && !_enEnvoi ? _enregistrer : null,
              child: _enEnvoi
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: CCCouleurs.limeVif,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Enregistrer la récolte',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _auMoinsUnePhoto
                            ? CCCouleurs.limeVif
                            : CCCouleurs.grisTexte,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  String _formaterDate(DateTime dt) {
    final jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final mois = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return '${jours[dt.weekday - 1]} ${dt.day} ${mois[dt.month - 1]} '
        '${dt.year} — ${dt.hour.toString().padLeft(2, '0')}h'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Carte photo individuelle ─────────────────────────────────────────────
class _CartePhoto extends StatelessWidget {
  final _PlanPhoto plan;
  final int index;
  final bool estPrise;
  final VoidCallback onTap;

  const _CartePhoto({
    required this.plan,
    required this.index,
    required this.estPrise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: estPrise ? CCCouleurs.succesClair : CCCouleurs.blanc,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: estPrise ? CCCouleurs.vertForet : CCCouleurs.feuilleGrise,
            width: estPrise ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: estPrise
                  ? CCCouleurs.vertForet.withOpacity(0.12)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Numéro photo
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: estPrise
                    ? CCCouleurs.vertForet
                    : CCCouleurs.feuilleGrise,
                borderRadius: BorderRadius.circular(12),
              ),
              child: estPrise
                  ? const Icon(
                      Icons.check_rounded,
                      color: CCCouleurs.blanc,
                      size: 24,
                    )
                  : Icon(plan.icone, color: CCCouleurs.grisTexte, size: 24),
            ),
            const SizedBox(width: 14),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Photo ${index + 1} — ${plan.label}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: estPrise
                          ? CCCouleurs.vertForet
                          : CCCouleurs.vertProfond,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    estPrise ? 'Photo prise ✓' : plan.description,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: estPrise
                          ? CCCouleurs.vertForet.withOpacity(0.7)
                          : CCCouleurs.grisTexte,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // Icône action
            Icon(
              estPrise ? Icons.refresh_rounded : Icons.camera_alt_rounded,
              color: estPrise ? CCCouleurs.vertForet : CCCouleurs.grisTexte,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Badge culture ────────────────────────────────────────────────────────
class _BadgeCulture extends StatelessWidget {
  final String culture;
  const _BadgeCulture({required this.culture});

  @override
  Widget build(BuildContext context) {
    final estCacao = culture.toLowerCase() == 'cacao';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: estCacao
            ? const Color(0xFF3D1C02).withOpacity(0.08)
            : const Color(0xFF4A2C0A).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: estCacao
              ? const Color(0xFF3D1C02).withOpacity(0.2)
              : const Color(0xFF6B3A1F).withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(estCacao ? '🍫' : '☕', style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            culture,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: estCacao
                  ? const Color(0xFF3D1C02)
                  : const Color(0xFF4A2C0A),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Modal de succès ──────────────────────────────────────────────────────
class _ModalSucces extends StatelessWidget {
  final VoidCallback onTerminer;
  const _ModalSucces({required this.onTerminer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: CCCouleurs.blanc,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône succès
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: CCCouleurs.succesClair,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: CCCouleurs.vertForet,
              size: 44,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Récolte enregistrée !',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: CCCouleurs.vertProfond,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Votre récolte a été enregistrée avec succès ',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: CCCouleurs.grisTexte,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // Bouton retour accueil
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CCCouleurs.vertProfond,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: onTerminer,
              child: Text(
                'Retour à l\'accueil',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: CCCouleurs.limeVif,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bouton Suivant réutilisable ──────────────────────────────────────────
class _BoutonSuivant extends StatelessWidget {
  final bool actif;
  final VoidCallback onTap;
  final String label;

  const _BoutonSuivant({
    required this.actif,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: actif
              ? CCCouleurs.vertProfond
              : CCCouleurs.feuilleGrise,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: actif ? 6 : 0,
          shadowColor: CCCouleurs.vertProfond.withOpacity(0.25),
        ),
        onPressed: actif ? onTap : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: actif ? CCCouleurs.limeVif : CCCouleurs.grisTexte,
              ),
            ),
            if (actif) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: CCCouleurs.limeVif,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Modèle étape ─────────────────────────────────────────────────────────
class _Etape {
  final IconData icone;
  final String label;
  final String cleAudio;
  final String description;
  const _Etape({
    required this.icone,
    required this.label,
    required this.cleAudio,
    required this.description,
  });
}

class _PlanPhoto {
  final String label;
  final String description;
  final IconData icone;
  const _PlanPhoto({
    required this.label,
    required this.description,
    required this.icone,
  });
}
