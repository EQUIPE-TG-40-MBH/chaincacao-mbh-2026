import 'champ.dart';

class Producteur {
  final String id;
  final String nomComplet;
  final String telephone;
  final String langue;
  final String? idCooperative;
  final List<Champ> champs; // Liste des champs (privés + coopératifs)

  const Producteur({
    required this.id,
    required this.nomComplet,
    required this.telephone,
    required this.langue,
    this.idCooperative,
    required this.champs,
  });

  factory Producteur.fromJson(Map<String, dynamic> json) => Producteur(
    id: json['id'],
    nomComplet: json['name'],
    telephone: json['phone'],
    langue: json['language'] ?? 'fr',
    idCooperative: json['cooperative_id'],
    champs:
        (json['champs'] as List?)?.map((c) => Champ.fromJson(c)).toList() ?? [],
  );

  // Pour ta salutation dashboard
  String get prenom => nomComplet.split(' ').first;

  // Vérifie si le producteur est dans l'un de ses champs autorisés
  bool estDansUneZoneAutorisee(double currentLat, double currentLong) {
    // Ici on bouclera sur 'champs' avec le service Haversine
    return true;
  }

  // Filtrage : retourne uniquement les champs de la coopérative
  List<Champ> get champsCooperative =>
      champs.where((c) => c.estCollectif).toList();

  // Filtrage : retourne uniquement les champs personnels
  List<Champ> get champsPrives => champs.where((c) => !c.estCollectif).toList();
}
