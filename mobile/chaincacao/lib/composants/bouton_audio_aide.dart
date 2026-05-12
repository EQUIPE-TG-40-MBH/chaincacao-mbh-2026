import 'package:flutter/material.dart';
import '../../services/service_audio.dart';
import 'package:provider/provider.dart';

class BoutonAudioAide extends StatelessWidget {
  final String cleAudio;
  final String langue;

  const BoutonAudioAide({
    super.key, 
    required this.cleAudio, 
    this.langue = 'fr'
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      onPressed: () => context.read<ServiceAudio>().jouer(cleAudio, langue: langue),
      backgroundColor: const Color(0xFFE9A139), // Jaune Solaire pour l'attention
      child: const Icon(Icons.volume_up, color: Colors.white),
    );
  }
}