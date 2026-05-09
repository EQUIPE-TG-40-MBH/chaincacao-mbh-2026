import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class DashboardDestination {
  final String label;
  final String route;
  final IconData icon;

  const DashboardDestination({
    required this.label,
    required this.route,
    required this.icon,
  });
}

const List<DashboardDestination> dashboardDestinations = [
  DashboardDestination(
    label: 'Cooperative',
    route: '/cooperative',
    icon: Icons.account_tree_outlined,
  ),
  DashboardDestination(
    label: 'Exportateur',
    route: '/exportateur',
    icon: Icons.local_shipping_outlined,
  ),
  DashboardDestination(
    label: 'Verification',
    route: '/verifier',
    icon: Icons.qr_code_2_outlined,
  ),
];

class DashboardShell extends StatelessWidget {
  final String currentRoute;
  final String pageTitle;
  final String pageSubtitle;
  final String userName;
  final String userRole;
  final Widget child;
  final List<Widget> actions;
  final Widget? floatingAction;

  const DashboardShell({
    super.key,
    required this.currentRoute,
    required this.pageTitle,
    required this.pageSubtitle,
    required this.userName,
    required this.userRole,
    required this.child,
    this.actions = const [],
    this.floatingAction,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 980;
        final sidebarWidth = isCompact ? 96.0 : 288.0;

        return Scaffold(
          backgroundColor: AppColors.creme,
          body: Row(
            children: [
              _Sidebar(
                width: sidebarWidth,
                compact: isCompact,
                currentRoute: currentRoute,
                userName: userName,
                userRole: userRole,
              ),
              Expanded(
                child: Stack(
                  children: [
                    CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              isCompact ? 24 : 40,
                              32,
                              isCompact ? 24 : 40,
                              16,
                            ),
                            child: _Header(
                              title: pageTitle,
                              subtitle: pageSubtitle,
                              actions: actions,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              isCompact ? 24 : 40,
                              0,
                              isCompact ? 24 : 40,
                              floatingAction == null ? 40 : 128,
                            ),
                            child: child,
                          ),
                        ),
                      ],
                    ),
                    if (floatingAction != null)
                      Positioned(
                        left: isCompact ? 24 : 40,
                        right: isCompact ? 24 : 40,
                        bottom: 24,
                        child: floatingAction!,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> actions;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.h1),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTextStyles.bodySecondary),
            ],
          ),
        ),
        if (actions.isNotEmpty)
          Wrap(spacing: 12, runSpacing: 12, children: actions),
      ],
    );
  }
}

class _Sidebar extends StatelessWidget {
  final double width;
  final bool compact;
  final String currentRoute;
  final String userName;
  final String userRole;

  const _Sidebar({
    required this.width,
    required this.compact,
    required this.currentRoute,
    required this.userName,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: double.infinity,
      padding: EdgeInsets.all(compact ? 16 : 24),
      decoration: BoxDecoration(
        color: AppColors.cacao,
        boxShadow: [
          BoxShadow(
            color: AppColors.cacao.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(8, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: compact
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          _Brand(compact: compact),
          const SizedBox(height: 40),
          ...dashboardDestinations.map(
            (destination) => _NavItem(
              destination: destination,
              selected: currentRoute == destination.route,
              compact: compact,
            ),
          ),
          const Spacer(),
          _ProfileCard(
            compact: compact,
            userName: userName,
            userRole: userRole,
          ),
          const SizedBox(height: 12),
          _LogoutButton(compact: compact),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  final bool compact;

  const _Brand({required this.compact});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/logo/chaincacao_logo.png',
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      );
    }

    return SizedBox(
      height: 64,
      child: Image.asset(
        'assets/logo/chaincacao_logo.png',
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final DashboardDestination destination;
  final bool selected;
  final bool compact;

  const _NavItem({
    required this.destination,
    required this.selected,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Tooltip(
        message: compact ? destination.label : '',
        waitDuration: const Duration(milliseconds: 300),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (!selected) {
              Navigator.pushReplacementNamed(context, destination.route);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: 56,
            padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 16),
            decoration: BoxDecoration(
              color: selected ? AppColors.orChaud : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? AppColors.orVif.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: compact
                ? Center(
                    child: Icon(
                      destination.icon,
                      color: AppColors.blanc,
                      size: 24,
                    ),
                  )
                : Row(
                    children: [
                      Icon(destination.icon, color: AppColors.blanc, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          destination.label,
                          style: AppTextStyles.button,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final bool compact;
  final String userName;
  final String userRole;

  const _ProfileCard({
    required this.compact,
    required this.userName,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: compact
          ? const Icon(Icons.person_outline, color: AppColors.blanc)
          : Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.orChaud,
                  child: Text(
                    userName.substring(0, 1).toUpperCase(),
                    style: AppTextStyles.button,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.blanc,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        userRole,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySecondary.copyWith(
                          color: AppColors.grisTexte,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final bool compact;

  const _LogoutButton({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Deconnexion',
      child: OutlinedButton(
        onPressed: () => Navigator.pushReplacementNamed(context, '/'),
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, compact ? 48 : 56),
          foregroundColor: AppColors.blanc,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
          padding: EdgeInsets.zero,
        ),
        child: compact
            ? const Icon(Icons.logout, size: 20)
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 8),
                  Text('Deconnexion'),
                ],
              ),
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Border? border;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.color = AppColors.blanc,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: border,
        boxShadow: [
          BoxShadow(
            color: AppColors.cacao.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AnimatedAppear extends StatelessWidget {
  final int index;
  final Widget child;

  const AnimatedAppear({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

Route<T> premiumRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.02, 0.02),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
