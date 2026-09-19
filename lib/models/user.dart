/// User profile model for authentication, session management, and captain profile.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String tier;
  final int loyaltyPoints;
  final String joinedDate;
  final bool notificationsEnabled;
  final bool biometricEnabled;
  final bool isAdmin;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'Captain User',
    this.tier = 'GOLD COMMANDER',
    this.loyaltyPoints = 12850,
    this.joinedDate = 'March 2026',
    this.notificationsEnabled = true,
    this.biometricEnabled = true,
    this.isAdmin = false,
  });

  /// Derives initials for avatar display, e.g. "Captain User" -> "CU"
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'CU';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Default demo user profile
  factory UserModel.defaultUser() {
    return const UserModel(
      id: 'LHP-981765',
      name: 'Captain User',
      email: 'captain@harbour.com',
      role: 'Fleet Commander',
      tier: 'GOLD COMMANDER',
      loyaltyPoints: 12850,
      joinedDate: 'March 2026',
      notificationsEnabled: true,
      biometricEnabled: true,
      isAdmin: false,
    );
  }

  /// Admin user profile
  factory UserModel.adminUser() {
    return const UserModel(
      id: 'LHP-ADMIN-001',
      name: 'Farhan Admin',
      email: 'farhan2407a@gmail.com',
      role: 'Super Administrator',
      tier: 'ADMIN COMMANDER',
      loyaltyPoints: 99999,
      joinedDate: 'September 2026',
      notificationsEnabled: true,
      biometricEnabled: true,
      isAdmin: true,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? tier,
    int? loyaltyPoints,
    String? joinedDate,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    bool? isAdmin,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      tier: tier ?? this.tier,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      joinedDate: joinedDate ?? this.joinedDate,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'tier': tier,
      'loyaltyPoints': loyaltyPoints,
      'joinedDate': joinedDate,
      'notificationsEnabled': notificationsEnabled,
      'biometricEnabled': biometricEnabled,
      'isAdmin': isAdmin,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? 'LHP-${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Captain User',
      email: json['email'] as String? ?? 'captain@harbour.com',
      role: json['role'] as String? ?? 'Fleet Commander',
      tier: json['tier'] as String? ?? 'GOLD COMMANDER',
      loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt() ?? 12850,
      joinedDate: json['joinedDate'] as String? ?? 'March 2026',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      biometricEnabled: json['biometricEnabled'] as bool? ?? true,
      isAdmin: json['isAdmin'] as bool? ?? false,
    );
  }
}
