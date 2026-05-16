import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_client.dart';

class CooperativeHomePage extends StatefulWidget {
  final EntityAccount? account;
  final VoidCallback? onViewAllLots;
  final VoidCallback? onAddFarmer;
  final VoidCallback? onRegisterHarvest;
  final VoidCallback? onBuy;

  const CooperativeHomePage({
    super.key,
    required this.account,
    this.onViewAllLots,
    this.onAddFarmer,
    this.onRegisterHarvest,
    this.onBuy,
  });

  @override
  State<CooperativeHomePage> createState() => _CooperativeHomePageState();
}

class _CooperativeHomePageState extends State<CooperativeHomePage> {
  List<Map<String, dynamic>> _lots = [];
  List<Map<String, dynamic>> _farmers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final coopId = widget.account?.registrationId ?? 'COOP-TG-001';
    final lots = await ApiClient.getLots();
    final farmers = await ApiClient.getFarmers(cooperativeId: coopId);
    if (mounted) {
      setState(() {
        _lots = lots;
        _farmers = farmers;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.orChaud),
      );
    }

    final registered = _lots.where((l) => l['status'] == 'REGISTERED').length;
    final validated = _lots.where((l) => l['status'] == 'VALIDATED').length;
    final fraudAlerts = _lots.where((l) => l['fraud_alert'] == true).length;
    final totalKg = _lots.fold<double>(
      0,
      (sum, lot) => sum + ((lot['weight_declared'] as num?) ?? 0).toDouble(),
    );

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.orChaud,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(isMobile),
            const SizedBox(height: 28),
            _buildQuickActions(isMobile),
            const SizedBox(height: 32),
            Text('Apercu du jour', style: AppTextStyles.h2),
            const SizedBox(height: 16),
            _buildStatsGrid(isMobile, registered, validated, fraudAlerts, totalKg),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Derniers lots', style: AppTextStyles.h2),
                TextButton.icon(
                  onPressed: widget.onViewAllLots,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Voir tous'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.orChaud),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRecentLots(isMobile),
            const SizedBox(height: 32),
            _buildFarmersSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.cacao, Color(0xFF6B3410)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, ${widget.account?.entityName ?? 'Cooperative'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gerez votre production, vos agriculteurs et vos lots.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.orChaud.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.orChaud.withOpacity(0.4)),
                  ),
                  child: Text(
                    'ID: ${widget.account?.registrationId ?? 'N/A'}',
                    style: const TextStyle(
                      color: AppColors.orVif,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.agriculture,
                color: AppColors.orVif,
                size: 44,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isMobile) {
    final actions = [
      _QuickAction(
        icon: Icons.person_add_outlined,
        label: 'Ajouter agriculteur',
        color: AppColors.cacao,
        onTap: widget.onAddFarmer,
      ),
      _QuickAction(
        icon: Icons.agriculture_outlined,
        label: 'Enregistrer recolte',
        color: AppColors.vertFeuille,
        onTap: widget.onRegisterHarvest,
      ),
      _QuickAction(
        icon: Icons.shopping_cart_outlined,
        label: 'Acheter recolte',
        color: AppColors.orChaud,
        onTap: widget.onBuy,
      ),
      _QuickAction(
        icon: Icons.inventory_2_outlined,
        label: 'Voir les lots',
        color: AppColors.bleuTransit,
        onTap: widget.onViewAllLots,
      ),
    ];

    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      childAspectRatio: isMobile ? 1.4 : 1.6,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: actions.map((action) => _buildActionCard(action)).toList(),
    );
  }

  Widget _buildActionCard(_QuickAction action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: action.color.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: action.color.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(action.icon, color: action.color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              action.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.cacao,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(bool isMobile, int registered, int validated,
      int fraudAlerts, double totalKg) {
    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      childAspectRatio: isMobile ? 1.3 : 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
          title: 'En attente',
          value: registered.toString(),
          icon: Icons.hourglass_empty,
          color: AppColors.orangeAlerte,
        ),
        _StatCard(
          title: 'Valides',
          value: validated.toString(),
          icon: Icons.check_circle_outline,
          color: AppColors.vertFeuille,
        ),
        _StatCard(
          title: 'Alertes fraude',
          value: fraudAlerts.toString(),
          icon: Icons.warning_amber_outlined,
          color: AppColors.rougeErreur,
        ),
        _StatCard(
          title: 'Total collecte',
          value: '${totalKg.toInt()} kg',
          icon: Icons.scale_outlined,
          color: AppColors.bleuTransit,
        ),
      ],
    );
  }

  Widget _buildRecentLots(bool isMobile) {
    final recent = _lots.take(5).toList();

    if (recent.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('Aucun lot enregistre', style: AppTextStyles.bodySecondary),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: widget.onRegisterHarvest,
                icon: const Icon(Icons.add),
                label: const Text('Enregistrer la premiere recolte'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: recent.map((lot) {
        final status = lot['status'] ?? 'REGISTERED';
        final hasFraud = lot['fraud_alert'] == true;
        final statusColor = hasFraud
            ? AppColors.rougeErreur
            : status == 'VALIDATED'
                ? AppColors.vertFeuille
                : status == 'EXPORTED'
                    ? AppColors.bleuTransit
                    : AppColors.orangeAlerte;
        final statusLabel = hasFraud
            ? 'Alerte fraude'
            : status == 'VALIDATED'
                ? 'Valide'
                : status == 'EXPORTED'
                    ? 'Exporte'
                    : 'En attente';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(color: statusColor, width: 4),
              top: BorderSide(color: Colors.grey.shade100),
              right: BorderSide(color: Colors.grey.shade100),
              bottom: BorderSide(color: Colors.grey.shade100),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lot['lot_id'] ?? 'N/A',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.cacao,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lot['farmer_name'] ?? 'N/A'} • ${lot['weight_declared']} kg • ${lot['culture_type'] ?? ''}',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFarmersSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.orChaud.withOpacity(0.08),
            AppColors.orChaud.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orChaud.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.orChaud.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.people_outline, color: AppColors.orChaud, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_farmers.length} agriculteurs',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cacao,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cultivateurs actifs dans votre cooperative',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: widget.onAddFarmer,
            child: const Text('Gerer'),
            style: TextButton.styleFrom(foregroundColor: AppColors.orChaud),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(title, style: AppTextStyles.bodySecondary),
            ],
          ),
        ],
      ),
    );
  }
}