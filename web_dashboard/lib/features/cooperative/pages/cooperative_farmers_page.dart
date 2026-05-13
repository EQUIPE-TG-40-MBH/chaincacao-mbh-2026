import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_client.dart';

class CooperativeFarmersPage extends StatefulWidget {
  final EntityAccount? account;
  const CooperativeFarmersPage({super.key, required this.account});

  @override
  State<CooperativeFarmersPage> createState() =>
      _CooperativeFarmersPageState();
}

class _CooperativeFarmersPageState
    extends State<CooperativeFarmersPage> {
  List<Map<String, dynamic>> _farmers = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final coopId =
        widget.account?.registrationId ?? 'COOP-TG-001';
    final data = await ApiClient.getFarmers(cooperativeId: coopId);
    if (mounted) setState(() { _farmers = data; _loading = false; });
  }

  List<Map<String, dynamic>> get _filtered {
    if (_search.isEmpty) return _farmers;
    final q = _search.toLowerCase();
    return _farmers.where((f) {
      final name =
          '${f['first_name']} ${f['last_name']}'.toLowerCase();
      final phone = (f['phone'] ?? '').toLowerCase();
      final village = (f['village'] ?? '').toLowerCase();
      return name.contains(q) ||
          phone.contains(q) ||
          village.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return _loading
        ? const Center(
            child: CircularProgressIndicator(
                color: AppColors.orChaud))
        : SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText:
                              'Rechercher un agriculteur...',
                          prefixIcon:
                              const Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (v) =>
                            setState(() => _search = v),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _showFarmerDialog(context),
                      icon: const Icon(Icons.person_add),
                      label: const Text('Ajouter'),
                      style: ElevatedButton.styleFrom(
                          minimumSize:
                              const Size(140, 52)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_filtered.isEmpty)
                  _buildEmpty()
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : 2,
                      childAspectRatio:
                          isMobile ? 2.2 : 1.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _FarmerCard(
                      farmer: _filtered[i],
                      onView: () => _showProfile(
                          context, _filtered[i]),
                      onEdit: () => _showFarmerDialog(
                          context,
                          farmer: _filtered[i]),
                      onDelete: () =>
                          _delete(_filtered[i]),
                      onQR: () =>
                          _showQR(context, _filtered[i]),
                    ),
                  ),
              ],
            ),
          );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.people_outline,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Aucun agriculteur',
                style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text(
                'Commencez par ajouter vos premiers membres',
                style: AppTextStyles.bodySecondary),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showFarmerDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un agriculteur'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfile(
      BuildContext context, Map<String, dynamic> farmer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.orChaud,
              child: Text(
                (farmer['first_name'] ?? 'A')[0]
                    .toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Text(
                '${farmer['first_name']} ${farmer['last_name']}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _ProfileRow(Icons.badge, 'ID',
                  farmer['farmer_id'] ?? 'N/A'),
              _ProfileRow(Icons.phone, 'Telephone',
                  farmer['phone'] ?? 'N/A'),
              _ProfileRow(Icons.location_on, 'Village',
                  farmer['village'] ?? 'N/A'),
              _ProfileRow(Icons.map, 'Region',
                  farmer['region'] ?? 'N/A'),
              _ProfileRow(Icons.language, 'Langue',
                  farmer['language'] ?? 'fr'),
              _ProfileRow(Icons.gps_fixed, 'GPS',
                  farmer['gps_coordinates'] ?? 'N/A'),
              _ProfileRow(Icons.inventory_2, 'Lots',
                  '${farmer['lots_count'] ?? 0} lots'),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fermer')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _showFarmerDialog(context, farmer: farmer);
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _showQR(
      BuildContext context, Map<String, dynamic> farmer) {
    showDialog(
      context: context, // Utilisation de l'ApiClient.serverUrl
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('QR Code - ${farmer['farmer_id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (farmer['qr_code'] != null)
              Image.network(
                '${ApiClient.serverUrl}${farmer['qr_code']}',
                width: 200,
                height: 200,
                errorBuilder: (_, __, ___) => Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey.shade100,
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code,
                          size: 80,
                          color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(farmer['farmer_id'] ?? '',
                          style:
                              AppTextStyles.bodySecondary),
                    ],
                  ),
                ),
              )
            else
              Container(
                width: 200,
                height: 200,
                color: Colors.grey.shade100,
                child: Center(
                  child: Icon(Icons.qr_code,
                      size: 80,
                      color: Colors.grey.shade400),
                ),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.creme,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                farmer['farmer_id'] ?? '',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fermer')),
        ],
      ),
    );
  }

  void _showFarmerDialog(BuildContext context,
      {Map<String, dynamic>? farmer}) {
    final isEdit = farmer != null;
    final firstNameCtrl = TextEditingController(
        text: farmer?['first_name'] ?? '');
    final lastNameCtrl = TextEditingController(
        text: farmer?['last_name'] ?? '');
    final phoneCtrl =
        TextEditingController(text: farmer?['phone'] ?? '');
    final villageCtrl = TextEditingController(
        text: farmer?['village'] ?? '');
    final regionCtrl = TextEditingController(
        text: farmer?['region'] ?? 'Plateaux');
    String language = farmer?['language'] ?? 'fr';
    double lat =
        (farmer?['gps_latitude'] as num?)?.toDouble() ??
            6.8913;
    double lng =
        (farmer?['gps_longitude'] as num?)?.toDouble() ??
            0.6502;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text(isEdit
              ? 'Modifier agriculteur'
              : 'Ajouter un agriculteur'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: firstNameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Prenom',
                          prefixIcon:
                              Icon(Icons.person_outline)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: lastNameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Nom'),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Telephone',
                    hintText: '+228 90 00 00 00',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: villageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Village',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: regionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Region',
                    prefixIcon: Icon(Icons.map_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: language,
                  decoration: const InputDecoration(
                    labelText: 'Langue preferee',
                    prefixIcon: Icon(Icons.language),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'fr',
                        child: Text('Francais')),
                    DropdownMenuItem(
                        value: 'ewe',
                        child: Text('Ewe')),
                    DropdownMenuItem(
                        value: 'kabiye',
                        child: Text('Kabiye')),
                  ],
                  onChanged: (v) =>
                      setLocal(() => language = v ?? 'fr'),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.gps_fixed,
                        color: lat != 0
                            ? AppColors.vertFeuille
                            : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'GPS: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                          style: AppTextStyles.bodySecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => setLocal(() {
                          lat = 6.8913;
                          lng = 0.6502;
                        }),
                        child: const Text('Capturer'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                if (firstNameCtrl.text.isEmpty ||
                    phoneCtrl.text.isEmpty) return;
                final coopId =
                    widget.account?.registrationId ??
                        'COOP-TG-001';
                if (isEdit) {
                  await ApiClient.updateFarmer(
                    farmer!['id'],
                    firstName: firstNameCtrl.text,
                    lastName: lastNameCtrl.text,
                    phone: phoneCtrl.text,
                    cooperativeId: coopId,
                    gpsLatitude: lat,
                    gpsLongitude: lng,
                    region: regionCtrl.text,
                    village: villageCtrl.text,
                  );
                } else {
                  await ApiClient.createFarmer(
                    firstName: firstNameCtrl.text,
                    lastName: lastNameCtrl.text,
                    phone: phoneCtrl.text,
                    cooperativeId: coopId,
                    gpsLatitude: lat,
                    gpsLongitude: lng,
                    region: regionCtrl.text,
                    village: villageCtrl.text,
                  );
                }
                if (mounted) {
                  Navigator.pop(ctx);
                  _load();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(
                    content: Text(isEdit
                        ? 'Agriculteur mis a jour'
                        : 'Agriculteur ajoute avec succes'),
                    backgroundColor: AppColors.vertFeuille,
                  ));
                }
              },
              child:
                  Text(isEdit ? 'Enregistrer' : 'Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(Map<String, dynamic> farmer) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cet agriculteur ?'),
        content: Text(
            '${farmer['first_name']} ${farmer['last_name']} sera supprime definitivement.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rougeErreur),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ApiClient.deleteFarmer(farmer['id']);
    if (mounted) {
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agriculteur supprime'),
          backgroundColor: AppColors.rougeErreur,
        ),
      );
    }
  }
}

