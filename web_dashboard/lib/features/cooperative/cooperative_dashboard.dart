import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/dashboard_shell.dart';
import 'lot_validation_page.dart';

class CooperativeDashboard extends StatefulWidget {
  const CooperativeDashboard({super.key});

  @override
  State<CooperativeDashboard> createState() => _CooperativeDashboardState();
}

class _CooperativeDashboardState extends State<CooperativeDashboard> {
  final List<Map<String, dynamic>> _lots = [
    {
      'lotId': 'TG-2026-0471',
      'farmerName': 'Koami Agbeko',
      'weightDeclared': 250.0,
      'weightVerified': 0.0,
      'cultureType': 'Cacao',
      'status': 'REGISTERED',
      'gps': '6.8913 N, 0.6502 E',
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
      'gps': '6.8900 N, 0.6489 E',
      'registeredAt': '09 Mai 2026 - 07:15',
      'blockchainHash': '0x9A3F1C22...B71e',
    },
    {
      'lotId': 'TG-2026-0468',
      'farmerName': 'Mensah Koffi',
      'weightDeclared': 180.0,
      'weightVerified': 178.0,
      'cultureType': 'Cafe',
      'status': 'VALIDATED',
      'gps': '6.8945 N, 0.6521 E',
      'registeredAt': '08 Mai 2026 - 16:45',
      'blockchainHash': '0x4D8E2A11...C93f',
    },
  ];

  final List<_ProductionPoint> _weeklyProduction = const [
    _ProductionPoint('Lun', 180),
    _ProductionPoint('Mar', 240),
    _ProductionPoint('Mer', 210),
    _ProductionPoint('Jeu', 320),
    _ProductionPoint('Ven', 280),
    _ProductionPoint('Sam', 430),
    _ProductionPoint('Dim', 260),
  ];

  @override
  Widget build(BuildContext context) {
    final pendingLots = _lots
        .where(
          (lot) =>
              lot['status'] == 'REGISTERED' || lot['status'] == 'FRAUD_ALERT',
        )
        .length;
    final fraudAlerts = _lots
        .where((lot) => lot['status'] == 'FRAUD_ALERT')
        .length;
    final totalKg = _lots.fold<double>(
      0,
      (sum, lot) => sum + (lot['weightDeclared'] as double),
    );

    return DashboardShell(
      currentRoute: '/cooperative',
      pageTitle: 'Bonjour, CAPRK Kpalime',
      pageSubtitle: '09 Mai 2026 - reception, controle et validation des lots',
      userName: 'CAPRK Kpalime',
      userRole: 'Cooperative',
      actions: [
        SizedBox(
          width: 220,
          child: ElevatedButton.icon(
            onPressed: () => _showScanDialog(context),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scanner QR'),
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 760 ? 1 : 3;
              return GridView.count(
                crossAxisCount: columns,
                childAspectRatio: columns == 1 ? 4.4 : 1.45,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  AnimatedAppear(
                    index: 0,
                    child: _StatCard(
                      title: 'Lots en attente',
                      value: '$pendingLots',
                      icon: Icons.inventory_2_outlined,
                      color: AppColors.orChaud,
                    ),
                  ),
                  AnimatedAppear(
                    index: 1,
                    child: _StatCard(
                      title: 'Total collecte',
                      value: '${totalKg.toInt()} kg',
                      icon: Icons.scale_outlined,
                      color: AppColors.vertFeuille,
                    ),
                  ),
                  AnimatedAppear(
                    index: 2,
                    child: _StatCard(
                      title: 'Alertes fraude',
                      value: '$fraudAlerts',
                      icon: Icons.warning_amber_outlined,
                      color: AppColors.rougeErreur,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          AnimatedAppear(
            index: 3,
            child: _ProductionChart(points: _weeklyProduction),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Text('Lots recents', style: AppTextStyles.h2),
              const SizedBox(width: 12),
              _StatusBadge(status: 'REGISTERED'),
            ],
          ),
          const SizedBox(height: 16),
          ..._lots.asMap().entries.map(
            (entry) => AnimatedAppear(
              index: 4 + entry.key,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _LotCard(
                  lot: entry.value,
                  onValidate: () {
                    Navigator.push(
                      context,
                      premiumRoute(LotValidationPage(lot: entry.value)),
                    ).then((_) => setState(() {}));
                  },
                ),
              ),
            ),
          ),
        ],
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
            const Text('Entrez l ID du lot manuellement pour la demo :'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'TG-2026-0471',
                prefixIcon: Icon(Icons.qr_code_2_outlined),
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
                (item) => item['lotId'] == controller.text.trim(),
                orElse: () => {},
              );
              if (lot.isNotEmpty) {
                Navigator.push(
                  context,
                  premiumRoute(LotValidationPage(lot: lot)),
                );
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Lot non trouve')));
              }
            },
            child: const Text('Rechercher'),
          ),
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
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 16),
          Text(value, style: AppTextStyles.h2.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.bodySecondary),
        ],
      ),
    );
  }
}

