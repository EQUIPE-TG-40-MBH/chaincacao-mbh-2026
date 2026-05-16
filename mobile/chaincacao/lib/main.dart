// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'configuration/theme.dart';
import 'configuration/routage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait uniquement
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Barre de statut transparente sur fond vert profond
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    const ChainCacaoApp()
    // MultiProvider(
    //   providers: [

    //     // On ajoutera ici au fur et à mesure :
    //     // ChangeNotifierProvider(create: (_) => ProviderLangue()),
    //     // ChangeNotifierProvider(create: (_) => ProviderAuth()),
    //   ],
    //   child: const ChainCacaoApp(),
    // ),
  );
}

class ChainCacaoApp extends StatelessWidget {
  const ChainCacaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ChainCacao',
      debugShowCheckedModeBanner: false,

      // Thème défini dans configuration/theme.dart
      theme:      CCTheme.clair,
      darkTheme:  CCTheme.sombre,
      themeMode:  ThemeMode.system,

      // Routage défini dans configuration/routage.dart
      routerConfig: CCRoutage.router,
    );
  }
}
