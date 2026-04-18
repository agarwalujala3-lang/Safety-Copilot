class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String phone;
  final DateTime createdAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
