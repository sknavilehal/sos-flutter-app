/// SOS Alert model
class SOSAlert {
  final String? id;
  final String senderAlias;
  final String senderMobile;
  final String district;
  final String? message;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;
  final bool isActive; // For tracking if alert is still active

  SOSAlert({
    this.id,
    required this.senderAlias,
    required this.senderMobile,
    required this.district,
    this.message,
    this.latitude,
    this.longitude,
    required this.timestamp,
    this.isActive = true,
  });

  /// Convert to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_alias': senderAlias,
      'sender_mobile': senderMobile,
      'district': district,
      'message': message,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  /// Create from Map (SQLite data)
  factory SOSAlert.fromMap(Map<String, dynamic> map) {
    return SOSAlert(
      id: map['id']?.toString(),
      senderAlias: map['sender_alias'] ?? '',
      senderMobile: map['sender_mobile'] ?? '',
      district: map['district'] ?? '',
      message: map['message'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
      isActive: map['is_active'] == 1,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'sender_alias': senderAlias,
      'sender_mobile': senderMobile,
      'district': district,
      'message': message,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create copy with updated fields
  SOSAlert copyWith({
    String? id,
    String? senderAlias,
    String? senderMobile,
    String? district,
    String? message,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    bool? isActive,
  }) {
    return SOSAlert(
      id: id ?? this.id,
      senderAlias: senderAlias ?? this.senderAlias,
      senderMobile: senderMobile ?? this.senderMobile,
      district: district ?? this.district,
      message: message ?? this.message,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      isActive: isActive ?? this.isActive,
    );
  }
}