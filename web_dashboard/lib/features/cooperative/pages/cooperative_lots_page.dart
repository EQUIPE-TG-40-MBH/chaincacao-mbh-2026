import 'dart:async';
import 'dart:convert';
import 'dart:html' as html; // Uniquement pour Flutter Web
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_client.dart';
import '../lot_validation_page.dart';

class CooperativeLotsPage extends StatefulWidget {
  final EntityAccount? account;

  const CooperativeLotsPage({super.key, required this.account});

  @override
  State<CooperativeLotsPage> createState() => _CooperativeLotsPageState();
}

class _CooperativeLotsPageState extends State<CooperativeLotsPage> {
  List<Map<String, dynamic>>? _cachedLots;
  String _filterStatus = 'all';
  String _searchQuery = '';
  bool _isRefreshing = false;
  bool _initialLoading = true;
  final _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadLots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _resetFilters() {
    _searchController.clear();
    _debounce?.cancel();
    setState(() {
      _filterStatus = 'all';
      _searchQuery = '';
      _selectedDateRange = null;
    });
  }

  /// Affiche les options d'export avant de générer le fichier
  void _showExportOptions(List<Map<String, dynamic>> lots) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Options d\'exportation CSV'),
        content: const Text(
          'Choisissez le niveau de détail souhaité pour votre rapport de traçabilité.'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showDeliveryOptions(lots, detailed: false); // Call new function
            },
            child: const Text('Simplifié'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showDeliveryOptions(lots, detailed: true); // Call new function
            },
            child: const Text('Détaillé (avec historique)'),
          ),
        ],
      ),
    );
  }

  /// Affiche les options d'export avant de générer le fichier
  void _showDeliveryOptions(List<Map<String, dynamic>> lots, {required bool detailed}) {
    final userEmail = widget.account?.email;
    final isEmailAvailable = userEmail != null && userEmail.isNotEmpty;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Méthode de livraison'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comment souhaitez-vous recevoir votre rapport CSV ?'
            ),
            if (!isEmailAvailable) ...[
              const SizedBox(height: 16),
              Text(
                'Votre adresse email n\'est pas configurée. Veuillez mettre à jour votre profil pour recevoir l\'export par email.',
                style: AppTextStyles.bodySecondary.copyWith(color: AppColors.rougeErreur),
              ),
            ],
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: isEmailAvailable ? () {
              Navigator.pop(ctx);
              _exportToEmail(detailed: detailed);
            } : null, // Désactiver si pas d'email
            icon: const Icon(Icons.email_outlined),
            label: const Text('Recevoir par email'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _exportToCSV(lots, detailed: detailed);
            },
            child: const Text('Télécharger'),
          ),
        ],
      ),
    );
  }

  /// Ouvre le sélecteur de plage de dates
  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: AppColors.orChaud, onPrimary: Colors.white, surface: Colors.white, onSurface: AppColors.cacao)),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDateRange = picked);
  }

  /// Envoie la demande d'export par email au serveur
  Future<void> _exportToEmail({required bool detailed}) async {
    final coopId = widget.account?.registrationId ?? '';
    if (coopId.isEmpty) return;

    setState(() => _isRefreshing = true);
    
    final result = await ApiClient.emailLotsCsv(
      detailed: detailed,
      cooperativeId: coopId,
      startDate: _selectedDateRange?.start.toIso8601String().split('T')[0],
      endDate: _selectedDateRange?.end.toIso8601String().split('T')[0],
    );

    if (mounted) {
      setState(() => _isRefreshing = false);
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Email envoyé avec succès'),
            backgroundColor: AppColors.vertFeuille,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'envoi de l\'email'),
            backgroundColor: AppColors.rougeErreur,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Exporte la liste actuelle des lots filtrés au format CSV
  void _exportToCSV(List<Map<String, dynamic>> lots, {required bool detailed}) {
    // Préparation de l'en-tête et des données
    final headers = [
      'ID Lot', 
      'Producteur', 
      'Culture', 
      'Poids Declare (kg)', 
      'Poids Verifie (kg)', 
      'Statut', 
      'Date', 
    ];

    if (detailed) headers.add('Historique des Transferts');

    final rows = lots.map((l) {
      // Formatage de la date pour Excel (AAAA-MM-JJ HH:mm:ss)
      String formattedDate = l['registered_at'] ?? '--';
      try {
        final dt = DateTime.tryParse(formattedDate);
        if (dt != null) {
          formattedDate = "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
              "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";
        }
      } catch (_) {}

      final rowData = [
        '"${l['lot_id']}"',
        '"${l['farmer_name']}"',
        '"${l['culture_type']}"',
        l['weight_declared'],
        l['weight_verified'] ?? '--',
        '"${l['status']}"',
        '"$formattedDate"',
      ];

      if (detailed) {
        final history = (l['transfers'] as List?)?.map((t) {
          return "${t['from_actor']} -> ${t['to_actor']} (${t['notes']})";
        }).join(' | ') ?? 'Aucun transfert';
        rowData.add('"$history"');
      }

      return rowData;
    });

    String csv = '${headers.join(',')}\n${rows.map((r) => r.join(',')).join('\n')}';
    
    // Création du lien de téléchargement (Web specifique)
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "lots_chaincacao_${DateTime.now().millisecondsSinceEpoch}.csv")
      ..click();
    html.Url.revokeObjectUrl(url);

    // Notification Toast (SnackBar) de succès
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Export CSV réussi ! Le fichier a été téléchargé.'),
          backgroundColor: AppColors.vertFeuille,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _loadLots() async {
    setState(() => _isRefreshing = true);
    try {
      final results = await ApiClient.getLots();
      if (mounted) {
        setState(() {
          _cachedLots = results;
          _initialLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initialLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    // On calcule la liste filtrée ici pour avoir accès au compte globalement dans le build
    final filteredLots = _cachedLots?.where((lot) {
      // Filtre par statut
      final matchesStatus = _filterStatus == 'all' || lot['status'] == _filterStatus;
      
      // Filtre par recherche textuelle
      final query = _searchQuery.toLowerCase();
      final lotId = (lot['lot_id'] ?? '').toString().toLowerCase();
      final farmer = (lot['farmer_name'] ?? '').toString().toLowerCase();
      final matchesSearch = lotId.contains(query) || farmer.contains(query);

      // Filtre par plage de dates
      bool matchesDate = true;
      if (_selectedDateRange != null) {
        final registeredAt = DateTime.tryParse(lot['registered_at'] ?? '');
        if (registeredAt != null) {
          matchesDate = registeredAt.isAfter(_selectedDateRange!.start) && registeredAt.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
        }
      }

      return matchesStatus && matchesSearch && matchesDate;
    }).toList() ?? [];

    return RefreshIndicator(
      onRefresh: _loadLots,
      color: AppColors.orChaud,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isRefreshing)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.creme,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.orChaud),
                ),
              ),
            Row(
              children: [
                Text('Mes lots', style: AppTextStyles.h1),
                if (!_initialLoading) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cacao.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${filteredLots.length}',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.cacao,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Suivez l\'état de tous vos lots enregistrés',
              style: AppTextStyles.bodySecondary,
            ),
          const SizedBox(height: 24),
          // Barre de recherche en temps réel
          TextField(
            controller: _searchController,
            onChanged: (value) {
              // On déclenche un setState immédiat pour afficher/masquer le bouton "X"
              setState(() {});

              // Debouncing : on annule le timer précédent et on en lance un nouveau
              // Le filtrage réel ne s'exécutera que 500ms après la dernière saisie
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                if (mounted) {
                  setState(() => _searchQuery = value);
                }
              });
            },
            decoration: InputDecoration(
              hintText: 'Rechercher par ID de lot ou producteur...',
              prefixIcon: const Icon(Icons.search, color: AppColors.grisTexte),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.grisTexte),
                      onPressed: () {
                        _searchController.clear();
                        _debounce?.cancel();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0D5C8), width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0D5C8), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.orChaud, width: 1.5),
              ),
            ),
          ),
            const SizedBox(height: 32),
            // Filtres
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Tous',
                    isSelected: _filterStatus == 'all',
                    onSelected: () {
                      setState(() => _filterStatus = 'all');
                    },
                  ),
                  _FilterChip(
                    label: 'En attente',
                    isSelected: _filterStatus == 'REGISTERED',
                    onSelected: () {
                      setState(() => _filterStatus = 'REGISTERED');
                    },
                  ),
                  _FilterChip(
                    label: 'Validés',
                    isSelected: _filterStatus == 'VALIDATED',
                    onSelected: () {
                      setState(() => _filterStatus = 'VALIDATED');
                    },
                  ),
                  _FilterChip(
                    label: 'Alerte fraude',
                    isSelected: _filterStatus == 'FRAUD_ALERT',
                    onSelected: () {
                      setState(() => _filterStatus = 'FRAUD_ALERT');
                    },
                  ),
                  _FilterChip(
                    label: 'Exportés',
                    isSelected: _filterStatus == 'EXPORTED',
                    onSelected: () {
                      setState(() => _filterStatus = 'EXPORTED');
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: _selectedDateRange == null 
                      ? 'Dates' 
                      : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
                    isSelected: _selectedDateRange != null,
                    onSelected: _pickDateRange,
                    icon: Icons.calendar_today_outlined,
                  ),
                  const SizedBox(width: 8),
                  if (_filterStatus != 'all' || _searchQuery.isNotEmpty || _selectedDateRange != null)
                    TextButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Réinitialiser'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.rougeErreur,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: AppColors.rougeErreur.withOpacity(0.2)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                if (!isMobile && !_initialLoading && filteredLots.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => _showExportOptions(filteredLots),
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Exporter CSV'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(160, 44),
                      side: BorderSide(color: AppColors.cacao.withOpacity(0.2)),
                    ),
                  ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showMergeDialog(context),
                  icon: const Icon(Icons.merge_type),
                  label: const Text('Fusionner des lots'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bleuTransit,
                    minimumSize: const Size(200, 44),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Liste des lots
            if (_initialLoading)
              _buildShimmerPlaceholder()
            else if (_cachedLots == null || _cachedLots!.isEmpty)
              _buildEmpty()
            else
              _buildLotList(filteredLots),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.white,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun lot',
              style: AppTextStyles.h2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLotList(List<Map<String, dynamic>> filteredLots) {
    if (filteredLots.isEmpty) return _buildEmpty();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredLots.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final lot = filteredLots[index];
        return _LotDetailCard(
          lot: lot,
          onRefresh: _loadLots,
          isRefreshing: _isRefreshing,
        );
      },
    );
  }

  void _showMergeDialog(BuildContext context) {
    final selected = <String>[];
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Fusionner des lots'),
          content: _initialLoading
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Selectionnez au moins 2 lots a fusionner',
                        style: AppTextStyles.bodySecondary,
                      ),
                      const SizedBox(height: 16),
                      ...(_cachedLots ?? [])
                          .where((l) =>
                              l['status'] == 'REGISTERED' ||
                              l['status'] == 'VALIDATED')
                          .map((lot) => CheckboxListTile(
                                title: Text(lot['lot_id'] ?? ''),
                                subtitle: Text(
                                    '${lot['weight_declared']} kg - ${lot['farmer_name']}'),
                                value: selected.contains(lot['lot_id']),
                                onChanged: (v) => setLocal(() {
                                  if (v == true) {
                                    selected.add(lot['lot_id']);
                                  } else {
                                    selected.remove(lot['lot_id']);
                                  }
                                }),
                                activeColor: AppColors.orChaud,
                              )),
                    ],
                  ),
                ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annuler')),
            ElevatedButton.icon(
              onPressed: selected.length < 2
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                    await ApiClient.mergeLots(selected);
                      if (mounted) {
                        _loadLots();
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                              'Lots fusionnes avec succes'),
                          backgroundColor:
                              AppColors.vertFeuille,
                        ));
                      }
                    },
              icon: const Icon(Icons.merge_type),
              label: Text(
                  'Fusionner (${selected.length} lots)'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bleuTransit),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Row(children: [if(icon != null) Icon(icon, size: 16, color: isSelected ? AppColors.cacao : AppColors.grisTexte), if(icon != null) const SizedBox(width: 6), Text(label)]),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        backgroundColor: Colors.white,
        selectedColor: AppColors.cacao.withOpacity(0.15),
        side: BorderSide(
          color:
              isSelected ? AppColors.cacao : Colors.grey.shade300,
        ),
      ),
    );
  }
}

