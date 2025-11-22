class OrderModel {
  final String orderId;
  final String customerId;
  final String? tailorId;
  final String? riderId;
  final double totalPrice;
  int status;
  final String paymentMethod;
  final String paymentStatus;
  final Address pickupLocation;
  final Address dropoffLocation;
  final String? deliveryDate;
  final String createdAt;
  final String updatedAt;


  final CustomerInfo? customer;
  final TailorInfo? tailor;


  CustomerInfo? get sender {
    if (status >= 0 && status <= 3) return customer;
    if (status >= 4 && status <= 10) {

      return tailor != null
          ? CustomerInfo(
              id: tailor!.id,
              name: tailor!.name,
              phone: tailor!.phone,
              address: tailor!.address
            )
          : null;
    }
    return null;
  }

  CustomerInfo? get receiver {
    if (status >= 0 && status <= 3) {
      return tailor != null
          ? CustomerInfo(
              id: tailor!.id,
              name: tailor!.name,
              phone: tailor!.phone,
              address: tailor!.address
            )
          : null;
    }
    if (status >= 4 && status <= 10) return customer;
    return null;
  }

  Address get currentPickupLocation {
    if (status >= 0 && status <= 3) return pickupLocation;  // Customer location
    if (status >= 6 && status <= 10) return dropoffLocation; // Tailor location
    return pickupLocation;
  }

  Address get currentDropoffLocation {
    if (status >= 0 && status <= 3) return dropoffLocation; // Tailor location
    if (status >= 6 && status <= 10) return pickupLocation; // Customer location
    return dropoffLocation;
  }

  OrderModel({
    required this.orderId,
    required this.customerId,
    this.tailorId,
    this.riderId,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.pickupLocation,
    required this.dropoffLocation,
    this.deliveryDate,
    required this.createdAt,
    required this.updatedAt,
    // this.orderDetails,
    this.customer,
    this.tailor,
  });


  factory OrderModel.fromJson(Map<String, dynamic> json) {
    double _parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int _parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    Map<String, dynamic> pickup = json['pickup_location'] ?? {};
    Map<String, dynamic> dropoff = json['dropoff_location'] ?? {};

    return OrderModel(
      orderId: json['order_id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      tailorId: json['tailor_id']?.toString(),
      riderId: json['rider_id']?.toString(),
      totalPrice: _parseDouble(json['total_price']),
      status: _parseInt(json['status']),
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      pickupLocation: Address.fromJson(pickup),
      dropoffLocation: Address.fromJson(dropoff),
      deliveryDate: json['delivery_date']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      // Embedded details are filled later in repository
      customer: (json['customer'] is Map<String, dynamic>)
          ? CustomerInfo.fromJson(json['customer'])
          : null,
      tailor: (json['tailor'] is Map<String, dynamic>)
          ? TailorInfo.fromJson(json['tailor'])
          : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'customer_id': customerId,
      'tailor_id': tailorId,
      'rider_id': riderId,
      'total_price': totalPrice,
      'status': status,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'pickup_location': pickupLocation.toJson(),
      'dropoff_location': dropoffLocation.toJson(),
      'delivery_date': deliveryDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
      if (customer != null) 'customer': customer!.toJson(),
      if (tailor != null) 'tailor': tailor!.toJson(),
    };
  }


  OrderModel copyWith({
    String? orderId,
    String? customerId,
    String? tailorId,
    String? riderId,
    double? totalPrice,
    int? status,
    String? paymentMethod,
    String? paymentStatus,
    Address? pickupLocation,
    Address? dropoffLocation,
    String? deliveryDate,
    String? createdAt,
    String? updatedAt,
    // List<OrderDetailModel>? orderDetails,
    CustomerInfo? customer,
    TailorInfo? tailor,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      tailorId: tailorId ?? this.tailorId,
      riderId: riderId ?? this.riderId,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // orderDetails: orderDetails ?? this.orderDetails,
      customer: customer ?? this.customer,
      tailor: tailor ?? this.tailor,
    );
  }

  // Helper method to get status label
  String get statusLabel {
    switch (status) {
      case 0: return 'Unassigned';
      case 1: return 'Assigned';
      case 2: return 'Picked up from Customer';
      case 3: return 'Delivered to Tailor';
      case 4: return 'Received by Tailor';
      case 5: return 'Completed by Tailor';
      case 6: return 'Waiting for Rider';
      case 7: return 'Assigned to Rider';
      case 8: return 'Picked up from Tailor';
      case 9: return 'Delivered to Customer';
      case 10: return 'Received by Customer';
      default: return 'Unknown';
    }
  }

  @override
  String toString() {
    return 'OrderModel(orderId: $orderId, totalPrice: $totalPrice, status: $status, customer: ${customer?.name ?? ''}, tailor: ${tailor?.name ?? ''})';
  }
}

class CustomerInfo {
  final String id;
  final String name;
  final String phone;
  final Address address;

  CustomerInfo({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    Address _extractAddress(Map<String, dynamic> j) {
      final addr = j['address'];
      if (addr is Map<String, dynamic>) {
        return Address.fromJson(addr);
      }
      // Root-level fallback keys
      if (j.containsKey('full_address') || j.containsKey('latitude') || j.containsKey('longitude')) {
        return Address.fromJson(j);
      }
      if (addr is String) {
        return Address(location: addr, latitude: '', longitude: '');
      }
      return Address(location: '', latitude: '', longitude: '');
    }

    return CustomerInfo(
      id: json['customer_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['full_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['phone_number']?.toString() ?? '',
      address: _extractAddress(json),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'address': address.toJson(),
  };
}

class TailorInfo {
  final String id;
  final String name;
  final String phone;
  final Address address;

  TailorInfo({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
  });

  factory TailorInfo.fromJson(Map<String, dynamic> json) {
    Address _extractAddress(Map<String, dynamic> j) {
      final addr = j['address'];
      if (addr is Map<String, dynamic>) {
        return Address.fromJson(addr);
      }
      if (j.containsKey('full_address') || j.containsKey('latitude') || j.containsKey('longitude')) {
        return Address.fromJson(j);
      }
      if (addr is String) {
        return Address(location: addr, latitude: '', longitude: '');
      }
      return Address(location: '', latitude: '', longitude: '');
    }

    return TailorInfo(
      id: json['tailor_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['shop_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['phone_number']?.toString() ?? '',
      address: _extractAddress(json),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'address': address.toJson(),
  };
}

class Address {
  final String location;
  final String latitude;
  final String longitude;

  Address({
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    // Accept different key variants and numeric/string values
    dynamic lat = json['latitude'] ?? json['lat'];
    dynamic lng = json['longitude'] ?? json['lng'] ?? json['Longitude'];
    String toS(dynamic v) => v == null ? '' : v.toString();
    return Address(
      location: json['full_address']?.toString() ?? json['address']?.toString() ?? '',
      latitude: toS(lat),
      longitude: toS(lng),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_address': location,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() => 'Address($location, $latitude, $longitude)';
}
