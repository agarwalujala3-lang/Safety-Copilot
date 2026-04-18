class CircleModel {
  CircleModel({
    required this.id,
    required this.name,
    required this.memberCount,
  });

  final String id;
  final String name;
  final int memberCount;

  factory CircleModel.fromJson(Map<String, dynamic> json) {
    final members = json['members'] as List<dynamic>? ?? const [];
    return CircleModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      memberCount: members.length,
    );
  }
}
