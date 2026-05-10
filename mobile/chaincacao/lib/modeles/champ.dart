class Champ {
  final String id;
  final String nom; // ex: "Champ de Kpalimé Nord"
  final double latitude;
  final double longitude;
  final double rayonCloture; // en mètres, ex: 100.0
  final bool estCollectif; // true si c'est un champ de coopérative

  const Champ({
    required this.id,
    required this.nom,
    required this.latitude,
    required this.longitude,
    this.rayonCloture = 100.0,
    this.estCollectif = false,
  });

  factory Champ.fromJson(Map<String, dynamic> json) => Champ(
    id: json['id'],
    nom: json['nom'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    rayonCloture: json['rayon_cloture']?.toDouble() ?? 100.0,
    estCollectif: json['est_collectif'] ?? false,
  );
}