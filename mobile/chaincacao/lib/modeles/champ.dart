// lib/modeles/champ.dart

class Champ {
  final String id;
  final String nom;           // ex: "Champ de Kpalimé Nord"
  final double latitude;
  final double longitude;
  final double rayonCloture;  // en mètres — zone autorisée autour du centre
  final bool   estCollectif;  // true = champ coopérative, false = champ privé
  final double? superficieHa; // TODO : à ajouter côté API Jacques si disponible

  const Champ({
    required this.id,
    required this.nom,
    required this.latitude,
    required this.longitude,
    this.rayonCloture  = 100.0,
    this.estCollectif  = false,
    this.superficieHa,
  });

  // ── Désérialisation API 
  factory Champ.fromJson(Map<String, dynamic> json) => Champ(
    id:            json['id']            as String,
    nom:           json['nom']           as String,
    latitude:      (json['latitude']     as num).toDouble(),
    longitude:     (json['longitude']    as num).toDouble(),
    rayonCloture:  (json['rayon_cloture'] as num?)?.toDouble() ?? 100.0,
    estCollectif:  json['est_collectif'] as bool? ?? false,
    superficieHa:  (json['superficie_ha'] as num?)?.toDouble(),
  );

  // ── Sérialisation 
  Map<String, dynamic> toJson() => {
    'id':             id,
    'nom':            nom,
    'latitude':       latitude,
    'longitude':      longitude,
    'rayon_cloture':  rayonCloture,
    'est_collectif':  estCollectif,
    'superficie_ha':  superficieHa,
  };

  // ── Helpers UI 

  // Nom affiché avec le type — ex: "Champ Nord (Coopérative)"
  String get nomAffiche =>
      estCollectif ? '$nom (Coopérative)' : nom;

  // Superficie formatée pour l'affichage
  // TODO : afficher dans ecran_selection_champ.dart
  String get superficieFormatee =>
      superficieHa != null ? '${superficieHa!.toStringAsFixed(1)} ha' : 'Surface inconnue';

  // Rayon formaté — ex: "100 m" ou "1.2 km"
  String get rayonFormate =>
      rayonCloture >= 1000
          ? '${(rayonCloture / 1000).toStringAsFixed(1)} km'
          : '${rayonCloture.toInt()} m';
}