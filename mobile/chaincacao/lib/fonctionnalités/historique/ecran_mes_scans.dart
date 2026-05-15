// lib/fonctionnalités/historique/ecran_mes_scans.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../configuration/theme.dart';
import '../../configuration/routage.dart';
import '../../composants/bouton_audio_aide.dart';
import '../../services/service_audio.dart';

// ─── Modèle récolte ───────────────────────────────────────────────────────
class RecolteHistorique {
  final String id;
  final String culture; // 'Cacao' | 'Café'
  final String statut; // 'attente' | 'transit' | 'certifie'
  final DateTime dateRecolte;
  final double? poidsCooperative; // TODO : saisi par la coopérative via API
  final String champNom;
  final String? hashBlockchain; // TODO : retourné par Jacques (BE15)

  const RecolteHistorique({
    required this.id,
    required this.culture,
    required this.statut,
    required this.dateRecolte,
    this.poidsCooperative,
    required this.champNom,
    this.hashBlockchain,
  });

  // Données encodées dans le QR code
  // Format : ID + hash blockchain si disponible
  String get donneesQr => hashBlockchain != null ? '$id|$hashBlockchain' : id;
}

// ─── Écran principal ──────────────────────────────────────────────────────
class EcranMesScans extends StatefulWidget {
  const EcranMesScans({super.key});

  @override
  State<EcranMesScans> createState() => _EcranMesScansState();
}

class _EcranMesScansState extends State<EcranMesScans> {
  String _filtreStatut = 'tous';

  // TODO : remplacer par LotService.mesLots depuis l'API Jacques
  // GET /api/lots/ — liste des lots de l'agriculteur connecté
  final List<RecolteHistorique> _recoltes = [
    RecolteHistorique(
      id: 'CC-2024-001',
      culture: 'Cacao',
      statut: 'certifie',
      dateRecolte: DateTime(2024, 5, 12, 8, 30),
      poidsCooperative: 120.5,
      champNom: 'Champ de Kpalimé Nord',
      hashBlockchain: '0x3a9f1b2c',
    ),
    RecolteHistorique(
      id: 'CC-2024-002',
      culture: 'Cacao',
      statut: 'transit',
      dateRecolte: DateTime(2024, 5, 11, 14, 0),
      champNom: 'Champ Bas-fond Est',
    ),
    RecolteHistorique(
      id: 'CC-2024-003',
      culture: 'Café',
      statut: 'attente',
      dateRecolte: DateTime(2024, 5, 9, 10, 15),
      champNom: 'Parcelle Familiale',
    ),
  ];

  List<RecolteHistorique> get _recoltesFiltrees => _filtreStatut == 'tous'
      ? _recoltes
      : _recoltes.where((r) => r.statut == _filtreStatut).toList();

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
              'Mes récoltes',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: CCCouleurs.vertProfond,
              ),
            ),
            actions: [
              // Compteur total
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: CCCouleurs.vertProfond,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_recoltes.length} lots',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CCCouleurs.limeVif,
                  ),
                ),
              ),
            ],
          ),

          body: Column(
            children: [
              // ── Filtres par statut ────────────────────────────────────
              _FiltresStatut(
                filtreActif: _filtreStatut,
                onFiltre: (f) => setState(() => _filtreStatut = f),
              ),

              // ── Liste ─────────────────────────────────────────────────
              Expanded(
                child: _recoltesFiltrees.isEmpty
                    ? _EtatVide(filtre: _filtreStatut)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        itemCount: _recoltesFiltrees.length,
                        itemBuilder: (_, i) =>
                            _CarteRecolte(recolte: _recoltesFiltrees[i]),
                      ),
              ),
            ],
          ),
        ),
        // ── Audio guide ─────────────────────────────────────────
        BoutonAudioGuide(cleAudio: ServiceAudio.mesScans),
      ],
    );
  }
}

// ─── Filtres statut ───────────────────────────────────────────────────────
class _FiltresStatut extends StatelessWidget {
  final String filtreActif;
  final Function(String) onFiltre;

  const _FiltresStatut({required this.filtreActif, required this.onFiltre});

