import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/dashboard_shell.dart';

class LotValidationPage extends StatefulWidget {
  final Map<String, dynamic> lot;

  const LotValidationPage({super.key, required this.lot});

  @override
  State<LotValidationPage> createState() => _LotValidationPageState();
}

class _LotValidationPageState extends State<LotValidationPage> {
  final _weightController = TextEditingController();
  bool _validated = false;
  bool _loading = false;
  bool _flash = false;
  String? _hash;

  bool get _hasFraud {
    final declared = widget.lot['weightDeclared'] as double;
    final verified = double.tryParse(_weightController.text) ?? 0;
    if (verified == 0) return false;
    final diff = ((declared - verified) / declared).abs();
    return diff > 0.05;
  }

  Future<void> _validate() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _validated = true;
      _flash = true;
      _hash = '0x72c5B32758000C6B6CbA364Cb4ef53aEF92948dc';
    });
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _flash = false);
  }

  @override
  Widget build(BuildContext context) {
    final lot = widget.lot;
    return Stack(
      children: [
        DashboardShell(
          currentRoute: '/cooperative',
          pageTitle: _validated ? 'Lot valide' : 'Validation du lot',
          pageSubtitle: '${lot['lotId']} - controle de reception cooperative',
          userName: 'CAPRK Kpalime',
          userRole: 'Cooperative',
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
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.ease,
            child: _validated
                ? _SuccessView(hash: _hash ?? '')
                : _ValidationForm(
                    key: const ValueKey('form'),
                    lot: lot,
                    weightController: _weightController,
                    hasFraud: _hasFraud,
                    loading: _loading,
                    onChanged: () => setState(() {}),
                    onValidate: _validate,
                  ),
          ),
        ),
        IgnorePointer(
          child: AnimatedOpacity(
            opacity: _flash ? 0.22 : 0,
            duration: const Duration(milliseconds: 300),
            child: Container(color: AppColors.vertFeuille),
          ),
        ),
      ],
    );
  }
}

class _ValidationForm extends StatelessWidget {
  final Map<String, dynamic> lot;
  final TextEditingController weightController;
  final bool hasFraud;
  final bool loading;
  final VoidCallback onChanged;
  final VoidCallback onValidate;

  const _ValidationForm({
    super.key,
    required this.lot,
    required this.weightController,
    required this.hasFraud,
    required this.loading,
    required this.onChanged,
    required this.onValidate,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 900;
        final details = _LotDetailsCard(lot: lot);
        final form = _WeightFormCard(
          weightController: weightController,
          hasFraud: hasFraud,
          loading: loading,
          onChanged: onChanged,
          onValidate: onValidate,
        );

        if (!twoColumns) {
          return Column(
            children: [
              AnimatedAppear(index: 0, child: details),
              const SizedBox(height: 24),
              AnimatedAppear(index: 1, child: form),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: AnimatedAppear(index: 0, child: details)),
            const SizedBox(width: 24),
            Expanded(child: AnimatedAppear(index: 1, child: form)),
          ],
        );
      },
    );
  }
}

class _LotDetailsCard extends StatelessWidget {
  final Map<String, dynamic> lot;

  const _LotDetailsCard({required this.lot});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fiche du lot', style: AppTextStyles.h2),
          const Divider(height: 32),
          _InfoRow('ID Lot', lot['lotId']),
          _InfoRow('Agriculteur', lot['farmerName']),
          _InfoRow('Culture', lot['cultureType']),
          _InfoRow('Poids declare', '${lot['weightDeclared'].toInt()} kg'),
          _InfoRow('GPS', lot['gps']),
          _InfoRow('Enregistre le', lot['registeredAt']),
          _InfoRow('Hash blockchain', lot['blockchainHash']),
        ],
      ),
    );
  }
}

class _WeightFormCard extends StatelessWidget {
  final TextEditingController weightController;
  final bool hasFraud;
  final bool loading;
  final VoidCallback onChanged;
  final VoidCallback onValidate;

  const _WeightFormCard({
    required this.weightController,
    required this.hasFraud,
    required this.loading,
    required this.onChanged,
    required this.onValidate,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Controle de reception', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            'Saisissez le poids reel pese avant validation blockchain.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 24),
          Text(
            'Poids verifie a la cooperative',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(
              hintText: 'Entrez le poids reel pese',
              suffixText: 'kg',
              prefixIcon: Icon(Icons.scale_outlined),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: hasFraud
                ? Padding(
                    key: const ValueKey('fraud'),
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: const Border(
                          left: BorderSide(
                            color: AppColors.rougeErreur,
                            width: 4,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_outlined,
                            color: AppColors.rougeErreur,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Alerte fraude detectee - ecart superieur a 5% entre poids declare et poids verifie.',
                              style: AppTextStyles.bodySecondary.copyWith(
                                color: AppColors.rougeErreur,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: weightController.text.isEmpty || loading
                ? null
                : onValidate,
            icon: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.blanc,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.link),
            label: Text(
              loading
                  ? 'Validation en cours...'
                  : 'Valider le transfert sur blockchain',
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String hash;

  const _SuccessView({required this.hash});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: PremiumCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.vertFeuille,
                    borderRadius: BorderRadius.circular(44),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.blanc,
                    size: 52,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Lot valide !', style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Text(
                'Transaction enregistree sur la blockchain Polygon',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.creme,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hash de transaction',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(hash, style: AppTextStyles.hashBlockchain),
                    const SizedBox(height: 8),
                    Text(
                      'Voir sur Polygonscan',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.bleuTransit,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour au dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
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
}
