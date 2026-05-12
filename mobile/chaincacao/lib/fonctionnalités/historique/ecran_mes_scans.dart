import 'package:flutter/material.dart';

class EcranMesScans extends StatelessWidget {
  const EcranMesScans({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Mon Historique")),
    body: const Center(child: Text("Liste des lots envoyés sur la blockchain")),
  );
}