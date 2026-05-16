import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/auth_service.dart';

class RegulatorDashboardPage extends StatefulWidget {
  final EntityAccount? account;
  const RegulatorDashboardPage({super.key, required this.account});

  @override
  State<RegulatorDashboardPage> createState() => _RegulatorDashboardPageState();
}

class _RegulatorDashboardPageState extends State<RegulatorDashboardPage> {
  List<Map<String, dynamic>> _lots = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final data = await ApiClient.getLots();
    if (mounted) {
      setState(() {
        final isOTR = widget.account?.entityName.contains('OTR') ?? false;
        _lots = data.where((l) => isOTR ? l['status'] == 'EXPORTED' : l['status'] == 'REGISTERED').toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final entityName = widget.account?.entityName ?? 'Régulateur';
    final isOTR = entityName.contains('OTR');

    return Scaffold(
      backgroundColor: AppColors.creme,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.cacao, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(isOTR ? Icons.account_balance : Icons.verified, color: AppColors.orChaud, size: 32),
                  const SizedBox(width: 16),
                  Text('Portail Supervision : $entityName', style: AppTextStyles.h2.copyWith(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(isOTR ? 'Cargaisons en attente de dédouanement' : 'Lots en attente de certification qualité', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            Expanded(
              child: _loading 
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _lots.length,
                    itemBuilder: (context, index) {
                      final lot = _lots[index];
                      return Card(
                        child: ListTile(
                          title: Text('Lot ${lot['lot_id']}', style: AppTextStyles.h3),
                          subtitle: Text('Origine: ${lot['farmer_name']} • Poids: ${lot['weight_declared']} kg'),
                          trailing: ElevatedButton(
                            onPressed: () => _loadData(),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.orChaud),
                            child: Text(isOTR ? 'Valider Douanes' : 'Certifier Qualité'),
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}