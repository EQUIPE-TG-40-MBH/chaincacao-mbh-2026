// lib/fonctionnalités/connexion/ecran_connexion.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../configuration/theme.dart';
import '../../configuration/routage.dart';
import '../../configuration/constantes.dart';
import '../../services/service_audio.dart';

class EcranConnexion extends StatefulWidget {
  const EcranConnexion({super.key});

  @override
  State<EcranConnexion> createState() => _EcranConnexionState();
}

class _EcranConnexionState extends State<EcranConnexion>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ServiceAudio _audio = ServiceAudio();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _audio.jouer('connexion', langue: 'fr');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audio.dispose();
    super.dispose();
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
          onTap: () => context.go(CCRoutes.selectionLangue),
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
          'Connexion',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: CCCouleurs.vertProfond,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            height: 48,
            decoration: BoxDecoration(
              color: CCCouleurs.feuilleGrise,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: CCCouleurs.vertProfond,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              labelColor: CCCouleurs.limeVif,
              unselectedLabelColor: CCCouleurs.grisTexte,
              tabs: const [
                Tab(text: 'MON IDENTIFIANT'),
                Tab(text: 'SCANNER LE QR'),
              ],
            ),
          ),
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [_OngletSaisieId(), _OngletScannerQr()],
      ),
    );
  }
}

// ─── Onglet 1 — Saisie ID
class _OngletSaisieId extends StatefulWidget {
  @override
  State<_OngletSaisieId> createState() => _OngletSaisieIdState();
}

class _OngletSaisieIdState extends State<_OngletSaisieId> {
  final _controleur = TextEditingController();
  bool _formatValide = false;
  final RegExp _idRegex = RegExp(r'^[A-Z0-9]+-[A-Z0-9]+-[0-9]{3}-[0-9]{3}$');

  @override
  void initState() {
    super.initState();
    _controleur.addListener(_validerSaisie);
  }

