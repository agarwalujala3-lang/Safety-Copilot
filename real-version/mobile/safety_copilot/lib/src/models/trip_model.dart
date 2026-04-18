class TripModel {
  TripModel({
    required this.id,
    required this.status,
    required this.destinationName,
    required this.destinationLat,
    required this.destinationLng,
  });

  final String id;
  final String status;
  final String destinationName;
  final double destinationLat;
  final double destinationLng;

  bool get isActive => status == 'active';

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'active',
      destinationName: json['destinationName'] as String? ?? 'Destination',
      destinationLat: (json['destinationLat'] as num?)?.toDouble() ?? 0,
      destinationLng: (json['destinationLng'] as num?)?.toDouble() ?? 0,
    );
  }
}
