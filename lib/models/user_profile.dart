/// User profile model
class UserProfile {
  final String? id;
  final String alias;
  final String mobileNumber;
  final String? address;
  final String? currentDistrict;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    this.id,
    required this.alias,
    required this.mobileNumber,
    this.address,
    this.currentDistrict,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alias': alias,
      'mobile_number': mobileNumber,
      'address': address,
      'current_district': currentDistrict,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from Map (SQLite data)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      alias: map['alias'] ?? '',
      mobileNumber: map['mobile_number'] ?? '',
      address: map['address'],
      currentDistrict: map['current_district'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// Create copy with updated fields
  UserProfile copyWith({
    String? id,
    String? alias,
    String? mobileNumber,
    String? address,
    String? currentDistrict,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      alias: alias ?? this.alias,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      currentDistrict: currentDistrict ?? this.currentDistrict,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}