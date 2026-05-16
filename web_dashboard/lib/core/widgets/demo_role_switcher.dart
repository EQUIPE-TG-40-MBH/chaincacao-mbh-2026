import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/auth_service.dart';

/// Affiche une boîte de dialogue pour accéder aux différents rôles en mode démo.
void showDemoSwitcher(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Accès Mode Démo', style: AppTextStyles.h2),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Choisissez un dashboard à explorer sans authentification.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 20),
          _roleTile(context, 'Coopérative', Icons.groups_outlined, '/cooperative', 'cooperative'),
          _roleTile(context, 'Exportateur', Icons.local_shipping_outlined, '/exportateur', 'exportateur'),
          _roleTile(context, 'Vérification Publique', Icons.qr_code_scanner, '/verifier', 'verificateur'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler', style: TextStyle(color: AppColors.grisTexte)),
        ),
      ],
    ),
  );
}

Widget _roleTile(BuildContext context, String title, IconData icon, String route, String role) {
  return ListTile(
    leading: Icon(icon, color: AppColors.orChaud),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    onTap: () async {
      // On crée une session fictive pour tromper l'AuthGate
      final account = EntityAccount(
        entityName: title,
        email: 'demo@chaincacao.tg',
        password: '',
        role: role,
        phone: '+228 00 00 00 00',
        registrationId: 'DEMO-2026',
        createdAt: DateTime.now().toIso8601String(),
        token: 'demo-token-bypass',
      );
      
      await AuthService.setGuestSession(account);
      
      if (context.mounted) {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, route);
      }
    },
  );
}