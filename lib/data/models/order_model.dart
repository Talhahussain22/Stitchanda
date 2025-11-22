import 'order_details_model.dart';

class Location {
  final String fullAddress;
  final double latitude;
  final double longitude;

  const Location({
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return Location(
      fullAddress: (json['full_address'] ?? json['fullAddress'] ?? '').toString(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_address': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class OrderModel {
  final String orderId;
  final String customerId;
  final String tailorId;
  final String? riderId; // first leg rider (customer -> tailor)
  final String? dropOffRiderId; // second leg rider (tailor -> customer)
  final Location? pickupLocation;
  final Location? dropoffLocation;
  final String paymentMethod;
  final String paymentStatus;
  final int status; // -2 just created, -1 accepted by tailor, 0 awaiting rider, 12 rejected by tailor, etc.
  final double totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deliveryDate;
  final List<OrderDetailsModel> orderDetails;

  OrderModel({
    required this.orderId,
    required this.customerId,
    required this.tailorId,
    this.riderId,
    this.dropOffRiderId,
    this.pickupLocation,
    this.dropoffLocation,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
    this.deliveryDate,
    required this.orderDetails,
  });

  // Helpers
  List<String> get items => orderDetails.map((d) => d.itemType).toList();
  int get itemCount => orderDetails.length;
  // Determine which rider is active based on status range.
  // Status 0..5 use riderId, 6+ use dropOffRiderId.
  String? get activeRiderId => (status >= 0 && status <= 5) ? riderId : dropOffRiderId;
  bool get isSecondLeg => status >= 6;
  String get statusLabel {
    switch (status) {
      case -3:
        return 'Rejected (By Tailor)';
      case -2:
        return 'Awaiting for Tailor\'s Approval';
      case -1:
        return 'Accepted (By Tailor)';
      case 0:
        return 'Awaiting for Rider to Accept';
      case 1:
        return 'Assigned (Rider)';
      case 2:
        return 'Picked Up';
      case 3:
        return 'Delivered';
      case 4:
        return 'Received (Tailor)';
      case 5:
        return 'Dress is Ready';
      case 6:
        return 'Tailor is Looking for a Rider';
      case 7:
        return 'Tailor has Dispatched the Dress';
      case 8:
        return 'Delivered at your Location';
      case 9:
        return 'Awaiting for Payment';
      case 10:
        return 'Completed';
      case 11:
        return 'Self Delivery';
      default:
        return 'Unknown';
    }
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    DateTime _parseDate(dynamic v) {
      try {
        if (v == null) return DateTime.now();
        if (v is DateTime) return v;
        if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
        if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
        final maybe = (v as dynamic);
        try {
          return maybe.toDate() as DateTime;
        } catch (_) {}
      } catch (_) {}
      return DateTime.now();
    }
    double _toDouble(dynamic v) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }
    int _toInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    final detailsRaw = json['orderDetails'] ?? json['order_details'];
    final List<OrderDetailsModel> details = (detailsRaw is List)
        ? detailsRaw
            .where((e) => e != null)
            .map((e) => OrderDetailsModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <OrderDetailsModel>[];

    Location? pickup;
    final pickupMap = json['pickup_location'] ?? json['pickupLocation'];
    if (pickupMap is Map) pickup = Location.fromJson(Map<String, dynamic>.from(pickupMap));

    Location? dropoff;
    final dropoffMap = json['dropoff_location'] ?? json['dropoffLocation'];
    if (dropoffMap is Map) dropoff = Location.fromJson(Map<String, dynamic>.from(dropoffMap));

    return OrderModel(
      orderId: (json['order_id'] ?? json['orderId'] ?? json['id'] ?? '').toString(),
      customerId: (json['customer_id'] ?? json['customerId'] ?? '').toString(),
      tailorId: (json['tailor_id'] ?? json['tailorId'] ?? '').toString(),
      riderId: (json['rider_id'] ?? json['riderId'])?.toString(),
      dropOffRiderId: (json['drop_off_rider_id'] ?? json['dropOffRiderId'])?.toString(),
      pickupLocation: pickup,
      dropoffLocation: dropoff,
      paymentMethod: (json['payment_method'] ?? json['paymentMethod'] ?? '').toString(),
      paymentStatus: (json['payment_status'] ?? json['paymentStatus'] ?? '').toString(),
      status: _toInt(json['status']),
      totalPrice: _toDouble(json['total_price'] ?? json['totalPrice']),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
      deliveryDate: (json['delivery_date'] ?? json['deliveryDate']) != null
          ? _parseDate(json['delivery_date'] ?? json['deliveryDate'])
          : null,
      orderDetails: details,
    );
  }

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'customer_id': customerId,
        'tailor_id': tailorId,
        'rider_id': riderId,
        'drop_off_rider_id': dropOffRiderId,
        'pickup_location': pickupLocation?.toJson(),
        'dropoff_location': dropoffLocation?.toJson(),
        'payment_method': paymentMethod,
        'payment_status': paymentStatus,
        'status': status,
        'total_price': totalPrice,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'delivery_date': deliveryDate?.toIso8601String(),
        'orderDetails': orderDetails.map((e) => e.toJson()).toList(),
      }..removeWhere((k, v) => v == null);

  OrderModel copyWith({
    String? orderId,
    String? customerId,
    String? tailorId,
    String? riderId,
    String? dropOffRiderId,
    Location? pickupLocation,
    Location? dropoffLocation,
    String? paymentMethod,
    String? paymentStatus,
    int? status,
    double? totalPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deliveryDate,
    List<OrderDetailsModel>? orderDetails,
  }) => OrderModel(
        orderId: orderId ?? this.orderId,
        customerId: customerId ?? this.customerId,
        tailorId: tailorId ?? this.tailorId,
        riderId: riderId ?? this.riderId,
        dropOffRiderId: dropOffRiderId ?? this.dropOffRiderId,
        pickupLocation: pickupLocation ?? this.pickupLocation,
        dropoffLocation: dropoffLocation ?? this.dropoffLocation,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        status: status ?? this.status,
        totalPrice: totalPrice ?? this.totalPrice,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deliveryDate: deliveryDate ?? this.deliveryDate,
        orderDetails: orderDetails ?? this.orderDetails,
      );

  @override
  String toString() => 'OrderModel(orderId: $orderId, status: $status, total: $totalPrice)';

  @override
  bool operator ==(Object other) => identical(this, other) || (other is OrderModel && other.orderId == orderId);

  @override
  int get hashCode => orderId.hashCode;
}
