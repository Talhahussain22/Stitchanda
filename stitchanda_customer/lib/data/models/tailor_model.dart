class Tailor {
  final String id;
  final String? tailor_id;
  final String name;
  final String category;
  final String? gender;
  final String? phone;
  final String? email;
  final String? cnic;
  final int? experience; // in years
  final double? review; // average rating
  final bool? is_verified;
  final String? verification_status; // e.g., pending/approved/rejected
  final bool? availability_status; // now boolean
  final String? image_path; // storage path or URL
  final TailorAddress? address; // nested address
  final DateTime? created_at;
  final DateTime? updated_at;
  final String? stripe_account_id;

  // Backward-compatibility helpers for existing UI
  String get area => address?.fullAddress ?? '';
  String? get imageUrl => image_path; // legacy alias

  final String initials;

  Tailor({
    required this.id,
    this.tailor_id,
    required this.name,
    required this.category,
    this.gender,
    this.phone,
    this.email,
    this.cnic,
    this.experience,
    this.review,
    this.is_verified,
    this.verification_status,
    this.availability_status,
    this.image_path,
    this.address,
    this.created_at,
    this.updated_at,
    this.stripe_account_id,
  }) : initials = _computeInitials(name);

  static String _computeInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  factory Tailor.fromJson(Map<String, dynamic> data) {
    TailorAddress? addr;
    final addrRaw = data['address'];
    if (addrRaw is Map<String, dynamic>) {
      addr = TailorAddress.fromJson(addrRaw);
    }

    DateTime? _toDate(dynamic v) {
      try {
        if (v == null) return null;
        if (v is DateTime) return v;
        if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
        if (v is String) return DateTime.tryParse(v);
        try {
          final toDate = (v as dynamic).toDate as DateTime Function();
          return toDate();
        } catch (_) {}
      } catch (_) {}
      return null;
    }

    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    bool? _toBool(dynamic v) {
      if (v == null) return null;
      if (v is bool) return v;
      if (v is String) {
        final s = v.toLowerCase().trim();
        if (s == 'true' || s == '1' || s == 'yes') return true;
        if (s == 'false' || s == '0' || s == 'no') return false;
      }
      if (v is num) return v != 0;
      return null;
    }

    return Tailor(
      id: (data['id'] ?? data['tailor_id'] ?? '').toString(),
      tailor_id: (data['tailor_id'] ?? data['id'])?.toString(),
      name: (data['name'] ?? '').toString(),
      category: (data['category'] ?? '').toString(),
      gender: (data['gender'])?.toString(),
      phone: (data['phone'])?.toString(),
      email: (data['email'])?.toString(),
      cnic: (data['cnic'])?.toString(),
      experience: _toInt(data['experience']),
      review: _toDouble(data['review']),
      is_verified: data['is_verified'] is bool ? data['is_verified'] as bool : null,
      verification_status: (data['verfication_status'] ?? data['verification_status'])?.toString(),
      availability_status: _toBool(data['availibility_status'] ?? data['availability_status']),
      image_path: (data['image_path'] ?? data['imageUrl'])?.toString(),
      address: addr,
      created_at: _toDate(data['created_at']),
      updated_at: _toDate(data['updated_at']),
      stripe_account_id: (data['stripe_account_id'] ?? data['stripeAccountId'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tailor_id': tailor_id ?? id,
      'name': name,
      'category': category,
      'gender': gender,
      'phone': phone,
      'email': email,
      'cnic': cnic,
      'experience': experience,
      'review': review,
      'is_verified': is_verified,
      'verfication_status': verification_status,
      'availibility_status': availability_status,
      'image_path': image_path,
      'address': address?.toJson(),
      'created_at': created_at?.toIso8601String(),
      'updated_at': updated_at?.toIso8601String(),
      'stripe_account_id': stripe_account_id,
    }..removeWhere((k, v) => v == null);
  }
}

class TailorAddress {
  final String? fullAddress;
  final double? latitude;
  final double? longitude;

  TailorAddress({this.fullAddress, this.latitude, this.longitude});

  factory TailorAddress.fromJson(Map<String, dynamic> map) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return TailorAddress(
      fullAddress: map['full_address']?.toString() ?? map['fullAddress']?.toString(),
      latitude: _toDouble(map['latitude']),
      longitude: _toDouble(map['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_address': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
    }..removeWhere((k, v) => v == null);
  }
}