  static const _filtres = [
    ('tous', 'Tous', null),
    ('attente', '⏳ Attente', CCCouleurs.attention),
    ('transit', '→ Transit', CCCouleurs.transit),
    ('certifie', '✓ Certifié', CCCouleurs.vertForet),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: _filtres.map((f) {
          final (code, label, couleur) = f;
          final estActif = filtreActif == code;
          return GestureDetector(
            onTap: () => onFiltre(code),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: estActif
                    ? (couleur ?? CCCouleurs.vertProfond)
                    : CCCouleurs.blanc,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: estActif
                      ? (couleur ?? CCCouleurs.vertProfond)
                      : CCCouleurs.feuilleGrise,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: estActif ? CCCouleurs.blanc : CCCouleurs.grisTexte,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Carte récolte ────────────────────────────────────────────────────────
class _CarteRecolte extends StatelessWidget {
  final RecolteHistorique recolte;
  const _CarteRecolte({required this.recolte});

  @override
  Widget build(BuildContext context) {
    final config = _configStatut(recolte.statut);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: CCCouleurs.blanc,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CCCouleurs.feuilleGrise),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header carte ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // QR miniature cliquable
                GestureDetector(
                  onTap: () => _afficherQrPleinEcran(context),
                  child: Container(
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: CCCouleurs.blanc,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: CCCouleurs.feuilleGrise),
                    ),
                    child: QrImageView(
                      data: recolte.donneesQr,
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: CCCouleurs.vertProfond,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: CCCouleurs.vertProfond,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Infos principales
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ID + Culture
                      Row(
                        children: [
                          Text(
                            recolte.id,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: CCCouleurs.vertProfond,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            recolte.culture == 'Cacao' ? '🍫' : '☕',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Badge statut
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
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
                      const SizedBox(height: 6),

                      // Champ
                      Row(
                        children: [
                          const Icon(
                            Icons.landscape_rounded,
                            size: 13,
                            color: CCCouleurs.grisTexte,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              recolte.champNom,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: CCCouleurs.grisTexte,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Bouton QR plein écran
                GestureDetector(
                  onTap: () => _afficherQrPleinEcran(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: CCCouleurs.feuilleClaire,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.qr_code_2_rounded,
                      color: CCCouleurs.vertProfond,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Séparateur ──────────────────────────────────────────────
          const Divider(height: 1, color: CCCouleurs.feuilleGrise),

          // ── Footer carte : date + poids ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Date
                _InfoItem(
                  icone: Icons.calendar_today_rounded,
                  label: 'Date',
                  valeur: _formaterDate(recolte.dateRecolte),
                ),

                // Séparateur vertical
                Container(
                  height: 32,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: CCCouleurs.feuilleGrise,
                ),

                // Poids coopérative
                _InfoItem(
                  icone: Icons.scale_rounded,
                  label: 'Poids vérifié',
                  valeur: recolte.poidsCooperative != null
                      ? '${recolte.poidsCooperative} kg'
                      : 'En attente',
                  couleurValeur: recolte.poidsCooperative != null
                      ? CCCouleurs.vertForet
                      : CCCouleurs.attention,
                ),

                // Hash blockchain si disponible
                if (recolte.hashBlockchain != null) ...[
                  Container(
                    height: 32,
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    color: CCCouleurs.feuilleGrise,
                  ),
                  _InfoItem(
                    icone: Icons.link_rounded,
                    label: 'Blockchain',
                    valeur: '${recolte.hashBlockchain!.substring(0, 8)}…',
                    couleurValeur: CCCouleurs.transit,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _afficherQrPleinEcran(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ModalQrCode(recolte: recolte),
    );
  }

  String _formaterDate(DateTime dt) {
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
    return '${dt.day} ${mois[dt.month - 1]} ${dt.year}\n'
        '${dt.hour.toString().padLeft(2, '0')}h'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  _ConfigStatut _configStatut(String statut) {
    switch (statut) {
      case 'certifie':
        return const _ConfigStatut(
          label: '✓ Certifié',
          couleur: CCCouleurs.vertForet,
          couleurFond: CCCouleurs.succesClair,
        );
      case 'transit':
        return const _ConfigStatut(
          label: '→ En transit',
          couleur: CCCouleurs.transit,
          couleurFond: CCCouleurs.transitClair,
        );
      default:
        return const _ConfigStatut(
          label: '⏳ En attente',
          couleur: CCCouleurs.attention,
          couleurFond: CCCouleurs.attentionClair,
        );
    }
  }
}

// ─── Modal QR plein écran ─────────────────────────────────────────────────
class _ModalQrCode extends StatelessWidget {
  final RecolteHistorique recolte;
  const _ModalQrCode({required this.recolte});

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
          // Poignée
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: CCCouleurs.feuilleGrise,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // ID + culture
          Text(
            recolte.id,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: CCCouleurs.vertProfond,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${recolte.culture} — ${recolte.champNom}',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: CCCouleurs.grisTexte,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // QR code grand format
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CCCouleurs.blanc,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: CCCouleurs.feuilleGrise),
              boxShadow: [
                BoxShadow(
                  color: CCCouleurs.vertProfond.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data: recolte.donneesQr,
              version: QrVersions.auto,
              size: 240,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: CCCouleurs.vertProfond,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: CCCouleurs.vertProfond,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Hash blockchain si disponible
          if (recolte.hashBlockchain != null)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: recolte.hashBlockchain!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Hash copié !',
                      style: GoogleFonts.dmSans(color: CCCouleurs.vertProfond),
                    ),
                    backgroundColor: CCCouleurs.limeVif,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: CCCouleurs.feuilleClaire,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: CCCouleurs.feuilleGrise),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.link_rounded,
                      size: 14,
                      color: CCCouleurs.transit,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      recolte.hashBlockchain!,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: CCCouleurs.transit,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: CCCouleurs.grisTexte,
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Bouton fermer
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CCCouleurs.vertProfond,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Fermer',
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

// ─── Info item (date, poids, hash) ────────────────────────────────────────
class _InfoItem extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valeur;
  final Color couleurValeur;

  const _InfoItem({
    required this.icone,
    required this.label,
    required this.valeur,
    this.couleurValeur = CCCouleurs.nuit,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 12, color: CCCouleurs.grisTexte),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: CCCouleurs.grisTexte,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            valeur,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: couleurValeur,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── État vide ────────────────────────────────────────────────────────────
class _EtatVide extends StatelessWidget {
  final String filtre;
  const _EtatVide({required this.filtre});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grass_rounded, size: 72, color: CCCouleurs.feuilleGrise),
          const SizedBox(height: 16),
          Text(
            filtre == 'tous'
                ? 'Aucune récolte enregistrée'
                : 'Aucune récolte "${filtre}"',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CCCouleurs.grisTexte,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur + pour ajouter\nvotre première récolte',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: CCCouleurs.grisTexte,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Modèles internes ─────────────────────────────────────────────────────
class _ConfigStatut {
  final String label;
  final Color couleur;
  final Color couleurFond;
  const _ConfigStatut({
    required this.label,
    required this.couleur,
    required this.couleurFond,
  });
}
