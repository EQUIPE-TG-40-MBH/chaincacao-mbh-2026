import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ImporterReceptionPage extends StatelessWidget {
  const ImporterReceptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creme,
      appBar: AppBar(backgroundColor: AppColors.cacao, title: const Text('Portail Importateur EU')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Réception des Cargaisons', style: AppTextStyles.h1),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('EUDR-TG-2026-FUS1', style: AppTextStyles.h2),
                        const Chip(label: Text('CONFORME'), backgroundColor: AppColors.vertFeuille),
                      ],
                    ),
                    const Divider(height: 32),
                    ListTile(
                      leading: const Icon(Icons.eco),
                      title: const Text('Preuve de non-déforestation'),
                      subtitle: const Text('Vérifié via géolocalisation par satellite'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.link),
                      title: const Text('Hash Blockchain Polygon'),
                      subtitle: Text('0x72c5...4dc', style: AppTextStyles.hash),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}