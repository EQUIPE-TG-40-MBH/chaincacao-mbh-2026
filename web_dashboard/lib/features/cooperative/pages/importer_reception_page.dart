import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/api_client.dart';

class ImporterReceptionPage extends StatelessWidget {
  const ImporterReceptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creme,
      appBar: AppBar(
        title: Text('EU Importer Portal', style: AppTextStyles.h2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.cacao,
        actions: [
          IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCard(),
            const SizedBox(height: 32),
            Text('Cargaisons récentes', style: AppTextStyles.h2),
            const SizedBox(height: 16),
            // Exemple de ligne de certificat
            _buildCertificateTile(
              id: 'EUDR-TG-2026-1029384',
              origin: 'Togo - Haho Union',
              weight: '12,500 kg',
              status: 'Conforme',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.cacao, Color(0xFF5D2E0A)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Certificats reçus', '42'),
          _statItem('Tonnes tracées', '158 T'),
          _statItem('Taux conformité', '100%'),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h1.copyWith(color: AppColors.orChaud)),
        Text(label, style: AppTextStyles.bodySecondary.copyWith(color: Colors.white70)),
      ],
    );
  }

  Widget _buildCertificateTile({required String id, required String origin, required String weight, required String status}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(id, style: AppTextStyles.h3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.vertFeuille.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(status, style: TextStyle(color: AppColors.vertFeuille, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: AppColors.grisTexte),
                const SizedBox(width: 8),
                Text(origin, style: AppTextStyles.body),
                const Spacer(),
                const Icon(Icons.scale_outlined, size: 18, color: AppColors.grisTexte),
                const SizedBox(width: 8),
                Text(weight, style: AppTextStyles.body),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
              child: const Text('Vérifier l\'arbre de traçabilité blockchain'),
            ),
          ],
        ),
      ),
    );
  }
}