class _LotDetailCard extends StatefulWidget {
  final Map<String, dynamic> lot;
  final VoidCallback onRefresh;
  final bool isRefreshing;

  const _LotDetailCard({
    required this.lot,
    required this.onRefresh,
    required this.isRefreshing,
  });

  @override
  State<_LotDetailCard> createState() => _LotDetailCardState();
}

class _LotDetailCardState extends State<_LotDetailCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final status = widget.lot['status'] ?? 'REGISTERED';
    final (statusColor, statusLabel) = _getStatusInfo(status);
    final hasFraud = widget.lot['fraud_alert'] == true;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovered
            ? Matrix4.translationValues(0, -4, 0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: hasFraud ? AppColors.rougeErreur : statusColor,
              width: 4,
            ),
            top: BorderSide(color: _isHovered ? AppColors.orChaud.withOpacity(0.3) : Colors.grey.shade200),
            right: BorderSide(color: _isHovered ? AppColors.orChaud.withOpacity(0.3) : Colors.grey.shade200),
            bottom: BorderSide(color: _isHovered ? AppColors.orChaud.withOpacity(0.3) : Colors.grey.shade200),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.12 : 0.05),
              blurRadius: _isHovered ? 20 : 10,
              offset: _isHovered ? const Offset(0, 8) : const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.lot['lot_id'] ?? 'N/A',
                      style: AppTextStyles.h2.copyWith(
                        fontFamily: 'Courier',
                        color: AppColors.cacao,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.lot['farmer_name'] ?? 'N/A',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    statusLabel,
                    style: AppTextStyles.bodySecondary.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hasFraud)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.rougeErreur.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning,
                      color: AppColors.rougeErreur,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alerte fraude détectée',
                            style: AppTextStyles.bodySecondary.copyWith(
                              color: AppColors.rougeErreur,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.lot['fraud_details'] ?? 'Écart détecté',
                            style: AppTextStyles.bodySecondary.copyWith(
                              color: AppColors.rougeErreur,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (hasFraud) const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _InfoField(
                  label: 'Culture',
                  value: widget.lot['culture_type'] ?? 'N/A',
                ),
                _InfoField(
                  label: 'Poids déclaré',
                  value: '${widget.lot['weight_declared']} kg',
                ),
                _InfoField(
                  label: 'Poids vérifié',
                  value: widget.lot['weight_verified'] != null
                      ? '${widget.lot['weight_verified']} kg'
                      : '--',
                ),
                _InfoField(
                  label: 'Région',
                  value: 'Plateaux, Togo',
                ),
                _InfoField(
                  label: 'Localisation',
                  value:
                      '${widget.lot['gps_latitude']?.toStringAsFixed(4)}, ${widget.lot['gps_longitude']?.toStringAsFixed(4)}',
                ),
                _InfoField(
                  label: 'Date enregistrement',
                  value: widget.lot['registered_at'] ?? 'N/A',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.lot['transfers'] != null && (widget.lot['transfers'] as List).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Historique des transferts', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  ...(widget.lot['transfers'] as List).map(
                    (transfer) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${transfer['from_actor']} → ${transfer['to_actor']}: ${transfer['notes']}',
                              style: AppTextStyles.bodySecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (status == 'REGISTERED' || status == 'FRAUD_ALERT')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                LotValidationPage(lot: widget.lot)),
                        );
                        widget.onRefresh();
                      },
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Valider'),
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 40)),
                    ),
                  ),
                if (status == 'VALIDATED')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                LotValidationPage(lot: widget.lot)),
                        );
                        widget.onRefresh();
                      },
                      icon: const Icon(Icons.send, size: 16),
                      label: const Text('Transferer'),
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 40)),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showLotDetails(context, widget.lot),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Details'),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  (Color, String) _getStatusInfo(String status) {
    return switch (status) {
      'VALIDATED' => (AppColors.vertFeuille, 'Validé'),
      'EXPORTED' => (AppColors.bleuTransit, 'Exporté'),
      'IN_TRANSFER' => (AppColors.orChaud, 'En transit'),
      'FRAUD_ALERT' => (AppColors.rougeErreur, 'Alerte'),
      _ => (AppColors.orangeAlerte, 'En attente'),
    };
  }

  void _showLotDetails(BuildContext context, Map<String, dynamic> lot) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Détails du lot ${lot['lot_id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow('ID', lot['lot_id'] ?? 'N/A'),
              _DetailRow('Agriculteur', lot['farmer_name'] ?? 'N/A'),
              _DetailRow('Culture', lot['culture_type'] ?? 'N/A'),
              _DetailRow('Poids déclaré', '${lot['weight_declared']} kg'),
              _DetailRow(
                'Poids vérifié',
                lot['weight_verified'] != null
                    ? '${lot['weight_verified']} kg'
                    : '--',
              ),
              _DetailRow('Coordonnées GPS',
                  '${lot['gps_latitude']}, ${lot['gps_longitude']}'),
              _DetailRow('Statut', lot['status'] ?? 'N/A'),
              if (lot['fraud_alert'] == true)
                _DetailRow('Alerte', lot['fraud_details'] ?? 'Alerte fraude'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySecondary),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.h3),
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;

  const _InfoField({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySecondary),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.body),
      ],
    );
  }
}
