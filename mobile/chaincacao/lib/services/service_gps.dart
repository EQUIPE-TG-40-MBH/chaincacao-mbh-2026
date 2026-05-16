// lib/services/service_gps.dart

import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../modeles/champ.dart';

// Résultat de la vérification GPS
class ResultatGps {
  final bool     estDansLeChamp;
  final double   distanceMetres;  // distance au centre du champ
  final Position position;        // position actuelle

  const ResultatGps({
    required this.estDansLeChamp,
    required this.distanceMetres,
    required this.position,
  });
}

class ServiceGps {
  ServiceGps._();
  static final ServiceGps instance = ServiceGps._();

  // ── Demander la permission et obtenir la position ─────────────────────
  Future<Position> obtenirPosition() async {
    // Vérifier si le GPS est activé
    final serviceActif = await Geolocator.isLocationServiceEnabled();
    if (!serviceActif) {
      throw Exception('GPS désactivé. Activez la localisation.');
    }

    // Vérifier/demander la permission
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission GPS refusée.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permission GPS refusée définitivement. '
        'Activez-la dans les paramètres.',
      );
    }

    // Obtenir la position avec haute précision
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // ── Vérifier si la position est dans le champ ─────────────────────────
  // Utilise la formule de Haversine pour calculer la distance
  Future<ResultatGps> verifierChamp(Champ champ) async {
    final position = await obtenirPosition();

    final distance = _haversine(
      position.latitude,
      position.longitude,
      champ.latitude,
      champ.longitude,
    );

    return ResultatGps(
      estDansLeChamp: distance <= champ.rayonCloture,
      distanceMetres: distance,
      position:       position,
    );
  }

  // ── Formule Haversine ─────────────────────────────────────────────────
  // Calcule la distance en mètres entre 2 coordonnées GPS
  double _haversine(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const rayonTerre = 6371000.0; // mètres
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return rayonTerre * c;
  }

  double _toRad(double deg) => deg * pi / 180;

  // ── Distance formatée pour l'UI ───────────────────────────────────────
  String formaterDistance(double metres) {
    if (metres < 1000) return '${metres.toInt()} m';
    return '${(metres / 1000).toStringAsFixed(1)} km';
  }
}