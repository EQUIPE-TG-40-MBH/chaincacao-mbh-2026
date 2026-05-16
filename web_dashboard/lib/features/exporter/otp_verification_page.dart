import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/auth_service.dart';

class OtpVerificationPage extends StatefulWidget {
  final EntityAccount account;
  const OtpVerificationPage({super.key, required this.account});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otpController.text.length < 4) {
      setState(() => _errorMessage = 'Veuillez entrer le code complet');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    // Simulation d'un délai réseau pour la connexion à ton API Render
    await Future.delayed(const Duration(seconds: 1)); 

    // Note pour le Hackathon : "1234" est ton code de test universel.
    // Pour la production, cet appel se fera via ApiClient.verifyOtp()
    if (_otpController.text == "1234" || _otpController.text.length == 4) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, widget.account.homeRoute);
      }
    } else {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _errorMessage = 'Code incorrect. Veuillez réessayer.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creme,
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.cacao.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_outlined, size: 64, color: AppColors.orChaud),
              const SizedBox(height: 24),
              const Text('Vérification de sécurité', style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Text(
                'Saisissez le code reçu par email sur\n${widget.account.email}',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 4,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 16),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '0000',
                  errorText: _errorMessage,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.orChaud, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isVerifying ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orChaud,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isVerifying 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Vérifier et Accéder', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour à la connexion', style: TextStyle(color: AppColors.grisTexte)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}