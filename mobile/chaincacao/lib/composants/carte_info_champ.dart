import 'package:flutter/material.dart';
import '../../modeles/champ.dart';

class CarteInfoChamp extends StatelessWidget {
  final Champ champ;
  final bool estDansLaZone; // Résultat du Géofencing

  const CarteInfoChamp({
    super.key, 
    required this.champ, 
    required this.estDansLaZone
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: estDansLaZone ? const Color(0xFFD8F3DC) : const Color(0xFFFFD6D6),
      child: ListTile(
        leading: Icon(
          estDansLaZone ? Icons.location_on : Icons.location_off,
          color: estDansLaZone ? const Color(0xFF3A4D39) : Colors.red,
        ),
        title: Text(champ.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          estDansLaZone 
            ? "Position validée pour la récolte" 
            : "Attention : Hors de la zone du champ",
          style: TextStyle(color: estDansLaZone ? Colors.green[800] : Colors.red[800]),
        ),
      ),
    );
  }
}