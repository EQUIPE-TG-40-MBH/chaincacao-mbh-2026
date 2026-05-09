import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  // Comptes de démo
  final Map<String, Map<String, String>> _demoAccounts = {
    'cooperative@chaincacao.tg': {'password': 'demo123', 'role': 'cooperative'},
    'exportateur@chaincacao.tg': {'password': 'demo123', 'role': 'exportateur'},
  };

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Connexion démo sans backend
    if (_demoAccounts.containsKey(email) &&
        _demoAccounts[email]!['password'] == password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', 'demo-token-123');
      await prefs.setString('role', _demoAccounts[email]!['role']!);
      await prefs.setString('email', email);

      if (mounted) {
        final role = _demoAccounts[email]!['role']!;
        if (role == 'cooperative') {
          Navigator.pushReplacementNamed(context, '/cooperative');
        } else {
          Navigator.pushReplacementNamed(context, '/exportateur');
        }
      }
    } else {
      setState(() {
        _error = 'Email ou mot de passe incorrect';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cacao,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.orChaud,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.link,
                    color: AppColors.blanc,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'ChainCacao',
                  style: AppTextStyles.h1.copyWith(color: AppColors.blanc),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tracabilité et Confiance',
                  style: AppTextStyles.bodySecondary.copyWith(
                    color: AppColors.grisTexte,
                  ),
                ),
                const SizedBox(height: 48),

                // Carte connexion
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.blanc,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Connexion', style: AppTextStyles.h2),
                      const SizedBox(height: 8),
                      Text(
                        'Accès réservé aux coopératives, exportateurs et certifiants',
                        style: AppTextStyles.bodySecondary,
                      ),
                      const SizedBox(height: 24),

                      // Email
                      Text('Email professionnel',
                          style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'cooperative@example.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Mot de passe
                      Text('Mot de passe',
                          style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: Icon(Icons.lock_outlined),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Erreur
                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(8),
                            border: const Border(
                              left: BorderSide(
                                  color: AppColors.rougeErreur, width: 4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber,
                                  color: AppColors.rougeErreur, size: 16),
                              const SizedBox(width: 8),
                              Text(_error!,
                                  style: AppTextStyles.bodySecondary.copyWith(
                                      color: AppColors.rougeErreur)),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Bouton connexion
                      ElevatedButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.blanc,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Se connecter'),
                      ),
                      const SizedBox(height: 16),

                      // Comptes démo
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F3E8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Comptes de démo :',
                                style: AppTextStyles.bodySecondary.copyWith(
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(
                              'cooperative@chaincacao.tg / demo123\nexportateur@chaincacao.tg / demo123',
                              style: AppTextStyles.bodySecondary.copyWith(
                                  fontFamily: 'JetBrainsMono', fontSize: 12),
                            ),
                          ],
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