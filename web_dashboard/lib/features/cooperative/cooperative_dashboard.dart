import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'lot_validation_page.dart';

class CooperativeDashboard extends StatefulWidget {
  const CooperativeDashboard({super.key});

  @override
  State<CooperativeDashboard> createState() => _CooperativeDashboardState();
}

class _CooperativeDashboardState extends State<CooperativeDashboard> {
  // Données de démo
  final List<Map<String, dynamic>> _lots = [
    {
      'lotId': 'TG-2026-0471',
      'farmerName': 'Koami Agbeko',
      'weightDeclared': 250.0,
      'weightVerified': 0.0,
      'cultureType': 'Cacao',
      'status': 'REGISTERED',
      'gps': '6.8913° N, 0.6502° E',
      'registeredAt': '09 Mai 2026 - 08:32',
      'blockchainHash': '0x72c5B327...948dc',
    },
    {
      'lotId': 'TG-2026-0469',
      'farmerName': 'Akosua Mensah',
      'weightDeclared': 350.0,
      'weightVerified': 310.0,
      'cultureType': 'Cacao',
      'status': 'FRAUD_ALERT',
      'gps': '6.8900° N, 0.6489° E',
      'registeredAt': '09 Mai 2026 - 07:15',
      'blockchainHash': '0x9A3F1C22...B71e',
    },
    {
      'lotId': 'TG-2026-0468',
      'farmerName': 'Mensah Koffi',
      'weightDeclared': 180.0,
      'weightVerified': 178.0,
      'cultureType': 'Café',
      'status': 'VALIDATED',
      'gps': '6.8945° N, 0.6521° E',
      'registeredAt': '08 Mai 2026 - 16:45',
      'blockchainHash': '0x4D8E2A11...C93f',
    },
  ];

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.blanc,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: AppTextStyles.h2.copyWith(color: color, fontSize: 28)),
            Text(title, style: AppTextStyles.bodySecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'VALIDATED':
        color = AppColors.vertFeuille;
        label = '✓ Validé';
        break;
      case 'FRAUD_ALERT':
        color = AppColors.rougeErreur;
        label = '⚠ Alerte fraude';
        break;
      case 'IN_TRANSFER':
        color = AppColors.bleuTransit;
        label = '→ En transit';
        break;
      default:
        color = AppColors.orangeAlerte;
        label = '⏳ En attente';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: AppTextStyles.bodySecondary.copyWith(
              color: AppColors.blanc, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildLotCard(Map<String, dynamic> lot) {
    final isFraud = lot['status'] == 'FRAUD_ALERT';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(12),
        border: isFraud
            ? const Border(
                left: BorderSide(color: AppColors.rougeErreur, width: 4))
            : null,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lot['lotId'],
                    style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'JetBrainsMono')),
                _buildStatusBadge(lot['status']),
              ],
            ),
            const SizedBox(height: 8),
            Text(lot['farmerName'],
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              '${lot['cultureType']} · ${lot['weightDeclared'].toInt()} kg déclarés'
              '${lot['weightVerified'] > 0 ? ' · ${lot['weightVerified'].toInt()} kg vérifiés' : ''}',
              style: AppTextStyles.bodySecondary,
            ),
            if (isFraud) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber,
                        color: AppColors.rougeErreur, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Écart de ${(lot['weightDeclared'] - lot['weightVerified']).toInt()} kg détecté — Vérification requise',
                      style: AppTextStyles.bodySecondary
                          .copyWith(color: AppColors.rougeErreur),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(lot['registeredAt'], style: AppTextStyles.bodySecondary),
            const SizedBox(height: 12),
            if (lot['status'] == 'REGISTERED' || lot['status'] == 'FRAUD_ALERT')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LotValidationPage(lot: lot),
                      ),
                    ).then((_) => setState(() {}));
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  child: const Text('Valider ce lot'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingLots = _lots
        .where((l) => l['status'] == 'REGISTERED' || l['status'] == 'FRAUD_ALERT')
        .length;
    final fraudAlerts =
        _lots.where((l) => l['status'] == 'FRAUD_ALERT').length;
    final totalKg = _lots.fold<double>(
        0, (sum, l) => sum + (l['weightDeclared'] as double));

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChainCacao — Coopérative CAPRK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bonjour, CAPRK Kpalimé 👋', style: AppTextStyles.h2),
            Text('09 Mai 2026', style: AppTextStyles.bodySecondary),
            const SizedBox(height: 24),

            // Stats
            Row(
              children: [
                _buildStatCard(
                    'Lots en attente', '$pendingLots', Icons.inbox, AppColors.orChaud),
                const SizedBox(width: 12),
                _buildStatCard(
                    'Total kg', '${totalKg.toInt()}', Icons.scale, AppColors.vertFeuille),
                const SizedBox(width: 12),
                _buildStatCard(
                    'Alertes fraude', '$fraudAlerts', Icons.warning_amber, AppColors.rougeErreur),
              ],
            ),
            const SizedBox(height: 24),

            // Bouton scanner
            ElevatedButton.icon(
              onPressed: () {
                _showScanDialog(context);
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scanner un QR de lot'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            const SizedBox(height: 24),

            Text('Lots récents', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            ..._lots.map((lot) => _buildLotCard(lot)),
          ],
        ),
      ),
    );
  }

  void _showScanDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Scanner un lot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Entrez l\'ID du lot manuellement pour la démo :'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'TG-2026-0471',
                prefixIcon: Icon(Icons.qr_code),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final lot = _lots.firstWhere(
                (l) => l['lotId'] == controller.text.trim(),
                orElse: () => {},
              );
              if (lot.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LotValidationPage(lot: lot),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lot non trouvé')),
                );
              }
            },
            child: const Text('Rechercher'),
          ),
        ],
      ),
    );
  }
}