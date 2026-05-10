// lib/configuration/theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ───COULEURS 
class CCCouleurs {
  CCCouleurs._();

  // Principales
  static const limeVif       = Color(0xFFD1F811); // Accent, CTA, badges
  static const limePale      = Color(0xFFEBF97F); // Hover, états actifs
  static const vertForet     = Color(0xFF076653); // Boutons, liens, primaire
  static const vertMoyen     = Color(0xFF3D9E7A); // Variante intermédiaire
  static const vertProfond   = Color(0xFF02403D); // App bar, splash, headers
  static const vertSombre    = Color(0xFF012B29); // Fonds très sombres

  // Neutres
  static const nuit          = Color(0xFF0A1628); // Textes, dark surface
  static const feuilleClaire = Color(0xFFF5F9EE); // Fond clair, cartes
  static const feuilleGrise  = Color(0xFFDDEDD4); // Bordures, séparateurs
  static const grisTexte     = Color(0xFF5A7060); // Labels, placeholders
  static const blanc         = Color(0xFFFFFFFF);

  // Statuts
  static const succes        = Color(0xFF076653);
  static const succesClair   = Color(0xFFE8F5EF);
  static const attention     = Color(0xFFD97706);
  static const attentionClair= Color(0xFFFEF3C7);
  static const transit       = Color(0xFF1D4ED8);
  static const transitClair  = Color(0xFFEFF6FF);
  static const erreur        = Color(0xFFDC2626);
  static const erreurClair   = Color(0xFFFEE2E2);


}


// ───TYPOGRAPHIE 
class CCTypographie {
  CCTypographie._();

  // ── Mode clair 
  static TextTheme get clair => TextTheme(
    // Titres — Playfair Display
    displayLarge:  GoogleFonts.playfairDisplay(
      fontSize: 32, fontWeight: FontWeight.w700, color: CCCouleurs.vertProfond),
    displayMedium: GoogleFonts.playfairDisplay(
      fontSize: 26, fontWeight: FontWeight.w700, color: CCCouleurs.vertProfond),
    headlineLarge: GoogleFonts.playfairDisplay(
      fontSize: 22, fontWeight: FontWeight.w600, color: CCCouleurs.vertProfond),
    headlineMedium:GoogleFonts.playfairDisplay(
      fontSize: 18, fontWeight: FontWeight.w600, color: CCCouleurs.vertProfond),

    // Corps — Epilogue
    titleLarge:  GoogleFonts.epilogue(
      fontSize: 18, fontWeight: FontWeight.w600, color: CCCouleurs.nuit),
    titleMedium: GoogleFonts.epilogue(
      fontSize: 16, fontWeight: FontWeight.w600, color: CCCouleurs.nuit),
    bodyLarge:   GoogleFonts.epilogue(
      fontSize: 16, fontWeight: FontWeight.w400, color: CCCouleurs.nuit),
    bodyMedium:  GoogleFonts.epilogue(
      fontSize: 14, fontWeight: FontWeight.w400, color: CCCouleurs.nuit),
    bodySmall:   GoogleFonts.epilogue(
      fontSize: 12, fontWeight: FontWeight.w400, color: CCCouleurs.grisTexte),

    // Labels
    labelLarge:  GoogleFonts.epilogue(
      fontSize: 16, fontWeight: FontWeight.w600, color: CCCouleurs.blanc),
    labelMedium: GoogleFonts.epilogue(
      fontSize: 12, fontWeight: FontWeight.w500, color: CCCouleurs.grisTexte),
  );

  // ── Mode sombre 
  static TextTheme get sombre => TextTheme(
    displayLarge:  GoogleFonts.playfairDisplay(
      fontSize: 32, fontWeight: FontWeight.w700, color: CCCouleurs.limeVif),
    displayMedium: GoogleFonts.playfairDisplay(
      fontSize: 26, fontWeight: FontWeight.w700, color: CCCouleurs.limeVif),
    headlineLarge: GoogleFonts.playfairDisplay(
      fontSize: 22, fontWeight: FontWeight.w600, color: CCCouleurs.feuilleClaire),
    headlineMedium:GoogleFonts.playfairDisplay(
      fontSize: 18, fontWeight: FontWeight.w600, color: CCCouleurs.feuilleClaire),

    titleLarge:  GoogleFonts.epilogue(
      fontSize: 18, fontWeight: FontWeight.w600, color: CCCouleurs.feuilleClaire),
    titleMedium: GoogleFonts.epilogue(
      fontSize: 16, fontWeight: FontWeight.w600, color: CCCouleurs.feuilleClaire),
    bodyLarge:   GoogleFonts.epilogue(
      fontSize: 16, fontWeight: FontWeight.w400, color: CCCouleurs.feuilleClaire),
    bodyMedium:  GoogleFonts.epilogue(
      fontSize: 14, fontWeight: FontWeight.w400, color: CCCouleurs.feuilleClaire),
    bodySmall:   GoogleFonts.epilogue(
      fontSize: 12, fontWeight: FontWeight.w400, color: CCCouleurs.grisTexte),

    labelLarge:  GoogleFonts.epilogue(
      fontSize: 16, fontWeight: FontWeight.w600, color: CCCouleurs.vertProfond),
    labelMedium: GoogleFonts.epilogue(
      fontSize: 12, fontWeight: FontWeight.w500, color: CCCouleurs.grisTexte),
  );
}


