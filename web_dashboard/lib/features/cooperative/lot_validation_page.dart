import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/api_client.dart';
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
  String? _rangeError;
  EntityAccount? _account;

  bool get _hasFraud {
    final declared = (widget.lot['weight_declared'] as num?)?.toDouble() ?? 0.0;
    final verified = double.tryParse(_weightController.text) ?? 0;
    if (verified == 0) return false;
    final diff = declared > 0 ? ((declared - verified) / declared).abs() : 0.0;
    return diff > 0.05;
  }

  Future<void> _validate() async {
    final verified = double.tryParse(_weightController.text) ?? 0;
    if (verified < 1 || verified > 500) {
      setState(() {
        _rangeError =
            'Ce poids semble inhabituel. Confirmez une valeur entre 1 kg et 500 kg.';
      });
      return;
    }

    setState(() => _loading = true);
    final result = await ApiClient.transferLot(
      lotId: widget.lot['lot_id'],
      weightVerified: verified,
      fromActor: widget.lot['farmer_name'] ?? 'PRODUCTEUR',
      toActor: _account?.entityName ?? 'COOPERATIVE',
      notes: _hasFraud ? 'Alerte fraude: écart de poids constaté.' : 'Réception conforme.',
    );

    if (!mounted) return;
    if (result != null) {
    setState(() {
      _loading = false;
      _validated = true;
      _flash = true;
        _hash = result['blockchain_hash'];
      _rangeError = null;
    });
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _flash = false);
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la validation sur le serveur')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    AuthService.currentAccount().then((account) { // Récupérer le compte pour l'acteur
      if (mounted) setState(() => _account = account);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lot = widget.lot;
    return PopScope(
      canPop: _validated || _weightController.text.isEmpty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _validated || _weightController.text.isEmpty) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quitter la validation ?'),
            content: const Text(
              'Un poids a ete saisi mais le lot n est pas encore valide.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Rester'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Quitter'),
              ),
            ],
          ),
        );
        if (leave == true && context.mounted) Navigator.pop(context);
      },
      child: Stack(
        children: [
          DashboardShell(
            currentRoute: '/cooperative',
            pageTitle: _validated ? 'Lot valide' : 'Validation du lot',
            pageSubtitle: '${lot['lot_id']} - controle de reception cooperative',
            userName: _account?.entityName ?? 'Cooperative',
            userRole: _account?.roleLabel ?? 'Cooperative',
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
                      rangeError: _rangeError,
                      loading: _loading,
                      onChanged: () => setState(() => _rangeError = null),
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
      ),
    );
  }
}

class _ValidationForm extends StatelessWidget {
  final Map<String, dynamic> lot;
  final TextEditingController weightController;
  final bool hasFraud;
  final String? rangeError;
  final bool loading;
  final VoidCallback onChanged;
  final VoidCallback onValidate;

  const _ValidationForm({
    super.key,
    required this.lot,
    required this.weightController,
    required this.hasFraud,
    required this.rangeError,
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
          rangeError: rangeError,
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fiche du lot', style: AppTextStyles.h2),
          const Divider(height: 32),
          _InfoRow('ID Lot', lot['lot_id']),
          _InfoRow('Agriculteur', lot['farmer_name']),
          _InfoRow('Culture', lot['culture_type']),
          _InfoRow('Poids declare', '${lot['weight_declared']} kg'),
          _InfoRow('GPS',
              '${lot['gps_latitude']?.toStringAsFixed(4)}, ${lot['gps_longitude']?.toStringAsFixed(4)}'),
          _InfoRow('Enregistre le', lot['registered_at']),
          _InfoRow('Hash blockchain',
              lot['blockchain_hash'] != null ? '${lot['blockchain_hash'].toString().substring(0, 10)}...' : 'En attente'),
        ],
      ),
    );
  }
}

class _WeightFormCard extends StatelessWidget {
  final TextEditingController weightController;
  final bool hasFraud;
  final String? rangeError;
  final bool loading;
  final VoidCallback onChanged;
  final VoidCallback onValidate;

  const _WeightFormCard({
    required this.weightController,
    required this.hasFraud,
    required this.rangeError,
    required this.loading,
    required this.onChanged,
    required this.onValidate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
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
            style: const TextStyle(fontWeight: FontWeight.w600),
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
            child: rangeError != null
                ? Padding(
                    key: const ValueKey('range'),
                    padding: const EdgeInsets.only(top: 16),
                    child: _AlertBox(
                      color: AppColors.orangeAlerte,
                      text: rangeError!,
                    ),
                  )
                : hasFraud
                ? Padding(
                    key: const ValueKey('fraud'),
                    padding: const EdgeInsets.only(top: 16),
                    child: _AlertBox(
                      color: AppColors.rougeErreur,
                      text:
                          'Alerte fraude detectee - ecart superieur a 5% entre poids declare et poids verifie.',
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

class _AlertBox extends StatelessWidget {
  final Color color;
  final String text;

  const _AlertBox({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color == AppColors.rougeErreur
            ? const Color(0xFFFEF2F2)
            : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_outlined, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySecondary.copyWith(color: color),
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
