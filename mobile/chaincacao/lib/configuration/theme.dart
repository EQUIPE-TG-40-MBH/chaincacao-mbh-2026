// lib/configuration/theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ───COULEURS
class CCCouleurs {
  CCCouleurs._();

  // Principales
  static const limeVif = Color(0xFFD1F811); // Accent, CTA, badges
  static const limePale = Color(0xFFEBF97F); // Hover, états actifs
  static const vertForet = Color(0xFF076653); // Boutons, liens, primaire
  static const vertMoyen = Color(0xFF3D9E7A); // Variante intermédiaire
  static const vertProfond = Color(0xFF02403D); // App bar, splash, headers
  static const vertSombre = Color(0xFF012B29); // Fonds très sombres

  // Neutres
  static const nuit = Color(0xFF0A1628); // Textes, dark surface
  static const feuilleClaire = Color(0xFFF5F9EE); // Fond clair, cartes
  static const feuilleGrise = Color(0xFFDDEDD4); // Bordures, séparateurs
  static const grisTexte = Color(0xFF5A7060); // Labels, placeholders
  static const blanc = Color(0xFFFFFFFF);

  // Statuts
  static const succes = Color(0xFF076653);
  static const succesClair = Color(0xFFE8F5EF);
  static const attention = Color(0xFFD97706);
  static const attentionClair = Color(0xFFFEF3C7);
  static const transit = Color(0xFF1D4ED8);
  static const transitClair = Color(0xFFEFF6FF);
  static const erreur = Color(0xFFDC2626);
  static const erreurClair = Color(0xFFFEE2E2);
}

// ───TYPOGRAPHIE
// lib/configuration/theme.dart
// Remplace CCTypographie

class CCTypographie {
  CCTypographie._();

  // ── Mode clair ────────────────────────────────────────────────────────
  static TextTheme get clair => TextTheme(
    // Très grands titres hero
    // ex : "Bonjour Koami !" sur le dashboard
    displayLarge: GoogleFonts.plusJakartaSans(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      color: CCCouleurs.vertProfond,
      height: 1.15,
      letterSpacing: -1.0,
    ),
    displayMedium: GoogleFonts.plusJakartaSans(
      fontSize: 30,
      fontWeight: FontWeight.w800,
      color: CCCouleurs.vertProfond,
      height: 1.2,
      letterSpacing: -0.8,
    ),

    // Titres d'écran
    // ex : "Scanner le QR Code", "Connexion"
    headlineLarge: GoogleFonts.plusJakartaSans(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: CCCouleurs.vertProfond,
      letterSpacing: -0.5,
      height: 1.25,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: CCCouleurs.vertProfond,
      letterSpacing: -0.3,
      height: 1.3,
    ),
    headlineSmall: GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: CCCouleurs.vertProfond,
      height: 1.3,
    ),

    // Titres de cartes / sections
    titleLarge: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: CCCouleurs.nuit,
      letterSpacing: -0.2,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: CCCouleurs.nuit,
    ),
    titleSmall: GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: CCCouleurs.nuit,
    ),

    // Corps — DM Sans, lisible et moderne
    bodyLarge: GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: CCCouleurs.nuit,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: CCCouleurs.nuit,
      height: 1.55,
    ),
    bodySmall: GoogleFonts.dmSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: CCCouleurs.grisTexte,
      height: 1.5,
    ),

    // Labels — boutons, badges, nav
    labelLarge: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.dmSans(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: CCCouleurs.grisTexte,
    ),
    labelSmall: GoogleFonts.dmSans(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: CCCouleurs.grisTexte,
      letterSpacing: 0.2,
    ),
  );

  // ── Mode sombre 
  static TextTheme get sombre => clair.copyWith(
    displayLarge: GoogleFonts.plusJakartaSans(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      color: CCCouleurs.limeVif,
      height: 1.15,
      letterSpacing: -1.0,
    ),
    displayMedium: GoogleFonts.plusJakartaSans(
      fontSize: 30,
      fontWeight: FontWeight.w800,
      color: CCCouleurs.limeVif,
      height: 1.2,
      letterSpacing: -0.8,
    ),
    headlineLarge: GoogleFonts.plusJakartaSans(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: CCCouleurs.feuilleClaire,
      letterSpacing: -0.5,
      height: 1.25,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: CCCouleurs.feuilleClaire,
      letterSpacing: -0.3,
      height: 1.3,
    ),
    headlineSmall: GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: CCCouleurs.feuilleClaire,
      height: 1.3,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: CCCouleurs.feuilleClaire,
    ),
    bodyLarge: GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: CCCouleurs.feuilleClaire,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: CCCouleurs.feuilleClaire,
      height: 1.55,
    ),
  );

  // ── Helper : texte accent lime dans un titre (comme "debt-free") ──────
  // Usage : RichText avec TextSpan
  static TextStyle get accentLime => GoogleFonts.plusJakartaSans(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: CCCouleurs.limeVif,
    letterSpacing: -0.5,
  );

  static TextStyle get accentBlanc => GoogleFonts.plusJakartaSans(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: CCCouleurs.blanc,
    letterSpacing: -0.5,
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
      primary: CCCouleurs.vertForet,
      primaryContainer: CCCouleurs.vertProfond,
      secondary: CCCouleurs.limeVif,
      surface: CCCouleurs.feuilleClaire,
      error: CCCouleurs.erreur,
      onPrimary: CCCouleurs.blanc,
      onSecondary: CCCouleurs.vertProfond,
      onSurface: CCCouleurs.nuit,
    ),
    textTheme: CCTypographie.clair,
    appBarTheme: _appBar,
    elevatedButtonTheme: ElevatedButtonThemeData(style: _boutonPrincipal),
    outlinedButtonTheme: OutlinedButtonThemeData(style: _boutonSecondaire),
    inputDecorationTheme: _champSaisie,
    cardTheme: _carte,
    dividerColor: CCCouleurs.feuilleGrise,
  );

  // ── Dark
  static ThemeData get sombre => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: CCCouleurs.nuit,
    colorScheme: const ColorScheme.dark(
      primary: CCCouleurs.limeVif,
      primaryContainer: CCCouleurs.vertForet,
      secondary: CCCouleurs.vertMoyen,
      surface: CCCouleurs.vertProfond,
      error: CCCouleurs.erreur,
      onPrimary: CCCouleurs.vertProfond,
      onSurface: CCCouleurs.feuilleClaire,
    ),
    textTheme: CCTypographie.sombre,
    appBarTheme: _appBarSombre,
    elevatedButtonTheme: ElevatedButtonThemeData(style: _boutonLime),
    cardTheme: _carteSombre,
    dividerColor: CCCouleurs.vertSombre,
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
