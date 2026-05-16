import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthGate extends StatelessWidget {
  final String? requiredRole;
  final List<String>? requiredRoles;
  final Widget child;

  const AuthGate({
    super.key,
    this.requiredRole,
    this.requiredRoles,
    required this.child,
  });

  List<String> get _allowedRoles {
    if (requiredRoles != null && requiredRoles!.isNotEmpty) {
      return requiredRoles!;
    }
    if (requiredRole != null) {
      return [requiredRole!];
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EntityAccount?>(
      future: AuthService.currentAccount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final account = snapshot.data;
        if (account == null) {
          Future.microtask(() {
            if (context.mounted) Navigator.pushReplacementNamed(context, '/');
          });
          return const SizedBox.shrink();
        }

        if (_allowedRoles.isNotEmpty && !_allowedRoles.contains(account.role)) {
          Future.microtask(() {
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, account.homeRoute);
            }
          });
          return const SizedBox.shrink();
        }

        return child;
      },
    );
  }
}