class _LotCard extends StatelessWidget {
  final Map<String, dynamic> lot;
  final VoidCallback onValidate;

  const _LotCard({required this.lot, required this.onValidate});

  @override
  Widget build(BuildContext context) {
    final isFraud = lot['status'] == 'FRAUD_ALERT';
    return PremiumCard(
      border: isFraud
          ? const Border(
              left: BorderSide(color: AppColors.rougeErreur, width: 4),
            )
          : null,
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
                lot['lotId'],
                style: AppTextStyles.hash.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              _StatusBadge(status: lot['status']),
            ],
          ),
          const SizedBox(height: 16),
          Text(lot['farmerName'], style: AppTextStyles.h3),
          const SizedBox(height: 6),
          Text(
            '${lot['cultureType']} - ${lot['weightDeclared'].toInt()} kg declares'
            '${lot['weightVerified'] > 0 ? ' - ${lot['weightVerified'].toInt()} kg verifies' : ''}',
            style: AppTextStyles.bodySecondary,
          ),
          if (isFraud) ...[
            const SizedBox(height: 16),
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
                  const Icon(
                    Icons.warning_amber_outlined,
                    color: AppColors.rougeErreur,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ecart de ${(lot['weightDeclared'] - lot['weightVerified']).toInt()} kg detecte - verification requise',
                      style: AppTextStyles.bodySecondary.copyWith(
                        color: AppColors.rougeErreur,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.schedule, color: AppColors.grisTexte, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lot['registeredAt'],
                  style: AppTextStyles.bodySecondary,
                ),
              ),
              if (lot['status'] == 'REGISTERED' ||
                  lot['status'] == 'FRAUD_ALERT')
                SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    onPressed: onValidate,
                    child: const Text('Valider ce lot'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'VALIDATED' => (AppColors.vertFeuille, 'Valide'),
      'FRAUD_ALERT' => (AppColors.rougeErreur, 'Alerte fraude'),
      'IN_TRANSFER' => (AppColors.bleuTransit, 'En transit'),
      _ => (AppColors.orangeAlerte, 'En attente'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySecondary.copyWith(
          color: AppColors.blanc,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProductionChart extends StatelessWidget {
  final List<_ProductionPoint> points;

  const _ProductionChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final total = points.fold<int>(0, (sum, point) => sum + point.kg);
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Production hebdomadaire', style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text(
                    'Volume collecte sur les 7 derniers jours',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
              Text(
                '$total kg',
                style: AppTextStyles.h2.copyWith(color: AppColors.vertFeuille),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              builder: (context, progress, _) {
                return CustomPaint(
                  painter: _ProductionChartPainter(points, progress),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductionPoint {
  final String label;
  final int kg;

  const _ProductionPoint(this.label, this.kg);
}

class _ProductionChartPainter extends CustomPainter {
  final List<_ProductionPoint> points;
  final double progress;

  _ProductionChartPainter(this.points, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = const Color(0xFFE0D5C8)
      ..strokeWidth = 1;
    final barPaint = Paint()
      ..color = AppColors.orChaud
      ..style = PaintingStyle.fill;
    final highlightPaint = Paint()
      ..color = AppColors.vertFeuille
      ..style = PaintingStyle.fill;
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    const bottom = 32.0;
    const top = 12.0;
    final chartHeight = size.height - bottom - top;
    final maxKg = points
        .map((point) => point.kg)
        .reduce((a, b) => a > b ? a : b);
    final gap = size.width / points.length;
    canvas.drawLine(
      Offset(0, size.height - bottom),
      Offset(size.width, size.height - bottom),
      axisPaint,
    );

    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final barHeight = (point.kg / maxKg) * chartHeight * progress;
      final left = gap * index + gap * 0.24;
      final width = gap * 0.52;
      final topY = size.height - bottom - barHeight;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, topY, width, barHeight),
        const Radius.circular(8),
      );
      canvas.drawRRect(rect, index == 5 ? highlightPaint : barPaint);

      textPainter.text = TextSpan(
        text: point.label,
        style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
      );
      textPainter.layout(maxWidth: gap);
      textPainter.paint(
        canvas,
        Offset(gap * index + (gap - textPainter.width) / 2, size.height - 22),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProductionChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.points != points;
  }
}
