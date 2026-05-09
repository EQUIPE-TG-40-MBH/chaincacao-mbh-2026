import 'package:flutter/material.dart';
import 'core/widgets/auth_gate.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_page.dart';
import 'features/cooperative/cooperative_dashboard.dart';
import 'features/exporter/exporter_dashboard.dart';
import 'features/verifier/verifier_page.dart';

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
        '/exportateur': (context) => const AuthGate(
          requiredRole: 'exportateur',
          child: ExporterDashboard(),
        ),
        '/verifier': (context) => const VerifierPage(),
      },
    );
  }
}
