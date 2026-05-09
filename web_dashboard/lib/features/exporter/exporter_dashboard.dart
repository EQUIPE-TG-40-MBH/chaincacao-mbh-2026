import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'eudr_certificate_page.dart';

class ExporterDashboard extends StatefulWidget {
  const ExporterDashboard({super.key});

  @override
  State<ExporterDashboard> createState() => _ExporterDashboardState();
}

class _ExporterDashboardState extends State<ExporterDashboard> {
  final List<Map<String, dynamic>> _lots = [
    {
      'lotId': 'TG-2026-0468',
      'farmerName': 'Mensah Koffi',
      'cooperativeName': 'CAPRK Kpalimé',
      'weightVerified': 178.0,
      'cultureType': 'Cacao',
      'status': 'VALIDATED',
      'gps': '6.8945° N, 0.6521° E',
      'registeredAt': '08 Mai 2026',
      'blockchainHash': '0x4D8E2A11...C93f',
      'selected': false,
    },
    {
      'lotId': 'TG-2026-0465',
      'farmerName': 'Kofi Amevor',
      'cooperativeName': 'CAPRK Kpalimé',
      'weightVerified': 220.0,
      'cultureType': 'Cacao',
      'status': 'VALIDATED',
      'gps': '6.8912° N, 0.6498° E',
      'registeredAt': '07 Mai 2026',
      'blockchainHash': '0x8B2F4D33...A12e',
      'selected': false,
    },
    {
      'lotId': 'TG-2026-0462',
      'farmerName': 'Yawa Dossou',
      'cooperativeName': 'CAPRK Kpalimé',
      'weightVerified': 195.0,
      'cultureType': 'Cacao',
      'status': 'VALIDATED',
      'gps': '6.8934° N, 0.6511° E',
      'registeredAt': '06 Mai 2026',
      'blockchainHash': '0x3C9A1E44...D85b',
      'selected': false,
    },
  ];

  List<Map<String, dynamic>> get _selectedLots =>
      _lots.where((l) => l['selected'] == true).toList();

  double get _totalSelectedKg => _selectedLots.fold(
      0, (sum, l) => sum + (l['weightVerified'] as double));

  Widget _buildLotCard(Map<String, dynamic> lot, int index) {
    final isSelected = lot['selected'] == true;
    return GestureDetector(
      onTap: () => setState(() => _lots[index]['selected'] = !isSelected),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.blanc,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.orChaud : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.orChaud : AppColors.creme,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? AppColors.orChaud : AppColors.grisTexte,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: AppColors.blanc, size: 16)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lot['lotId'],
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'JetBrainsMono',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.vertFeuille,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '✓ Validé',
                            style: AppTextStyles.bodySecondary.copyWith(
                                color: AppColors.blanc,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lot['farmerName'],
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${lot['cultureType']} · ${lot['weightVerified'].toInt()} kg · ${lot['cooperativeName']}',
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: 2),
                    Text(lot['registeredAt'],
                        style: AppTextStyles.bodySecondary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChainCacao — Exportateur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lots disponibles à l\'export', style: AppTextStyles.h2),
                const SizedBox(height: 4),
                Text(
                  'Sélectionnez les lots à consolider pour générer le certificat EUDR',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 24),

                // Stats
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
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
                            const Icon(Icons.inventory_2,
                                color: AppColors.orChaud),
                            const SizedBox(height: 8),
                            Text('${_lots.length}',
                                style: AppTextStyles.h2
                                    .copyWith(color: AppColors.orChaud)),
                            Text('Lots disponibles',
                                style: AppTextStyles.bodySecondary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
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
                            const Icon(Icons.check_circle,
                                color: AppColors.vertFeuille),
                            const SizedBox(height: 8),
                            Text('${_selectedLots.length}',
                                style: AppTextStyles.h2.copyWith(
                                    color: AppColors.vertFeuille)),
                            Text('Lots sélectionnés',
                                style: AppTextStyles.bodySecondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Liste des lots
                ..._lots.asMap().entries.map(
                      (e) => _buildLotCard(e.value, e.key),
                    ),
              ],
            ),
          ),

          // Bouton flottant
          if (_selectedLots.isNotEmpty)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cacao,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedLots.length} lot(s) sélectionné(s)',
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.blanc),
                          ),
                          Text(
                            '${_totalSelectedKg.toInt()} kg total',
                            style: AppTextStyles.bodySecondary
                                .copyWith(color: AppColors.grisTexte),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EudrCertificatePage(
                              lots: _selectedLots,
                              totalKg: _totalSelectedKg,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orChaud,
                        minimumSize: const Size(0, 48),
                      ),
                      child: const Text('Générer certificat EUDR'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}