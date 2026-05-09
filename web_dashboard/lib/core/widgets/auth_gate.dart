import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthGate extends StatelessWidget {
  final String requiredRole;
  final Widget child;

  const AuthGate({super.key, required this.requiredRole, required this.child});

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

        if (account.role != requiredRole) {
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
