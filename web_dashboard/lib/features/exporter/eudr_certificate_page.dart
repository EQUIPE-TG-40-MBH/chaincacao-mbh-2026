import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/api_client.dart';
import '../../core/services/pdf_service.dart';
import '../../core/widgets/dashboard_shell.dart';

class EudrCertificatePage extends StatefulWidget {
  final List<Map<String, dynamic>> lots;
  final double totalKg;

  const EudrCertificatePage({
    super.key,
    required this.lots,
    required this.totalKg,
  });

  @override
  State<EudrCertificatePage> createState() => _EudrCertificatePageState();
}

class _EudrCertificatePageState extends State<EudrCertificatePage> {
  bool _generating = false;
  bool _generated = false;
  final String _certId =
      'EUDR-TG-2026-${DateTime.now().millisecondsSinceEpoch}';

  Future<void> _generateCertificate() async {
    setState(() => _generating = true);
    await ChainCacaoPdfService.downloadEudrCertificate(
      certificateId: _certId,
      lots: widget.lots,
      totalKg: widget.totalKg,
    );

    final lotIds = widget.lots.map((l) => l['lot_id'] as String).toList();
    final result = await ApiClient.generateEudrCertificate(lotIds);

    if (result != null) {
    setState(() {
      _generating = false;
      _generated = true;
    });
    } else {
      setState(() => _generating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la génération du certificat')),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: AppTextStyles.bodySecondary.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.body)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      currentRoute: '/exportateur',
      pageTitle: 'Certificat EUDR',
      pageSubtitle: 'Conformite deforestation et tracabilite export',
      userName: 'ChainCacao Export',
      userRole: 'Exportateur',
      actions: [
        SizedBox(
          width: 180,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Retour'),
          ),
        ),
      ],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cacao,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Certificat de conformité EUDR',
                    style: AppTextStyles.h2.copyWith(color: AppColors.blanc),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Règlement UE 2023/1115 — Déforestation',
                    style: AppTextStyles.bodySecondary.copyWith(
                      color: AppColors.grisTexte,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Résumé du conteneur
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.blanc,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Informations du conteneur', style: AppTextStyles.h2),
                  const Divider(height: 24),
                  _buildInfoRow('ID Certificat', _certId),
                  _buildInfoRow('Date d\'émission', '09 Mai 2026'),
                  _buildInfoRow('Exportateur', 'ChainCacao Export SARL'),
                  _buildInfoRow('Pays d\'origine', 'Togo'),
                  _buildInfoRow('Nombre de lots', '${widget.lots.length} lots'),
                  _buildInfoRow('Poids total', '${widget.totalKg.toInt()} kg'),
                  _buildInfoRow('Destination', 'Union Européenne'),
                  _buildInfoRow('Produit', 'Cacao brut (HS 1801)'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Lots inclus
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.blanc,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lots inclus et traçabilité', style: AppTextStyles.h2),
                  const Divider(height: 24),
                  ...widget.lots.map(
                    (lot) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.creme,
                        borderRadius: BorderRadius.circular(8),
                        border: const Border(
                          left: BorderSide(
                            color: AppColors.vertFeuille,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lot['lot_id'],
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'JetBrainsMono',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${lot['farmer_name']} · ${lot['weight_verified'] ?? lot['weight_declared']} kg',
                            style: AppTextStyles.body,
                          ),
                          Text(
                            'GPS : ${lot['gps_latitude']}, ${lot['gps_longitude']}',
                            style: AppTextStyles.bodySecondary,
                          ),
                          Text(
                            'Hash : ${lot['blockchain_hash']}',
                            style: AppTextStyles.hash,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Déclaration légale
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: AppColors.vertFeuille, width: 4),
                ),
              ),
              child: Text(
                'Je soussigné certifie que les produits couverts par ce document ont été produits sans contribuer à la déforestation ni à la dégradation des forêts, conformément au Règlement (UE) 2023/1115.',
                style: AppTextStyles.bodySecondary.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bouton générer
            if (!_generated)
              ElevatedButton.icon(
                onPressed: _generating ? null : _generateCertificate,
                icon: _generating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.blanc,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf),
                label: Text(
                  _generating
                      ? 'Génération en cours...'
                      : 'Générer le PDF EUDR',
                ),
              ),

            // Succès
            if (_generated) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.vertFeuille),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.vertFeuille,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Certificat généré avec succès',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.vertFeuille,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Signé cryptographiquement · Enregistré sur Polygon',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          ChainCacaoPdfService.downloadEudrCertificate(
                            certificateId: _certId,
                            lots: widget.lots,
                            totalKg: widget.totalKg,
                          ),
                      icon: const Icon(Icons.download),
                      label: const Text('Télécharger le PDF'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Lien envoyé à l\'importateur européen',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Envoyer à l\'importateur'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        foregroundColor: AppColors.cacao,
                        side: const BorderSide(color: AppColors.orChaud),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
