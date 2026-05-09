import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LotValidationPage extends StatefulWidget {
  final Map<String, dynamic> lot;
  const LotValidationPage({super.key, required this.lot});

  @override
  State<LotValidationPage> createState() => _LotValidationPageState();
}

class _LotValidationPageState extends State<LotValidationPage> {
  final _weightController = TextEditingController();
  bool _validated = false;
  bool _loading = false;
  String? _hash;

  bool get _hasFraud {
    final declared = widget.lot['weightDeclared'] as double;
    final verified = double.tryParse(_weightController.text) ?? 0;
    if (verified == 0) return false;
    final diff = ((declared - verified) / declared).abs();
    return diff > 0.05;
  }

  Future<void> _validate() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _loading = false;
      _validated = true;
      _hash = '0x72c5B327...948dc';
    });
  }

  @override
  Widget build(BuildContext context) {
    final lot = widget.lot;
    return Scaffold(
      appBar: AppBar(title: const Text('Validation du lot')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _validated ? _buildSuccess() : _buildForm(lot),
      ),
    );
  }

  Widget _buildForm(Map<String, dynamic> lot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fiche du lot
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.blanc,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fiche du lot', style: AppTextStyles.h2),
              const Divider(height: 24),
              _buildInfoRow('ID Lot', lot['lotId']),
              _buildInfoRow('Agriculteur', lot['farmerName']),
              _buildInfoRow('Culture', lot['cultureType']),
              _buildInfoRow('Poids déclaré', '${lot['weightDeclared'].toInt()} kg'),
              _buildInfoRow('GPS', lot['gps']),
              _buildInfoRow('Enregistré le', lot['registeredAt']),
              _buildInfoRow('Hash blockchain', lot['blockchainHash']),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Saisie poids vérifié
        Text('Poids vérifié à la coopérative',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _weightController,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Entrez le poids réel pesé',
            suffixText: 'kg',
            prefixIcon: Icon(Icons.scale),
          ),
        ),

        // Alerte fraude
        if (_hasFraud) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
              border: const Border(
                left: BorderSide(color: AppColors.rougeErreur, width: 4),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber,
                    color: AppColors.rougeErreur, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '⚠ Alerte fraude détectée — Écart supérieur à 5% entre le poids déclaré et le poids vérifié.',
                    style: AppTextStyles.bodySecondary
                        .copyWith(color: AppColors.rougeErreur),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: _weightController.text.isEmpty ? null : _validate,
          child: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: AppColors.blanc, strokeWidth: 2),
                )
              : const Text('Valider le transfert sur blockchain'),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.vertFeuille,
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Icon(Icons.check, color: AppColors.blanc, size: 48),
        ),
        const SizedBox(height: 24),
        Text('Lot validé !', style: AppTextStyles.h1),
        const SizedBox(height: 8),
        Text('Transaction enregistrée sur la blockchain Polygon',
            style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.blanc,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hash de transaction',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(_hash ?? '',
                  style: AppTextStyles.hash),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Voir sur Polygonscan →',
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.bleuTransit,
                      decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Retour au dashboard'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: AppTextStyles.bodySecondary
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }
}