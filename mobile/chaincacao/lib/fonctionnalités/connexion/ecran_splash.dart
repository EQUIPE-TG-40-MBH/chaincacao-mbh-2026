import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../configuration/theme.dart';
import '../../configuration/constantes.dart';
import '../../configuration/routage.dart';


class EcranSplash extends StatefulWidget {
  const EcranSplash({super.key});

  @override
  State<EcranSplash> createState() => _EcranSplashState();
}

class _EcranSplashState extends State<EcranSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controleur;
  late Animation<double> _opacite;

  Future<void> _redirigerApres() async {
    // Petite pause après le fondu pour un rendu naturel
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final langue = prefs.getString(CCStockage.langue);
    final token = prefs.getString(CCStockage.token);

    if (!mounted) return;

    // Pas encore de langue choisie → sélection de langue
    if (langue == null) {
      context.go(CCRoutes.selectionLangue);
      return;
    }

    // Langue choisie mais pas connecté → connexion
    if (token == null) {
      context.go(CCRoutes.connexion);
      return;
    }

    // Déjà connecté → accueil directement
    context.go(CCRoutes.accueil);
  }

  @override
  void initState() {
    super.initState();

    // Animation fondu : 0 → 1 en 1.2 secondes
    _controleur = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _opacite = CurvedAnimation(parent: _controleur, curve: Curves.easeIn);

    // Lancer l'animation puis rediriger
    _controleur.forward().then((_) => _redirigerApres());
  }

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CCCouleurs.transitClair,
      body: Center(
        child: FadeTransition(
          opacity: _opacite,
          child: Image.asset(
            'assets/images/chaincacao_logo_light.png',
            width: 260,
          ),
        ),
      ),
    );
  }
}
