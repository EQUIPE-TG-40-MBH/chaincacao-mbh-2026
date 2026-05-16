import 'package:flutter/material.dart';
import '../../core/services/mvp_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class VerifierPage extends StatefulWidget {
  const VerifierPage({super.key});

  @override
  State<VerifierPage> createState() => _VerifierPageState();
}

class _VerifierPageState extends State<VerifierPage> {
  final _controller = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;
  bool _notFound = false;

  final Map<String, Map<String, dynamic>> _demoLots = {
    'TG-2026-0471': {
      'lotId': 'TG-2026-0471',
      'farmerName': 'Koami Agbeko',
      'cooperativeName': 'CAPRK Kpalimé',
      'exporterName': 'ChainCacao Export SARL',
      'cultureType': 'Cacao',
      'weightDeclared': 250,
      'weightVerified': 242,
      'gps': '6.8913° N, 0.6502° E',
      'region': 'Plateaux, Togo',
      'blockchainHash': '0x72c5B32758000C6B6CbA364Cb4ef53aEF92948dc',
      'eudrCertified': true,
      'history': [
        {
          'step': 'Enregistrement',
          'actor': 'Koami Agbeko',
          'date': '09 Mai 2026 - 08:32',
          'status': 'done',
        },
        {
          'step': 'Réception coopérative',
          'actor': 'CAPRK Kpalimé',
          'date': '09 Mai 2026 - 10:15',
          'status': 'done',
        },
        {
          'step': 'Transfert exportateur',
          'actor': 'ChainCacao Export SARL',
          'date': '09 Mai 2026 - 14:30',
          'status': 'done',
        },
        {
          'step': 'Certificat EUDR émis',
          'actor': 'ChainCacao Export SARL',
          'date': '09 Mai 2026 - 14:32',
          'status': 'done',
        },
      ],
    },
    'TG-2026-0468': {
      'lotId': 'TG-2026-0468',
      'farmerName': 'Mensah Koffi',
      'cooperativeName': 'CAPRK Kpalimé',
      'exporterName': 'ChainCacao Export SARL',
      'cultureType': 'Café',
      'weightDeclared': 180,
      'weightVerified': 178,
      'gps': '6.8945° N, 0.6521° E',
      'region': 'Plateaux, Togo',
      'blockchainHash': '0x4D8E2A11...C93f',
      'eudrCertified': true,
      'history': [
        {
          'step': 'Enregistrement',
          'actor': 'Mensah Koffi',
          'date': '08 Mai 2026 - 16:45',
          'status': 'done',
        },
        {
          'step': 'Réception coopérative',
          'actor': 'CAPRK Kpalimé',
          'date': '08 Mai 2026 - 18:00',
          'status': 'done',
        },
        {
          'step': 'Certificat EUDR émis',
          'actor': 'ChainCacao Export SARL',
          'date': '09 Mai 2026 - 09:00',
          'status': 'done',
        },
      ],
    },
  };

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _result = null;
      _notFound = false;
    });
    await Future.delayed(const Duration(seconds: 1));
    final id = _controller.text.trim().toUpperCase();
    final lot = await MvpStore.getLot(id) ?? _demoLots[id];
    setState(() {
      _loading = false;
      _result = lot;
      _notFound = lot == null;
    });
  }

  Widget _buildHistoryStep(Map<String, dynamic> step, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.vertFeuille,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.check, color: AppColors.blanc, size: 18),
            ),
            if (!isLast)
              Container(width: 2, height: 40, color: AppColors.vertFeuille),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step['step'],
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(step['actor'], style: AppTextStyles.bodySecondary),
                Text(
                  step['date'],
                  style: AppTextStyles.bodySecondary.copyWith(
                    color: AppColors.grisTexte,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final lot = _result!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge vérifié
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.vertFeuille),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.verified,
                color: AppColors.vertFeuille,
                size: 32,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LOT VÉRIFIÉ ✓',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.vertFeuille,
                    ),
                  ),
                  Text(lot['lotId'], style: AppTextStyles.hash),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Infos du lot
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.blanc,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Informations du lot', style: AppTextStyles.h2),
              const Divider(height: 24),
              _buildInfoRow('🌱 Agriculteur', lot['farmerName']),
              _buildInfoRow('📍 Localisation', '${lot['region']}'),
              _buildInfoRow('🗺 GPS', lot['gps']),
              _buildInfoRow('🍫 Culture', lot['cultureType']),
              _buildInfoRow('⚖ Poids déclaré', '${lot['weightDeclared']} kg'),
              _buildInfoRow('✅ Poids vérifié', '${lot['weightVerified']} kg'),
              _buildInfoRow('🏭 Coopérative', lot['cooperativeName']),
              _buildInfoRow('🚢 Exportateur', lot['exporterName']),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Historique blockchain
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.blanc,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Historique blockchain', style: AppTextStyles.h2),
              const SizedBox(height: 16),
              ...(lot['history'] as List).asMap().entries.map(
                (e) => _buildHistoryStep(
                  e.value,
                  e.key == (lot['history'] as List).length - 1,
                ),
              ),
              const Divider(height: 24),
              Text(
                'Hash de transaction',
                style: AppTextStyles.bodySecondary.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(lot['blockchainHash'], style: AppTextStyles.hash),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Voir sur Polygonscan →',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.bleuTransit,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // EUDR
        if (lot['eudrCertified'] == true)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: const Border(
                left: BorderSide(color: AppColors.vertFeuille, width: 4),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user,
                  color: AppColors.vertFeuille,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Certificat EUDR émis — Ce lot est conforme au Règlement UE 2023/1115 sur la déforestation',
                    style: AppTextStyles.bodySecondary.copyWith(
                      color: AppColors.vertFeuille,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),

        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rapport EUDR téléchargé'),
                backgroundColor: AppColors.vertFeuille,
              ),
            );
          },
          icon: const Icon(Icons.download),
          label: const Text('Télécharger le rapport EUDR'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
    return Scaffold(
      appBar: AppBar(title: const Text('ChainCacao — Vérification publique')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vérifier un lot', style: AppTextStyles.h2),
            const SizedBox(height: 4),
            Text(
              'Entrez l\'ID du lot pour voir son historique complet. Aucun compte requis.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 24),

            // Champ de recherche
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Ex: TG-2026-0471',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _controller.text.isEmpty || _loading ? null : _search,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.blanc,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Vérifier'),
            ),
            const SizedBox(height: 24),

            // Lot non trouvé
            if (_notFound)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(
                    left: BorderSide(color: AppColors.rougeErreur, width: 4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.rougeErreur,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Lot non trouvé. Vérifiez l\'ID saisi.',
                      style: AppTextStyles.bodySecondary.copyWith(
                        color: AppColors.rougeErreur,
                      ),
                    ),
                  ],
                ),
              ),

            // Résultat
            if (_result != null) _buildResult(),
          ],
        ),
      ),
    );
  }
}
