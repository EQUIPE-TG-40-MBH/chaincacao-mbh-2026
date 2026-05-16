import 'champ.dart';

class Producteur {
  final String id;
  final String nomComplet;
  final String photoUrl;
  final String telephone;
  final String langue;
  final String? idCooperative;
  final List<Champ> champs; // Liste des champs (privés + coopératifs)

  const Producteur({
    required this.id,
    required this.nomComplet,
    required this.photoUrl,
    required this.telephone,
    required this.langue,
    this.idCooperative,
    required this.champs,
  });

  factory Producteur.fromJson(Map<String, dynamic> json) => Producteur(
    id: json['id'],
    nomComplet: json['name'],
    photoUrl:      json['photo_url']      as String,
    telephone: json['phone'],
    langue: json['language'] ?? 'fr',
    idCooperative: json['cooperative_id'],
    champs:
        (json['champs'] as List?)?.map((c) => Champ.fromJson(c)).toList() ?? [],
  );

  Map<String, dynamic> toJson() => {
    'id':             id,
    'name':           nomComplet,
    'phone':          telephone,
    'language':       langue,
    'cooperative_id': idCooperative,
    'photo_url':      photoUrl,
  };

  // Pour ta salutation dashboard
  String get prenom => nomComplet.split(' ').first;


  // Filtrage : retourne uniquement les champs de la coopérative
  List<Champ> get champsCooperative =>
      champs.where((c) => c.estCollectif).toList();

  // Filtrage : retourne uniquement les champs personnels
  List<Champ> get champsPrives => champs.where((c) => !c.estCollectif).toList();
}
