import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Ces imports seront créés au fur et à mesure
// import 'configuration/routage.dart';
// import 'configuration/theme.dart';

void main() async {
  // 1. Initialisation des services système
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Fixer l'orientation en portrait pour éviter les bugs d'affichage
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        // On ajoutera ici nos ChangeNotifierProviders (Langue, Auth, Agriculteur)
        // ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const ChainCacaoApp(),
    ),
  );
}

class ChainCacaoApp extends StatelessWidget {
  const ChainCacaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Utilisation de .router pour GoRouter
    return MaterialApp.router(
      title: 'ChainCacao',
      debugShowCheckedModeBanner: false,

      // Configuration du thème (on le déplacera dans configuration/theme.dart)
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6B3A2A), // Brun Cacao
        fontFamily: 'Poppins',
      ),

      // Configuration du routage (on le déplacera dans configuration/routage.dart)
      // routerConfig: ConfigurationRoutage.router,

      // En attendant GoRouter, on peut utiliser un placeholder ou builder
      builder: (context, child) =>
          child ??
          const Scaffold(body: Center(child: Text("ChainCacao Ready"))),
    );
  }
}
