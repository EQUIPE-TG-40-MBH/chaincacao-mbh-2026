import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_client.dart';

class CooperativeRegisterHarvestPage extends StatefulWidget {
  final EntityAccount? account;
  const CooperativeRegisterHarvestPage(
      {super.key, required this.account});

  @override
  State<CooperativeRegisterHarvestPage> createState() =>
      _CooperativeRegisterHarvestPageState();
}

class _CooperativeRegisterHarvestPageState
    extends State<CooperativeRegisterHarvestPage> {
  final _formKey = GlobalKey<FormState>();
  String _cultureType = 'cacao';
  String _variety = 'Forastero';
  final _weightCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  double _lat = 6.8913;
  double _lng = 0.6502;
  bool _gpsOk = false;
  bool _loading = false;
  String? _successLotId;
  String? _blockchainHash;

  static const _varieties = {
    'cacao': ['Forastero', 'Criollo', 'Trinitario'],
    'cafe': ['Arabica', 'Robusta', 'Bourbon'],
    'coton': ['Local'],
    'arachide': ['Local'],
    'mais': ['Local'],
  };

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = DateTime.now().toString().split(' ')[0];
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_gpsOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Capturez le GPS')),
      );
      return;
    }
    setState(() => _loading = true);
    final coopId =
        widget.account?.registrationId ?? 'COOP-TG-001';

    final result = await ApiClient.registerCooperativeHarvest(
      cooperativeId: coopId,
      weightDeclared: double.parse(_weightCtrl.text),
      cultureType: '$_cultureType - $_variety',
      gpsLatitude: _lat,
      gpsLongitude: _lng,
      harvestDate: _dateCtrl.text,
      notes: _notesCtrl.text,
    );

    if (result != null && mounted) {
      setState(() {
        _successLotId = result['lot']['lot_id'];
        _blockchainHash = result['blockchain_hash'];
        _loading = false;
      });
    } else if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'enregistrement de la récolte')),
      );
      }
  }

  void _reset() {
    setState(() {
      _successLotId = null;
      _blockchainHash = null;
      _weightCtrl.clear();
      _notesCtrl.clear();
      _gpsOk = false;
      _cultureType = 'cacao';
      _variety = 'Forastero';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: _successLotId != null
          ? _buildSuccess()
          : _buildForm(isMobile),
    );
  }

  Widget _buildSuccess() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.vertFeuille.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.vertFeuille.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle,
                color: AppColors.vertFeuille, size: 48),
          ),
          const SizedBox(height: 20),
          Text('Recolte enregistree !',
              style: AppTextStyles.h1
                  .copyWith(color: AppColors.vertFeuille)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.creme,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('Identifiant du lot',
                    style: AppTextStyles.bodySecondary),
                const SizedBox(height: 8),
                Text(
                  _successLotId!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cacao,
                    fontFamily: 'monospace',
                  ),
                ),
                if (_blockchainHash != null) ...[
                  const SizedBox(height: 12),
                  Text('Hash Blockchain',
                      style: AppTextStyles.bodySecondary),
                  const SizedBox(height: 4),
                  Text(
                    '${_blockchainHash!.substring(0, 10)}...${_blockchainHash!.substring(_blockchainHash!.length - 8)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.orChaud,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.add),
                  label: const Text('Nouvelle recolte'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isMobile) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.orChaud.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.orChaud.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppColors.orChaud),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cette recolte sera enregistree au nom de la cooperative, pas d\'un agriculteur individuel.',
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Type de culture', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _cultureType,
                  decoration: InputDecoration(
                    labelText: 'Culture',
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'cacao',
                        child: Text('Cacao')),
                    DropdownMenuItem(
                        value: 'cafe', child: Text('Cafe')),
                    DropdownMenuItem(
                        value: 'coton',
                        child: Text('Coton')),
                    DropdownMenuItem(
                        value: 'arachide',
                        child: Text('Arachide')),
                    DropdownMenuItem(
                        value: 'mais',
                        child: Text('Mais')),
                  ],
                  onChanged: (v) => setState(() {
                    _cultureType = v!;
                    _variety =
                        _varieties[v]?.first ?? 'Local';
                  }),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _variety,
                  decoration: InputDecoration(
                    labelText: 'Variete',
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10)),
                  ),
                  items: (_varieties[_cultureType] ?? ['Local'])
                      .map((v) => DropdownMenuItem(
                          value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _variety = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Poids (kg)', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          TextFormField(
            controller: _weightCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Poids declare en kg',
              prefixIcon: const Icon(Icons.scale),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            validator: (v) {
              if (v == null || v.isEmpty)
                return 'Entrez le poids';
              if (double.tryParse(v) == null)
                return 'Valeur invalide';
              final d = double.parse(v);
              if (d < 1 || d > 10000)
                return 'Poids inhabituel (1-10000 kg)';
              return null;
            },
          ),
          const SizedBox(height: 24),
          Text('Date de recolte', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          TextFormField(
            controller: _dateCtrl,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Date',
              prefixIcon:
                  const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (d != null) {
                _dateCtrl.text =
                    d.toString().split(' ')[0];
              }
            },
          ),
          const SizedBox(height: 24),
          Text('Notes (optionnel)',
              style: AppTextStyles.h3),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Qualite, conditions de recolte...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 24),
          Text('Localisation GPS',
              style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                  color: _gpsOk
                      ? AppColors.vertFeuille
                      : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
              color: _gpsOk
                  ? AppColors.vertFeuille.withOpacity(0.05)
                  : Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Icon(
                  _gpsOk
                      ? Icons.gps_fixed
                      : Icons.gps_not_fixed,
                  color: _gpsOk
                      ? AppColors.vertFeuille
                      : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _gpsOk
                        ? '${_lat.toStringAsFixed(4)}, ${_lng.toStringAsFixed(4)}'
                        : 'Position non capturee',
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => setState(() {
                    _lat = 6.8913;
                    _lng = 0.6502;
                    _gpsOk = true;
                  }),
                  icon: const Icon(Icons.my_location,
                      size: 16),
                  label: const Text('Capturer'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 40)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2))
                  : const Icon(Icons.agriculture),
              label: Text(_loading
                  ? 'Enregistrement...'
                  : 'Enregistrer et generer QR'),
            ),
          ),
        ],
      ),
    );
  }
}