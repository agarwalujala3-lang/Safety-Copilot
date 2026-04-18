class AlertModel {
  AlertModel({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.createdAt,
    required this.acknowledgedAt,
  });

  final String id;
  final String type;
  final String severity;
  final String message;
  final DateTime createdAt;
  final DateTime? acknowledgedAt;

  bool get isAcknowledged => acknowledgedAt != null;

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'unknown',
      severity: json['severity'] as String? ?? 'low',
      message: json['message'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      acknowledgedAt: json['acknowledgedAt'] == null
          ? null
          : DateTime.tryParse(json['acknowledgedAt'] as String),
    );
  }
}
