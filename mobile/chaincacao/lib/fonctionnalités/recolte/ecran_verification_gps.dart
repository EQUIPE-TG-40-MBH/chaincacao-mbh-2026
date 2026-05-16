// lib/fonctionnalités/recolte/ecran_verification_gps.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../configuration/theme.dart';
import '../../configuration/routage.dart';
import '../../modeles/champ.dart';
import '../../services/service_gps.dart';

class EcranVerificationGps extends StatefulWidget {
  final Champ champ;
  const EcranVerificationGps({super.key, required this.champ});

  @override
  State<EcranVerificationGps> createState() => _EcranVerificationGpsState();
}

class _EcranVerificationGpsState extends State<EcranVerificationGps>
    with SingleTickerProviderStateMixin {

  // États possibles : verification | succes | echec | erreur
  String        _etat     = 'verification';
  ResultatGps?  _resultat;
  String?       _messageErreur;

  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Animation pulsation pendant la vérification
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Lancer la vérification dès l'ouverture
    _verifier();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifier() async {
    setState(() => _etat = 'verification');
    try {
      final resultat = await ServiceGps.instance.verifierChamp(widget.champ);
      if (!mounted) return;
      setState(() {
        _resultat = resultat;
        _etat = resultat.estDansLeChamp ? 'succes' : 'echec';
      });

      // Succès → navigation automatique après 1.5s
      if (resultat.estDansLeChamp) {
        await Future.delayed(const Duration(milliseconds: 2000));
        if (!mounted) return;
        context.push(
          CCRoutes.diagnosticRecolte,
          extra: {
            'champ': widget.champ,
            'gps_forced': false,
            'gps_resultat': resultat,
          },
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _etat = 'erreur';
        _messageErreur = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CCCouleurs.feuilleClaire,
      appBar: AppBar(
        backgroundColor: CCCouleurs.feuilleClaire,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
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
          'Vérification GPS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: CCCouleurs.vertProfond,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ── Infos du champ 
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CCCouleurs.blanc,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CCCouleurs.feuilleGrise),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: CCCouleurs.succesClair,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.landscape_rounded,
                      color: CCCouleurs.vertForet,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.champ.nom,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: CCCouleurs.vertProfond,
                          ),
                        ),
                        Text(
                          'Zone autorisée : ${widget.champ.rayonFormate}',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: CCCouleurs.grisTexte,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Contenu central selon l'état 
            _buildContenuCentral(),

            const Spacer(),

            // ── Bouton selon l'état 
            _buildBouton(),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildContenuCentral() {
    switch (_etat) {

      // ── En cours de vérification 
      case 'verification':
        return Column(
          children: [
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CCCouleurs.vertForet.withOpacity(0.1),
                  border: Border.all(
                    color: CCCouleurs.vertForet.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.gps_fixed_rounded,
                  color: CCCouleurs.vertForet,
                  size: 56,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Localisation en cours…',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: CCCouleurs.vertProfond,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nous vérifions que vous êtes\nbien dans le champ sélectionné.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: CCCouleurs.grisTexte,
                height: 1.5,
              ),
            ),
          ],
        );

      // ── Succès 
      case 'succes':
        return Column(
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CCCouleurs.succesClair,
                border: Border.all(
                  color: CCCouleurs.vertForet.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: CCCouleurs.vertForet,
                size: 64,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Vous êtes dans le champ !',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: CCCouleurs.vertForet,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Distance au centre : ${ServiceGps.instance.formaterDistance(_resultat!.distanceMetres)}',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: CCCouleurs.grisTexte,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Redirection en cours…',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: CCCouleurs.vertForet.withOpacity(0.7),
              ),
            ),
          ],
        );

      // ── Échec — hors du champ 
      case 'echec':
        return Column(
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CCCouleurs.erreurClair,
                border: Border.all(
                  color: CCCouleurs.erreur.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.location_off_rounded,
                color: CCCouleurs.erreur,
                size: 64,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Hors du champ',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: CCCouleurs.erreur,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous êtes à ${ServiceGps.instance.formaterDistance(_resultat!.distanceMetres)} du champ.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: CCCouleurs.grisTexte,
              ),
            ),
            const SizedBox(height: 16),
            // Explication claire pour l'agriculteur
            Container(
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
                  const Icon(
                    Icons.info_rounded,
                    color: CCCouleurs.erreur,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Rendez-vous dans votre champ '
                      '"${widget.champ.nom}" pour enregistrer '
                      'une récolte.',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: CCCouleurs.erreur,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      // ── Erreur GPS 
      default:
        return Column(
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CCCouleurs.attentionClair,
                border: Border.all(
                  color: CCCouleurs.attention.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.gps_off_rounded,
                color: CCCouleurs.attention,
                size: 64,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'GPS indisponible',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: CCCouleurs.attention,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _messageErreur ?? 'Une erreur est survenue.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: CCCouleurs.grisTexte,
                height: 1.5,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildBouton() {
    switch (_etat) {
      case 'verification':
      case 'succes':
        return const SizedBox.shrink(); // Pas de bouton pendant vérif/succès

      case 'echec':
        return Column(
          children: [
            // Option de forçage : Continuer malgré l'écart GPS
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CCCouleurs.attention,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () => context.push(
                  CCRoutes.diagnosticRecolte, 
                  extra: {
                    'champ': widget.champ,
                    'gps_forced': true,
                    'gps_resultat': _resultat,
                  }),
                icon: const Icon(Icons.arrow_forward_rounded, color: CCCouleurs.blanc),
                label: Text(
                  'Capturer quand même',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: CCCouleurs.blanc,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Réessayer
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CCCouleurs.vertProfond,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: _verifier,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: CCCouleurs.limeVif,
                ),
                label: Text(
                  'Réessayer',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: CCCouleurs.limeVif,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Changer de champ
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: CCCouleurs.vertForet,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => context.pop(),
                child: Text(
                  'Changer de champ',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CCCouleurs.vertForet,
                  ),
                ),
              ),
            ),
          ],
        );

      // Erreur GPS → réessayer
      default:
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: CCCouleurs.attention,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _verifier,
            icon: const Icon(Icons.refresh_rounded, color: CCCouleurs.blanc),
            label: Text(
              'Réessayer',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: CCCouleurs.blanc,
              ),
            ),
          ),
        );
    }
  }
}
