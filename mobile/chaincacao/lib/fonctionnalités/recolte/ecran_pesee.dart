import 'package:flutter/material.dart';
import '../../configuration/theme.dart';

class EcranPesee extends StatelessWidget {
  final String idSac;
  const EcranPesee({super.key, required this.idSac});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CCCouleurs.vertProfond,
      body: Center(
        child: Text('EcranPesee — $idSac',
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
