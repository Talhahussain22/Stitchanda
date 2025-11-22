class Address {
  final String fullAddress;
  final double latitude;
  final double longitude;

  const Address({
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }
    return Address(
      fullAddress: (json['fullAddress'] ?? json['full_address'] ?? '').toString(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() => {
        'fullAddress': fullAddress,
        'latitude': latitude,
        'longitude': longitude,
      };
}

class CustomerModel {
  final String customerId;
  final String name;
  final String gender;
  final String email;
  final String phone;
  final String profileImagePath; // can be empty string if not set
  final Address address;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomerModel({
    required this.customerId,
    required this.name,
    required this.gender,
    required this.email,
    required this.phone,
    required this.profileImagePath,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  static DateTime _parseDate(dynamic v, {required DateTime fallback}) {
    try {
      if (v == null) return fallback;
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v) ?? fallback;
      if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
      // Firestore Timestamp support
      final maybe = (v as dynamic);
      try {
        final toDate = maybe.toDate as DateTime Function();
        return toDate();
      } catch (_) {}
    } catch (_) {}
    return fallback;
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final addrRaw = json['address'] is Map ? Map<String, dynamic>.from(json['address']) : <String, dynamic>{};
    final addr = Address.fromJson(addrRaw);
    final now = DateTime.now();
    final created = _parseDate(json['createdAt'] ?? json['created_at'], fallback: now);
    final updated = _parseDate(json['updatedAt'] ?? json['updated_at'], fallback: created);

    return CustomerModel(
      customerId: (json['customerId'] ?? json['customer_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      profileImagePath: (json['profileImagePath'] ?? json['profile_image_path'] ?? '').toString(),
      address: addr,
      createdAt: created,
      updatedAt: updated,
    );
  }

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'name': name,
        'gender': gender,
        'email': email,
        'phone': phone,
        'profileImagePath': profileImagePath,
        'address': address.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  CustomerModel copyWith({
    String? customerId,
    String? name,
    String? gender,
    String? email,
    String? phone,
    String? profileImagePath,
    Address? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CustomerModel(
        customerId: customerId ?? this.customerId,
        name: name ?? this.name,
        gender: gender ?? this.gender,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        profileImagePath: profileImagePath ?? this.profileImagePath,
        address: address ?? this.address,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() => 'CustomerModel(customerId: $customerId, name: $name, email: $email)';
}
