import 'package:flutter/material.dart';
import '../../../core/services/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/auth_service.dart';

class CooperativePurchasesPage extends StatefulWidget {
  final EntityAccount? account;

  const CooperativePurchasesPage({super.key, required this.account});

  @override
  State<CooperativePurchasesPage> createState() => _CooperativePurchasesPageState();
}

class _CooperativePurchasesPageState extends State<CooperativePurchasesPage> {
  late Future<List<Map<String, dynamic>>> _farmers;
  late Future<List<Map<String, dynamic>>> _recentLots;
  final _formKey = GlobalKey<FormState>();
  int? _selectedFarmerId;
  String _cultureType = 'cacao';
  String _cultureVariety = 'Forastero';
  final _weightController = TextEditingController();
  final _dateController = TextEditingController();
  bool _isSubmitting = false;

  static const Map<String, List<String>> _varieties = {
    'cacao': ['Forastero', 'Criollo', 'Trinitario'],
    'cafe': ['Arabica', 'Robusta', 'Bourbon'],
  };

  @override
  void initState() {
    super.initState();
    final coopId = widget.account?.registrationId ?? 'COOP-TG-001';
    _farmers = ApiClient.getFarmers(cooperativeId: coopId); // Utilise ApiClient
    _recentLots = ApiClient.getLots();
    _dateController.text = DateTime.now().toString().split(' ')[0];
  }

  void _refreshLots() {
    setState(() {
      _recentLots = ApiClient.getLots();
    });
  }

  Future<void> _submitPurchase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedFarmerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez un agriculteur')), 
      );
      return;
    }
    setState(() => _isSubmitting = true);
    final coopId = widget.account?.registrationId ?? 'COOP-TG-001';
    final cultureLabel = '${_cultureType == 'cacao' ? 'Cacao' : 'Café'} - $_cultureVariety';
    final createdLot = await ApiClient.createLot(
      farmerId: _selectedFarmerId.toString(),
      cooperativeId: coopId,
      cultureType: cultureLabel,
      weightDeclared: double.parse(_weightController.text),
      gpsLatitude: 6.8913,
      gpsLongitude: 0.6502,
    );
    setState(() => _isSubmitting = false);
    if (createdLot != null) {
      _refreshLots();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Achat enregistré : ${createdLot['lot_id']}')),
      );
      _formKey.currentState?.reset();
      setState(() {
        _selectedFarmerId = null;
        _cultureType = 'cacao';
        _cultureVariety = 'Forastero';
        _weightController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’enregistrer l’achat')), 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Acheter chez un agriculteur', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text(
            'Saisissez un achat de café ou de cacao et suivez les achats récents.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 32),
          _buildPurchaseForm(isMobile),
          const SizedBox(height: 32),
          Text('Historique des achats', style: AppTextStyles.h2),
          const SizedBox(height: 16),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _recentLots,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}'));
              }
              final lots = snapshot.data ?? [];
              if (lots.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('Aucun achat enregistré.', style: AppTextStyles.bodySecondary),
                  ),
                );
              }
              final recent = lots.take(6).toList();
              return Column(
                children: recent.map((lot) => _PurchaseRow(lot: lot)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseForm(bool isMobile) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sélection agriculteur', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _farmers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              final farmers = snapshot.data ?? [];
              return DropdownButtonFormField<int?>(
                value: _selectedFarmerId,
                decoration: InputDecoration(
                  labelText: 'Agriculteur',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('-- Choisir --')),
                  ...farmers.map((farmer) {
                    return DropdownMenuItem<int?>(
                      value: farmer['id'],
                      child: Text('${farmer['first_name']} ${farmer['last_name']}'),
                    );
                  }),
                ],
                onChanged: (value) => setState(() => _selectedFarmerId = value),
                validator: (value) => value == null ? 'Sélectionnez un agriculteur' : null,
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Culture & variété', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: isMobile ? double.infinity : 260,
                child: DropdownButtonFormField<String>(
                  value: _cultureType,
                  decoration: InputDecoration(
                    labelText: 'Culture',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'cacao', child: Text('Cacao')),
                    DropdownMenuItem(value: 'cafe', child: Text('Café')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _cultureType = value;
                      _cultureVariety = _varieties[value]!.first;
                    });
                  },
                ),
              ),
              SizedBox(
                width: isMobile ? double.infinity : 260,
                child: DropdownButtonFormField<String>(
                  value: _cultureVariety,
                  decoration: InputDecoration(
                    labelText: 'Variété',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _varieties[_cultureType]!.map((variety) {
                    return DropdownMenuItem(value: variety, child: Text(variety));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _cultureVariety = value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: isMobile ? double.infinity : 240,
                child: TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantité (kg)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Saisissez une quantité';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Valeur invalide';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Le poids doit être supérieur à 0';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                width: isMobile ? double.infinity : 240,
                child: TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submitPurchase,
            icon: const Icon(Icons.shopping_cart_outlined),
            label: Text(_isSubmitting ? 'Enregistrement...' : 'Enregistrer l’achat'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseRow extends StatelessWidget {
  final Map<String, dynamic> lot;

  const _PurchaseRow({required this.lot});

  @override
  Widget build(BuildContext context) {
    final date = lot['created_at']?.toString().split('T').first ?? 'Date inconnue';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lot['lot_id'] ?? 'N/A', style: AppTextStyles.h3.copyWith(color: AppColors.cacao)),
                const SizedBox(height: 6),
                Text('${lot['farmer_name'] ?? 'Agriculteur inconnu'} • ${lot['culture_type'] ?? 'Culture inconnue'}', style: AppTextStyles.body),
                const SizedBox(height: 6),
                Text('${lot['weight_declared'] ?? '0'} kg', style: AppTextStyles.bodySecondary),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(date, style: AppTextStyles.bodySecondary),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.orChaud.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('Achat', style: AppTextStyles.body.copyWith(color: AppColors.orChaud)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
