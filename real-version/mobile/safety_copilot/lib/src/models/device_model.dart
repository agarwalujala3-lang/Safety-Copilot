class DeviceModel {
  DeviceModel({
    required this.deviceId,
    required this.platform,
    required this.lastSeenAt,
    required this.batteryLevel,
  });

  final String deviceId;
  final String platform;
  final DateTime? lastSeenAt;
  final int? batteryLevel;

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      deviceId: json['deviceId'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
      lastSeenAt: json['lastSeenAt'] == null
          ? null
          : DateTime.tryParse(json['lastSeenAt'] as String),
      batteryLevel: (json['batteryLevel'] as num?)?.toInt(),
    );
  }
}