// ───  THÈME 
class CCTheme {
  CCTheme._();

  // ── Light 
  static ThemeData get clair => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: CCCouleurs.feuilleClaire,
    colorScheme: const ColorScheme.light(
      primary:          CCCouleurs.vertForet,
      primaryContainer: CCCouleurs.vertProfond,
      secondary:        CCCouleurs.limeVif,
      surface:          CCCouleurs.feuilleClaire,
      error:            CCCouleurs.erreur,
      onPrimary:        CCCouleurs.blanc,
      onSecondary:      CCCouleurs.vertProfond,
      onSurface:        CCCouleurs.nuit,
    ),
    textTheme:             CCTypographie.clair,
    appBarTheme:           _appBar,
    elevatedButtonTheme:   ElevatedButtonThemeData(style: _boutonPrincipal),
    outlinedButtonTheme:   OutlinedButtonThemeData(style: _boutonSecondaire),
    inputDecorationTheme:  _champSaisie,
    cardTheme:             _carte,
    dividerColor:          CCCouleurs.feuilleGrise,
  );

  // ── Dark 
  static ThemeData get sombre => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: CCCouleurs.nuit,
    colorScheme: const ColorScheme.dark(
      primary:          CCCouleurs.limeVif,
      primaryContainer: CCCouleurs.vertForet,
      secondary:        CCCouleurs.vertMoyen,
      surface:          CCCouleurs.vertProfond,
      error:            CCCouleurs.erreur,
      onPrimary:        CCCouleurs.vertProfond,
      onSurface:        CCCouleurs.feuilleClaire,
    ),
    textTheme:           CCTypographie.sombre,
    appBarTheme:         _appBarSombre,
    elevatedButtonTheme: ElevatedButtonThemeData(style: _boutonLime),
    cardTheme:           _carteSombre,
    dividerColor:        CCCouleurs.vertSombre,
  );

  // ── Styles partagés 

  static const AppBarTheme _appBar = AppBarTheme(
    backgroundColor: CCCouleurs.vertProfond,
    foregroundColor: CCCouleurs.blanc,
    elevation: 0,
    centerTitle: true,
  );

  static const AppBarTheme _appBarSombre = AppBarTheme(
    backgroundColor: CCCouleurs.vertSombre,
    foregroundColor: CCCouleurs.feuilleClaire,
    elevation: 0,
    centerTitle: true,
  );

  // Bouton principal — vert forêt (light)
  static ButtonStyle get _boutonPrincipal => ElevatedButton.styleFrom(
    backgroundColor: CCCouleurs.vertForet,
    foregroundColor: CCCouleurs.blanc,
    minimumSize: const Size(double.infinity, 56),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w600),
    elevation: 0,
  );

  // Bouton CTA lime — à utiliser pour "+ Scanner un sac", actions clés
  static ButtonStyle get boutonLime => ElevatedButton.styleFrom(
    backgroundColor: CCCouleurs.limeVif,
    foregroundColor: CCCouleurs.vertProfond,
    minimumSize: const Size(double.infinity, 56),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w600),
    elevation: 0,
  );

  // Bouton lime (dark mode)
  static ButtonStyle get _boutonLime => boutonLime;

  // Bouton secondaire — contour vert forêt
  static ButtonStyle get _boutonSecondaire => OutlinedButton.styleFrom(
    foregroundColor: CCCouleurs.vertForet,
    side: const BorderSide(color: CCCouleurs.vertForet, width: 2),
    minimumSize: const Size(double.infinity, 56),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w600),
  );

  static InputDecorationTheme get _champSaisie => InputDecorationTheme(
    filled: true,
    fillColor: CCCouleurs.blanc,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: CCCouleurs.feuilleGrise),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: CCCouleurs.feuilleGrise),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: CCCouleurs.vertForet, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: CCCouleurs.erreur),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: CCCouleurs.erreur, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: GoogleFonts.epilogue(fontSize: 14, color: CCCouleurs.grisTexte),
    prefixIconColor: CCCouleurs.grisTexte,
  );

  static const CardThemeData _carte = CardThemeData(
    color: CCCouleurs.blanc,
    elevation: 0,
    shadowColor: Color(0x1A076653),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      side: BorderSide(color: CCCouleurs.feuilleGrise),
    ),
  );

  static const CardThemeData _carteSombre = CardThemeData(
    color: CCCouleurs.vertProfond,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );
}