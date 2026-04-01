class UserModel {
  final String id;
  final String name;
  final String email;
  final double balance;
  final double dailyEarnings;
  final String apiKey;
  final String role;
  final DateTime createdAt;
  final String? referredBy;
  final double referralEarnings;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.balance,
    required this.dailyEarnings,
    required this.apiKey,
    required this.role,
    required this.createdAt,
    this.referredBy,
    this.referralEarnings = 0.0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      dailyEarnings: (json['daily_earnings'] ?? 0).toDouble(),
      apiKey: json['api_key'] ?? '',
      role: json['role'] ?? 'user',
      createdAt: (json['created_at'] != null && json['created_at'] is int)
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'])
          : DateTime.now(),
      referredBy: json['referred_by'],
      referralEarnings: (json['referral_earnings'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'balance': balance,
      'daily_earnings': dailyEarnings,
      'api_key': apiKey,
      'role': role,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    double? balance,
    double? dailyEarnings,
    String? apiKey,
    String? role,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      balance: balance ?? this.balance,
      dailyEarnings: dailyEarnings ?? this.dailyEarnings,
      apiKey: apiKey ?? this.apiKey,
      role: role ?? this.role,
      createdAt: createdAt,
    );
  }

  // Currency utility: 1 USD = 115 BDT
  double get balanceBDT => balance * 115.0;
}
