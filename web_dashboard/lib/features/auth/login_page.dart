import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _entityNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _registrationIdController = TextEditingController();

  bool _loading = false;
  bool _registerMode = false;
  String _role = 'cooperative';
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final account = _registerMode
          ? await AuthService.register(
              entityName: _entityNameController.text,
              email: _emailController.text,
              password: _passwordController.text,
              role: _role,
              phone: _phoneController.text,
              registrationId: _registrationIdController.text,
            )
          : await AuthService.login(
              _emailController.text,
              _passwordController.text,
            );

      if (!mounted) return;
      if (account == null) {
        setState(() {
          _error = 'Compte introuvable ou mot de passe incorrect.';
          _loading = false;
        });
        return;
      }

      Navigator.pushReplacementNamed(context, account.homeRoute);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is StateError ? error.message : 'Action impossible.';
        _loading = false;
      });
    }
  }

  bool get _canSubmit {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().length < 6) {
      return false;
    }
    if (!_registerMode) return true;
    return _entityNameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _registrationIdController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cacao,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 76,
                  child: Image.asset(
                    'assets/logo/chaincacao_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _registerMode ? 'Creer un compte entite' : 'Connexion',
                  style: AppTextStyles.h1.copyWith(color: AppColors.blanc),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cooperatives, exportateurs et certificateurs gerent chacun leur propre espace.',
                  style: AppTextStyles.bodySecondary.copyWith(
                    color: AppColors.grisTexte,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.blanc,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: false,
                            label: Text('Connexion'),
                            icon: Icon(Icons.login),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text('Inscription'),
                            icon: Icon(Icons.app_registration),
                          ),
                        ],
                        selected: {_registerMode},
                        onSelectionChanged: (value) {
                          setState(() {
                            _registerMode = value.first;
                            _error = null;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      if (_registerMode) ...[
                        _FieldLabel('Type d entite'),
                        DropdownButtonFormField<String>(
                          initialValue: _role,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.business_outlined),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'cooperative',
                              child: Text('Cooperative'),
                            ),
                            DropdownMenuItem(
                              value: 'exportateur',
                              child: Text('Exportateur'),
                            ),
                            DropdownMenuItem(
                              value: 'verificateur',
                              child: Text('Verificateur / certificateur'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() => _role = value);
                          },
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel('Nom officiel de l entite'),
                        TextField(
                          controller: _entityNameController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'CAPRK Kpalime',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel('Telephone professionnel'),
                        TextField(
                          controller: _phoneController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: '+228 90 00 00 00',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel('Identifiant administratif'),
                        TextField(
                          controller: _registrationIdController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'COOP-TG-001 / RCCM / Certifiant',
                            prefixIcon: Icon(Icons.verified_user_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _FieldLabel('Email professionnel'),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'contact@chaincacao.tg',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel('Mot de passe'),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: '6 caracteres minimum',
                          prefixIcon: Icon(Icons.lock_outlined),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(8),
                            border: const Border(
                              left: BorderSide(
                                color: AppColors.rougeErreur,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber,
                                color: AppColors.rougeErreur,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: AppTextStyles.bodySecondary.copyWith(
                                    color: AppColors.rougeErreur,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loading || !_canSubmit ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.blanc,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _registerMode
                                    ? 'Creer le compte et entrer'
                                    : 'Se connecter',
                              ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          '/verifier',
                        ),
                        icon: const Icon(Icons.qr_code_2_outlined),
                        label: const Text('Verification publique sans compte'),
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

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
