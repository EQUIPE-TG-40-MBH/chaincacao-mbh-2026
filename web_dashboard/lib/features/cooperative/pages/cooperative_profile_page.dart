import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_client.dart';

class CooperativeProfilePage extends StatefulWidget {
  final EntityAccount? account;
  const CooperativeProfilePage(
      {super.key, required this.account});

  @override
  State<CooperativeProfilePage> createState() =>
      _CooperativeProfilePageState();
}

class _CooperativeProfilePageState
    extends State<CooperativeProfilePage> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _editing = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _regionCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final coopId =
        widget.account?.registrationId ?? 'COOP-TG-001';
    final data = await ApiClient.getCooperativeProfile(coopId);
    if (data != null) {
      setState(() {
        _profile = data;
        _loading = false;
        _nameCtrl = TextEditingController(text: data['name'] ?? '');
        _regionCtrl = TextEditingController(text: data['region'] ?? '');
        _emailCtrl = TextEditingController(text: data['contact_email'] ?? '');
        _phoneCtrl = TextEditingController(text: data['contact_phone'] ?? '');
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final coopId =
        widget.account?.registrationId ?? 'COOP-TG-001';
    final success = await ApiClient.updateCooperativeProfile(
      coopId,
      name: _nameCtrl.text,
      region: _regionCtrl.text,
      contactEmail: _emailCtrl.text,
      contactPhone: _phoneCtrl.text,
    );

    if (success) {
      setState(() => _editing = false);
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis a jour'),
            backgroundColor: AppColors.vertFeuille,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(
              color: AppColors.orChaud));
    }
    final isMobile =
        MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _editing ? _buildEditForm() : _buildInfos(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.orChaud,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                (_profile?['name'] ?? 'C')[0]
                    .toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _profile?['name'] ?? 'Cooperative',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _profile?['cooperative_id'] ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.orChaud
                        .withOpacity(0.2),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_profile?['farmers_count'] ?? 0} agriculteurs',
                    style: const TextStyle(
                      color: AppColors.orVif,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                setState(() => _editing = !_editing),
            icon: Icon(
              _editing ? Icons.close : Icons.edit,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfos() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _InfoTile(Icons.badge, 'Identifiant', _profile?['cooperative_id'] ?? 'N/A'),
          _InfoTile(Icons.business, 'Nom officiel', _profile?['name'] ?? 'N/A'),
          _InfoTile(Icons.map, 'Region', _profile?['region'] ?? 'N/A'),
          _InfoTile(Icons.email, 'Email', _profile?['contact_email'] ?? 'N/A'),
          _InfoTile(Icons.phone, 'Telephone', _profile?['contact_phone'] ?? 'N/A'),
          _InfoTile(Icons.calendar_today, 'Membre depuis', (_profile?['created_at'] ?? '').toString().split('T').first, isLast: true),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.orChaud.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Modifier le profil',
              style: AppTextStyles.h2),
          const SizedBox(height: 24),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Nom officiel',
              prefixIcon:
                  const Icon(Icons.business_outlined),
              border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _regionCtrl,
            decoration: InputDecoration(
              labelText: 'Region',
              prefixIcon:
                  const Icon(Icons.map_outlined),
              border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailCtrl,
            decoration: InputDecoration(
              labelText: 'Email de contact',
              prefixIcon:
                  const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneCtrl,
            decoration: InputDecoration(
              labelText: 'Telephone',
              prefixIcon:
                  const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      setState(() => _editing = false),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoTile(this.icon, this.label, this.value,
      {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                    color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.orChaud.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(icon, color: AppColors.orChaud, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.bodySecondary
                        .copyWith(fontSize: 11)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.cacao,
                      fontSize: 15,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}