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
    final data = await ApiClient.getLots();
    if (mounted) {
      setState(() {
        // Le régulateur voit tout ce qui est en attente ou certifié
        _lots = data.where((l) => l['status'] == 'REGISTERED' || l['status'] == 'EXPORTED').toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creme,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.cacao, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.gavel, color: AppColors.orChaud),
                  const SizedBox(width: 12),
                  Text('Supervision Gouvernementale : ${widget.account?.entityName}', style: AppTextStyles.h3.copyWith(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: _loading 
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _lots.length,
                    itemBuilder: (context, index) {
                      final lot = _lots[index];
                      return ListTile(
                        leading: const Icon(Icons.inventory_2, color: AppColors.cacao),
                        title: Text('Lot ${lot['lot_id']}'),
                        subtitle: Text('Statut actuel: ${lot['status']}'),
                        trailing: const Icon(Icons.verified_user_outlined, color: AppColors.vertFeuille),
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