// lib/composants/bouton_audio_guide.dart

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../configuration/theme.dart';
import '../services/service_audio.dart';

class BoutonAudioGuide extends StatefulWidget {
  final String cleAudio;
  const BoutonAudioGuide({super.key, required this.cleAudio});

  @override
  State<BoutonAudioGuide> createState() => _BoutonAudioGuideState();
}

class _BoutonAudioGuideState extends State<BoutonAudioGuide>
    with SingleTickerProviderStateMixin {

  final ServiceAudio _audio = ServiceAudio();

  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Jouer automatiquement à l'ouverture
    _audio.jouerAuto(widget.cleAudio);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 90,
      right:  20,
      child: StreamBuilder<PlayerState>(
        stream: _audio.etatStream,
        builder: (_, snapshot) {
          final enLecture = snapshot.data?.playing ?? false;
          return GestureDetector(
            onTap: () => enLecture
                ? _audio.arreter()
                : _audio.jouerAuto(widget.cleAudio),
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) => Transform.scale(
                scale: enLecture ? _pulseAnim.value : 1.0,
                child: child,
              ),
              child: Container(
                width:  56,
                height: 56,
                decoration: BoxDecoration(
                  color: enLecture
                      ? CCCouleurs.vertForet
                      : CCCouleurs.vertProfond,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:      CCCouleurs.vertProfond.withOpacity(0.3),
                      blurRadius: 12,
                      offset:     const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  enLecture
                      ? Icons.stop_rounded
                      : Icons.volume_up_rounded,
                  color: CCCouleurs.limeVif,
                  size:  26,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}