import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Page "Mode invité": permet d'ouvrir les dashboards sans passer par login/password.
///
/// Note: ceci crée un compte local (SharedPreferences) avec un rôle démo.
class GuestModePage extends StatefulWidget {
  const GuestModePage({super.key});

  @override
  State<GuestModePage> createState() => _GuestModePageState();
}

class _GuestModePageState extends State<GuestModePage> {
  String _selectedRole = 'cooperative';
  String _selectedActorName = 'Invité'; // Valeur par défaut

  static const _roleLabels = <String, String>{
    'cooperative': 'Cooperative',
    'ccfcc': 'CCFCC (Qualité)',
    'otr': 'OTR (Douanes)',
    'exportateur': 'Exportateur',
    'verificateur': 'Verificateur',
    'importateur': 'Importateur',
  };

  @override
  Widget build(BuildContext context) {
    // final selectedLabel = _roleLabels[_selectedRole] ?? _selectedRole; // Non utilisé

    return Scaffold(
      backgroundColor: AppColors.creme,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Passer en mode invité…',
                  style: AppTextStyles.h1,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sélectionne un acteur (rôle) pour ouvrir le dashboard sans authentification.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1) Rôle / dashboard',
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedRole,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        ),
                        items: _roleLabels.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ), // Correction: utiliser e.value pour le texte
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() {
                            _selectedRole = v;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '2) Nom de l’acteur (démo)',
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Nom de l\'acteur (Ex: COOP-TG-001)',
                          prefixIcon: Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        ),
                        controller: TextEditingController(text: _selectedActorName), // Pré-remplir
                        onChanged: (v) => setState(() => _selectedActorName = v),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.login),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orChaud,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            // Utilise le nom saisi ou le défaut
                            final actorName = _selectedActorName.isNotEmpty ? _selectedActorName : 'Invité';

                            final account = EntityAccount(
                              entityName: actorName, // Utilise le nom saisi
                              email: 'guest@local',
                              password: 'guest123',
                              role: _selectedRole,
                              phone: '',
                              registrationId: 'GUEST',
                              createdAt: DateTime.now().toIso8601String(),
                              token: 'guest-token',
                            );

                            // Sauvegarde la session invité
                            await AuthService.setGuestSession(account);

                            if (!mounted) return;
                            // Navigue directement vers le dashboard du rôle sélectionné
                            // Utilise Navigator.pushReplacementNamed pour le routage standard
                            String homeRoute;
                            switch (_selectedRole) {
                              case 'cooperative':
                                homeRoute = '/cooperative';
                                break;
                              case 'exportateur':
                                homeRoute = '/exportateur';
                                break;
                              case 'ccfcc':
                                homeRoute = '/ccfcc';
                                break;
                              case 'otr':
                                homeRoute = '/otr';
                                break;
                              case 'importateur':
                                homeRoute = '/importer/reception';
                                break;
                              default:
                                homeRoute = '/';
                            }
                            Navigator.pushReplacementNamed(context, homeRoute);
                          },
                          label: const Text('Continuer'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
