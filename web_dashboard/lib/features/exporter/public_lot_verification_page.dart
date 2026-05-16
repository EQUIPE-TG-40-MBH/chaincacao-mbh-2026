Lmport 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/api_client.dart';

class PublicLotVerificationPage extends StatefulWidget {
  final String? initialLotId;
  const PublicLotVerificationPage({super.key, this.initialLotId});

  @override
  State<PublicLotVerificationPage> createState() => _PublicLotVerificationPageState();
}

class _PublicLotVerificationPageState extends State<PublicLotVerificationPage> {
  final _controller = TextEditingController();
  Map<String, dynamic>? _lotData;
  bool _searching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialLotId != null) {
      _controller.text = widget.initialLotId!;
      _searchLot();
    }
  }

  Future<void> _searchLot() async {
    if (_controller.text.isEmpty) return;
    
    setState(() {
      _searching = true;
      _error = null;
      _lotData = null;
    });

    try {
      // Appel à l'endpoint public (sans token)
      final result = await ApiClient.getPublicLot(_controller.text);
      setState(() {
        _lotData = result;
        _searching = false;
      });
    } catch (e) {
      setState(() {
        _error = "Lot introuvable ou erreur réseau.";
        _searching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creme,
      appBar: AppBar(
        backgroundColor: AppColors.cacao,
        title: Text('Vérification Publique ChainCacao', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                Text('Transparence Blockchain', style: AppTextStyles.h1),
                const SizedBox(height: 12),
                Text(
                  'Saisissez l\'identifiant du lot pour voir son historique complet, du champ jusqu\'à l\'export.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 40),
                
                // Barre de recherche
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Ex: TGO-2026-00124',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onSubmitted: (_) => _searchLot(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _searching ? null : _searchLot,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orChaud,
                        minimumSize: const Size(120, 56),
                      ),
                      child: _searching 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Vérifier'),
                    ),
                  ],
                ),

                if (_error != null) ...[
                  const SizedBox(height: 32),
                  Text(_error!, style: TextStyle(color: AppColors.rougeErreur, fontWeight: FontWeight.bold)),
                ],

                if (_lotData != null) ...[
                  const SizedBox(height: 40),
                  _buildResultCard(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, color: AppColors.vertFeuille, size: 32),
              const SizedBox(width: 12),
              Text('Lot Vérifié', style: AppTextStyles.h2.copyWith(color: AppColors.vertFeuille)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.creme, borderRadius: BorderRadius.circular(20)),
                child: Text(_lotData!['status'] ?? 'N/A', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.cacao)),
              ),
            ],
          ),
          const Divider(height: 40),
          _infoRow('Origine', '${_lotData!['farmer_name']} - ${_lotData!['region']}'),
          _infoRow('Poids certifié', '${_lotData!['weight_verified']} kg'),
          _infoRow('Culture', _lotData!['culture_type']),
          _infoRow('Coordonnées GPS', '${_lotData!['gps_latitude']}, ${_lotData!['gps_longitude']}'),
          const SizedBox(height: 24),
          Text('Preuve Blockchain (Polygon)', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
            child: Text(
              _lotData!['blockchain_hash'] ?? 'Aucun hash disponible',
              style: AppTextStyles.hashBlockchain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(width: 150, child: Text(label, style: AppTextStyles.bodySecondary)),
          Expanded(child: Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}