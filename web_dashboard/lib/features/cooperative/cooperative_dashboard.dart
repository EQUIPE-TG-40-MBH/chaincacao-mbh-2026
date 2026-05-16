import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/auth_service.dart';
import 'pages/cooperative_home_page.dart';
import 'pages/cooperative_farmers_page.dart';
import 'pages/cooperative_purchases_page.dart';
import 'pages/cooperative_register_harvest_page.dart';
import 'pages/cooperative_lots_page.dart';
import 'pages/cooperative_profile_page.dart';

class CooperativeDashboard extends StatefulWidget {
  const CooperativeDashboard({super.key});

  @override
  State<CooperativeDashboard> createState() => _CooperativeDashboardState();
}

class _CooperativeDashboardState extends State<CooperativeDashboard> {
  int _currentIndex = 0;
  EntityAccount? _account;
  List<Widget>? _cachedPages;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    final account = await AuthService.currentAccount();
    if (mounted) {
      setState(() {
        _account = account;
        _cachedPages = [
          _buildHome(),
          CooperativeFarmersPage(account: account),
          CooperativeRegisterHarvestPage(account: account),
          CooperativeLotsPage(account: account),
          CooperativePurchasesPage(account: account),
          CooperativeProfilePage(account: account),
        ];
      });
    }
  }

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Accueil'),
    _NavItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Agriculteurs'),
    _NavItem(icon: Icons.agriculture_outlined, activeIcon: Icons.agriculture, label: 'Recoltes'),
    _NavItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2, label: 'Lots'),
    _NavItem(icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart, label: 'Achats'),
    _NavItem(icon: Icons.business_outlined, activeIcon: Icons.business, label: 'Profil'),
  ];

  Widget _buildHome() {
    return CooperativeHomePage(
      account: _account,
      onViewAllLots: () => setState(() => _currentIndex = 3),
      onAddFarmer: () => setState(() => _currentIndex = 1),
      onRegisterHarvest: () => setState(() => _currentIndex = 2),
      onBuy: () => setState(() => _currentIndex = 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 860;

    if (_account == null || _cachedPages == null) {
      return const Scaffold(
        backgroundColor: AppColors.creme,
        body: Center(child: CircularProgressIndicator(color: AppColors.orChaud)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.creme,
      body: SafeArea(
        child: isMobile
            ? _buildMobileLayout()
            : _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildSidebar(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: IndexedStack(
                    key: ValueKey<int>(_currentIndex),
                    index: _currentIndex,
                    children: _cachedPages!,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildMobileTopBar(),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: IndexedStack(
              key: ValueKey<int>(_currentIndex),
              index: _currentIndex,
              children: _cachedPages!,
            ),
          ),
        ),
        _buildBottomNav(),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 72,
      color: AppColors.cacao,
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Logo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/logo/chaincacao_logo_light.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.eco,
                  color: AppColors.orChaud,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Nav items
          Expanded(
            child: Column(
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final selected = _currentIndex == index;
                return Tooltip(
                  message: item.label,
                  preferBelow: false,
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = index),
                    child: Container(
                      width: 52,
                      height: 52,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.orChaud.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: selected
                            ? Border.all(color: AppColors.orChaud.withOpacity(0.4))
                            : null,
                      ),
                      child: Icon(
                        selected ? item.activeIcon : item.icon,
                        color: selected ? AppColors.orVif : Colors.white54,
                        size: 24,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Profile icon
          Tooltip(
            message: _account?.entityName ?? 'Profil',
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.orChaud,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _account?.entityName.isNotEmpty == true
                      ? _account!.entityName[0].toUpperCase()
                      : 'C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Logout
          Tooltip(
            message: 'Deconnexion',
            child: GestureDetector(
              onTap: () async {
                await AuthService.logout();
                if (mounted) Navigator.pushReplacementNamed(context, '/');
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.logout,
                  color: Colors.white54,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final item = _navItems[_currentIndex];
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
      decoration: BoxDecoration(
        color: AppColors.creme,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.label, style: AppTextStyles.h1),
              const SizedBox(height: 2),
              Text(
                _account?.entityName ?? '',
                style: AppTextStyles.bodySecondary,
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.orChaud.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.orChaud.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: AppColors.orChaud, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _account?.registrationId ?? '',
                      style: const TextStyle(
                        color: AppColors.orChaud,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.cacao,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'ChainCacao',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Text(
                _navItems[_currentIndex].label,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () async {
                  await AuthService.logout();
                  if (mounted) Navigator.pushReplacementNamed(context, '/');
                },
                child: const Icon(Icons.logout, color: Colors.white54, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cacao,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_navItems.length, (index) {
          final item = _navItems[index];
          final selected = _currentIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selected ? item.activeIcon : item.icon,
                      color: selected ? AppColors.orVif : Colors.white38,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: selected ? AppColors.orVif : Colors.white38,
                        fontSize: 10,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}