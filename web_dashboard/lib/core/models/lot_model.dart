class Lot {
  final String lotId;
  final String farmerId;
  final String farmerName;
  final String cooperativeId;
  final double weightDeclared;
  final double weightVerified;
  final String gpsCoordinates;
  final String cultureType;
  final String status;
  final String registeredAt;
  final String blockchainHash;

  Lot({
    required this.lotId,
    required this.farmerId,
    required this.farmerName,
    required this.cooperativeId,
    required this.weightDeclared,
    required this.weightVerified,
    required this.gpsCoordinates,
    required this.cultureType,
    required this.status,
    required this.registeredAt,
    required this.blockchainHash,
  });

  factory Lot.fromJson(Map<String, dynamic> json) {
    return Lot(
      lotId: json['lot_id'] ?? '',
      farmerId: json['farmer_id'] ?? '',
      farmerName: json['farmer_name'] ?? '',
      cooperativeId: json['cooperative_id'] ?? '',
      weightDeclared: (json['weight_declared'] ?? 0).toDouble(),
      weightVerified: (json['weight_verified'] ?? 0).toDouble(),
      gpsCoordinates: json['gps_coordinates'] ?? '',
      cultureType: json['culture_type'] ?? '',
      status: json['status'] ?? '',
      registeredAt: json['registered_at'] ?? '',
      blockchainHash: json['blockchain_hash'] ?? '',
    );
  }
}
