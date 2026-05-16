import 'package:flutter/material.dart';
import 'core/widgets/auth_gate.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_page.dart';
import 'features/cooperative/cooperative_dashboard.dart';
import 'features/exporter/exporter_dashboard.dart';
import 'features/verifier/verifier_page.dart';
import 'features/guest/guest_mode_page.dart';

void main() {
  runApp(const ChainCacaoApp());
}

class ChainCacaoApp extends StatelessWidget {
  const ChainCacaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChainCacao',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/cooperative': (context) => const AuthGate(
          requiredRole: 'cooperative',
          child: CooperativeDashboard(),
        ),
        '/cooperative/lots': (context) => const AuthGate(
          requiredRole: 'cooperative',
          child: CooperativeDashboard(),
        ),
        '/exportateur': (context) => const AuthGate(
          requiredRole: 'exportateur',
          // child: ExporterDashboard(), // Commenté pour éviter le conflit si tu as déjà une route /exporter/dashboard
          child: ExporterDashboard(),
        ),
        '/verifier': (context) => const VerifierPage(),
        '/exporter/dashboard': (context) => const AuthGate(
          requiredRole: 'exportateur',
          child: ExporterDashboard(),
        ),
        '/guest': (context) => const GuestModePage(), // Nouvelle route pour le mode invité
        '/regulator/dashboard': (context) => const VerifierPage(),
        '/importer/reception': (context) => const VerifierPage(),
      },
    );
  }
}
