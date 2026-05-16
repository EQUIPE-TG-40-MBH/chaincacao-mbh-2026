import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/api_client.dart';
import '../../core/widgets/dashboard_shell.dart';
import 'eudr_certificate_page.dart';

class ExporterDashboard extends StatefulWidget {
  const ExporterDashboard({super.key});

  @override
  State<ExporterDashboard> createState() => _ExporterDashboardState();
}

class _ExporterDashboardState extends State<ExporterDashboard> {
  List<Map<String, dynamic>> _lots = [];
  List<Map<String, dynamic>> _exports = [];
  bool _loading = true;
  EntityAccount? _account;

  List<Map<String, dynamic>> get _selectedLots =>
      _lots.where((lot) => lot['selected'] == true).toList();

  double get _totalSelectedKg => _selectedLots.fold(
    0,
    (sum, lot) => sum + ((lot['weight_verified'] ?? lot['weight_declared'] ?? 0) as num).toDouble(),
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final lots = await ApiClient.getLots();
    // Note: Pour l'historique des exports réels, on pourrait ajouter une méthode getCertificates
    final account = await AuthService.currentAccount();
    if (!mounted) return;
    setState(() {
      _lots = lots // ApiClient.getLots() retourne déjà des lots réels
          .where((lot) => lot['status'] == 'VALIDATED' || lot['status'] == 'CERTIFIED')
          .map((lot) => {...lot, 'selected': false})
          .toList();
      _exports = []; // À brancher sur ApiClient.getCertificates() plus tard
      _account = account;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      currentRoute: '/exportateur',
      pageTitle: 'Lots disponibles a l export',
      pageSubtitle:
          'Selectionnez les lots consolides pour generer un certificat EUDR',
      userName: _account?.entityName ?? 'Exportateur',
      userRole: _account?.roleLabel ?? 'Exportateur',
      floatingAction: _selectedLots.isEmpty
          ? null
          : _ExportActionBar(
              selectedLots: _selectedLots.length,
              totalKg: _totalSelectedKg,
              onGenerate: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => 
                    EudrCertificatePage(
                      lots: _selectedLots,
                      totalKg: _totalSelectedKg,
                    ),
                  ),
                ).then((_) => _loadData());
              },
            ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth < 680 ? 1 : 2;
                    return GridView.count(
                      crossAxisCount: columns,
                      childAspectRatio: columns == 1 ? 4.2 : 1.9,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _StatCard(
                            title: 'Lots disponibles',
                            value: '${_lots.length}',
                            icon: Icons.inventory_2_outlined,
                            color: AppColors.orChaud,
                          ),
                        _StatCard(
                            title: 'Lots selectionnes',
                            value: '${_selectedLots.length}',
                            icon: Icons.check_circle_outline,
                            color: AppColors.vertFeuille,
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                ..._lots.asMap().entries.map(
                  (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _LotCard(
                        lot: entry.value,
                        onTap: () => setState(
                          () => _lots[entry.key]['selected'] =
                              !(_lots[entry.key]['selected'] as bool),
                        ),
                      ),
                    ),
                ),
                if (_exports.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _ExportHistoryCard(exports: _exports),
                ],
              ],
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: AppTextStyles.h2.copyWith(color: color)),
              Text(title, style: AppTextStyles.bodySecondary),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

class _LotCard extends StatelessWidget {
  final Map<String, dynamic> lot;
  final VoidCallback onTap;

  const _LotCard({required this.lot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = lot['selected'] == true;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.orChaud : Colors.transparent, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.orChaud : AppColors.creme,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.orChaud
                        : const Color(0xFFE0D5C8),
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: AppColors.blanc, size: 18)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          lot['lot_id'],
                          style: AppTextStyles.hash.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.vertFeuille,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Valide',
                            style: AppTextStyles.bodySecondary.copyWith(
                              color: AppColors.blanc,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(lot['farmer_name'], style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Text(
                      '${lot['culture_type']} - ${(lot['weight_verified'] ?? lot['weight_declared']).toInt()} kg',
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lot['registered_at'] ?? '',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportActionBar extends StatelessWidget {
  final int selectedLots;
  final double totalKg;
  final VoidCallback onGenerate;

  const _ExportActionBar({
    required this.selectedLots,
    required this.totalKg,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: Offset.zero,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cacao,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0x403D1C02), // Correction de l'opacité cacao
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$selectedLots lot(s) selectionne(s)',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.blanc,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${totalKg.toInt()} kg total',
                  style: AppTextStyles.bodySecondary.copyWith(
                    color: AppColors.grisTexte,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 260,
              child: ElevatedButton.icon(
                onPressed: onGenerate,
                icon: const Icon(Icons.description_outlined),
                label: const Text('Generer certificat EUDR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportHistoryCard extends StatelessWidget {
  final List<Map<String, dynamic>> exports;

  const _ExportHistoryCard({required this.exports});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Historique des exports', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          ...exports
              .take(5)
              .map(
                (export) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.creme,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: AppColors.orChaud,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              export['certificateId'],
                              style: AppTextStyles.hash.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${(export['lotIds'] as List).length} lot(s) - ${(export['totalKg'] as num).toInt()} kg - ${export['createdAt']}',
                              style: AppTextStyles.bodySecondary,
                            ),
                          ],
                        ),
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
