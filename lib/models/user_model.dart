class UserModel {
  final String id;
  final String name;
  final String email;
  final double balance;
  final String apiKey;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.balance,
    required this.apiKey,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      apiKey: json['api_key'] ?? '',
      createdAt: (json['created_at'] != null)
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'balance': balance,
      'api_key': apiKey,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
}