class _FarmerCard extends StatelessWidget {
  final Map<String, dynamic> farmer;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onQR;

  const _FarmerCard({
    required this.farmer,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onQR,
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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    AppColors.orChaud.withOpacity(0.15),
                child: Text(
                  (farmer['first_name'] ?? 'A')[0]
                      .toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.orChaud,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${farmer['first_name']} ${farmer['last_name']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.cacao,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      farmer['farmer_id'] ?? '',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.orChaud,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.phone,
                  size: 14, color: AppColors.grisTexte),
              const SizedBox(width: 6),
              Text(farmer['phone'] ?? 'N/A',
                  style: AppTextStyles.bodySecondary),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on,
                  size: 14, color: AppColors.grisTexte),
              const SizedBox(width: 6),
              Text(farmer['village'] ?? 'N/A',
                  style: AppTextStyles.bodySecondary),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              _ActionBtn(
                icon: Icons.visibility_outlined,
                label: 'Voir',
                color: AppColors.bleuTransit,
                onTap: onView,
              ),
              const SizedBox(width: 8),
              _ActionBtn(
                icon: Icons.qr_code,
                label: 'QR',
                color: AppColors.orChaud,
                onTap: onQR,
              ),
              const SizedBox(width: 8),
              _ActionBtn(
                icon: Icons.edit_outlined,
                label: 'Edit',
                color: AppColors.vertFeuille,
                onTap: onEdit,
              ),
              const SizedBox(width: 8),
              _ActionBtn(
                icon: Icons.delete_outline,
                label: 'Suppr.',
                color: AppColors.rougeErreur,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.orChaud),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.bodySecondary
                      .copyWith(fontSize: 11)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.cacao)),
            ],
          ),
        ],
      ),
    );
  }
}