import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EcranScanSac extends StatelessWidget {
  const EcranScanSac({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Scanner Sac")),
    body: Center(child: ElevatedButton(onPressed: () => context.push('/recolte/pesee'), child: const Text("Simuler Scan OK"))),
  );
}