  void _validerSaisie() {
    final texte = _controleur.text.trim().toUpperCase();
    
    if (_controleur.text != texte) {
      _controleur.value = _controleur.value.copyWith(
        text: texte,
        selection: TextSelection.collapsed(offset: texte.length),
      );
    }

    setState(() {
      _formatValide = _idRegex.hasMatch(texte);
    });
  }

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: CCCouleurs.feuilleClaire,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône centrale
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: CCCouleurs.succesClair,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CCCouleurs.vertForet.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.badge_rounded,
                  color: CCCouleurs.vertForet,
                  size: 44,
                ),
              ),
            ),
            const SizedBox(height: 28),

            Center(
              child: Text(
                'Entrez votre identifiant',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: CCCouleurs.vertProfond,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Saisissez votre numéro agriculteur reçu\nlors de votre inscription à la coopérative.',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: CCCouleurs.grisTexte,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Champ de saisie
            TextField(
              controller: _controleur,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CCCouleurs.vertProfond,
                letterSpacing: 2,
              ),
              cursorColor: CCCouleurs.vertForet,
              decoration: InputDecoration(
                hintText: 'Ex : COOP-TG-001-001',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: CCCouleurs.grisTexte,
                  letterSpacing: 1,
                ),
                filled: true,
                fillColor: CCCouleurs.blanc,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: CCCouleurs.feuilleGrise),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: CCCouleurs.feuilleGrise),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: CCCouleurs.vertForet,
                    width: 2,
                  ),
                ),
                prefixIcon: const Icon(
                  Icons.tag_rounded,
                  color: CCCouleurs.grisTexte,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Bouton valider
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _formatValide
                      ? CCCouleurs.vertProfond
                      : CCCouleurs.feuilleGrise,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: _formatValide ? 6 : 0,
                  shadowColor: CCCouleurs.vertProfond.withOpacity(0.25),
                ),
                onPressed: _formatValide
                    ? () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(
                          CCStockage.token,
                          'token_test_123',
                        );
                        await prefs.setString(
                          'id_agriculteur',
                          _controleur.text.trim().toLowerCase(),
                        );
                        if (mounted) {
                          context.go(CCRoutes.accueil);
                        }
                      }
                    : null,
                child: Text(
                  'Valider',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _formatValide ? CCCouleurs.limeVif : CCCouleurs.grisTexte,
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

// ─── Onglet 2 — Scanner QR fonctionnel
class _OngletScannerQr extends StatefulWidget {
  @override
  State<_OngletScannerQr> createState() => _OngletScannerQrState();
}

class _OngletScannerQrState extends State<_OngletScannerQr> {
  final MobileScannerController _scannerCtrl = MobileScannerController();
  bool _traite = false; // Évite les doubles détections

  @override
  void dispose() {
    _scannerCtrl.dispose();
    super.dispose();
  }

  void _surDetection(BarcodeCapture capture) {
    if (_traite) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _traite = true);
    _scannerCtrl.stop();

    // Feedback visuel puis navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'QR détecté : $code',
          style: GoogleFonts.dmSans(color: CCCouleurs.vertProfond),
        ),
        backgroundColor: CCCouleurs.limeVif,
        duration: const Duration(seconds: 1),
      ),
    );

    Future.delayed(const Duration(milliseconds: 800), () async{
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(CCStockage.token, 'token_test_123');
      await prefs.setString('id_agriculteur', code.trim().toUpperCase());
      
      if (!mounted) return;
      context.go(CCRoutes.accueil, extra: code);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CCCouleurs.feuilleClaire,
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Texte guide
          Text(
            'Placez le QR Code dans le cadre',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: CCCouleurs.grisTexte,
            ),
          ),
          const SizedBox(height: 24),

          // Zone scanner réelle
          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    children: [
                      // Caméra réelle
                      MobileScanner(
                        controller: _scannerCtrl,
                        onDetect: _surDetection,
                      ),

                      // Overlay coins lime
                      CustomPaint(
                        painter: _PeintreCadreQr(),
                        size: const Size(280, 280),
                      ),

                      // Ligne de scan animée
                      if (!_traite) const _LigneScanAnimee(),

                      // Overlay succès
                      if (_traite)
                        Container(
                          color: CCCouleurs.vertForet.withOpacity(0.7),
                          child: const Center(
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: CCCouleurs.limeVif,
                              size: 72,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Bouton torche
          TextButton.icon(
            onPressed: () => _scannerCtrl.toggleTorch(),
            icon: const Icon(
              Icons.flashlight_on_rounded,
              color: CCCouleurs.vertForet,
            ),
            label: Text(
              'Activer la torche',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: CCCouleurs.vertForet,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bouton recommencer si bloqué
          if (_traite)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 58,
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
                  onPressed: () {
                    setState(() => _traite = false);
                    _scannerCtrl.start();
                  },
                  child: Text(
                    'Scanner à nouveau',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CCCouleurs.vertForet,
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Ligne de scan animée
class _LigneScanAnimee extends StatefulWidget {
  const _LigneScanAnimee();

  @override
  State<_LigneScanAnimee> createState() => _LigneScanAnimeeState();
}

class _LigneScanAnimeeState extends State<_LigneScanAnimee>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Positioned(
        top: _anim.value * 260,
        left: 0,
        right: 0,
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CCCouleurs.limeVif.withOpacity(0),
                CCCouleurs.limeVif,
                CCCouleurs.limeVif.withOpacity(0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Painter — coins du cadre QR ─────────────────────────────────────────
class _PeintreCadreQr extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pinceau = Paint()
      ..color = CCCouleurs.limeVif
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const longueur = 40.0;

    // Coin haut-gauche
    canvas.drawPath(
      Path()
        ..moveTo(0, longueur)
        ..lineTo(0, 0)
        ..lineTo(longueur, 0),
      pinceau,
    );
    // Coin haut-droite
    canvas.drawPath(
      Path()
        ..moveTo(size.width - longueur, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, longueur),
      pinceau,
    );
    // Coin bas-gauche
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - longueur)
        ..lineTo(0, size.height)
        ..lineTo(longueur, size.height),
      pinceau,
    );
    // Coin bas-droite
    canvas.drawPath(
      Path()
        ..moveTo(size.width - longueur, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height - longueur),
      pinceau,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
