// Fabric nested model
class Fabric {
  final String? shirtFabric;
  final String? trouserFabric;
  final String? dupataFabric;

  const Fabric({
    this.shirtFabric,
    this.trouserFabric,
    this.dupataFabric,
  });

  factory Fabric.fromJson(Map<String, dynamic> json) {
    return Fabric(
      shirtFabric: json['shirt_fabric']?.toString(),
      trouserFabric: json['trouser_fabric']?.toString(),
      dupataFabric: json['dupata_fabric']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shirt_fabric': shirtFabric,
      'trouser_fabric': trouserFabric,
      'dupata_fabric': dupataFabric,
    }..removeWhere((k, v) => v == null);
  }
}

// Measurements nested model
class Measurements {
  final double? armLength;
  final double? chest;
  final double? shoulder;
  final double? waist;
  final double? hips;
  final double? wrist;
  final String? fittingPreferences;

  const Measurements({
    this.armLength,
    this.chest,
    this.shoulder,
    this.waist,
    this.hips,
    this.wrist,
    this.fittingPreferences,
  });

  factory Measurements.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return Measurements(
      armLength: json['arm_length'] != null ? _toDouble(json['arm_length']) : null,
      chest: json['chest'] != null ? _toDouble(json['chest']) : null,
      shoulder: json['shoulder'] != null ? _toDouble(json['shoulder']) : null,
      waist: json['waist'] != null ? _toDouble(json['waist']) : null,
      hips: json['hips'] != null ? _toDouble(json['hips']) : null,
      wrist: json['wrist'] != null ? _toDouble(json['wrist']) : null,
      fittingPreferences: json['fitting_preferences']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arm_length': armLength,
      'chest': chest,
      'shoulder': shoulder,
      'waist': waist,
      'hips': hips,
      'wrist': wrist,
      'fitting_preferences': fittingPreferences,
    }..removeWhere((k, v) => v == null);
  }
}

// Main OrderDetailsModel
class OrderDetailsModel {
  final String detailsId;
  final String orderId;
  final String tailorId;
  final String customerName;
  final String? description;
  final String? imagePath;
  final Fabric? fabric;
  final Measurements? measurements;
  final double price;
  final double? totalPrice;
  final String? dueData; // Note: Firebase has "due_data" - keeping as-is from schema

  OrderDetailsModel({
    required this.detailsId,
    required this.orderId,
    required this.tailorId,
    required this.customerName,
    this.description,
    this.imagePath,
    this.fabric,
    this.measurements,
    required this.price,
    this.totalPrice,
    this.dueData,
  });

  // Helpers for backward compatibility
  String get id => detailsId;
  String get itemType => description ?? 'Order Item';
  String get clothType => fabric?.shirtFabric ?? fabric?.trouserFabric ?? fabric?.dupataFabric ?? 'N/A';

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    // Parse nested fabric
    Fabric? fabric;
    if (json['fabric'] is Map) {
      fabric = Fabric.fromJson(Map<String, dynamic>.from(json['fabric']));
    }

    // Parse nested measurements
    Measurements? measurements;
    if (json['measurements'] is Map) {
      measurements = Measurements.fromJson(Map<String, dynamic>.from(json['measurements']));
    }

    return OrderDetailsModel(
      detailsId: (json['details_id'] ?? json['detailsId'] ?? json['id'] ?? '').toString(),
      orderId: (json['order_id'] ?? json['orderId'] ?? '').toString(),
      tailorId: (json['tailor_id'] ?? json['tailorId'] ?? '').toString(),
      customerName: (json['customer_name'] ?? json['customerName'] ?? '').toString(),
      description: json['description']?.toString(),
      imagePath: json['image_path']?.toString(),
      fabric: fabric,
      measurements: measurements,
      price: _toDouble(json['price']),
      totalPrice: json['totalprice'] != null ? _toDouble(json['totalprice']) : null,
      dueData: json['due_data']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'details_id': detailsId,
      'order_id': orderId,
      'tailor_id': tailorId,
      'customer_name': customerName,
      'description': description,
      'image_path': imagePath,
      'fabric': fabric?.toJson(),
      'measurements': measurements?.toJson(),
      'price': price,
      'totalprice': totalPrice,
      'due_data': dueData,
    }..removeWhere((k, v) => v == null);
  }

  OrderDetailsModel copyWith({
    String? detailsId,
    String? orderId,
    String? tailorId,
    String? customerName,
    String? description,
    String? imagePath,
    Fabric? fabric,
    Measurements? measurements,
    double? price,
    double? totalPrice,
    String? dueData,
  }) {
    return OrderDetailsModel(
      detailsId: detailsId ?? this.detailsId,
      orderId: orderId ?? this.orderId,
      tailorId: tailorId ?? this.tailorId,
      customerName: customerName ?? this.customerName,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      fabric: fabric ?? this.fabric,
      measurements: measurements ?? this.measurements,
      price: price ?? this.price,
      totalPrice: totalPrice ?? this.totalPrice,
      dueData: dueData ?? this.dueData,
    );
  }

  @override
  String toString() {
    return 'OrderDetailsModel(detailsId: $detailsId, orderId: $orderId, customerName: $customerName, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderDetailsModel && other.detailsId == detailsId;
  }

  @override
  int get hashCode => detailsId.hashCode;
}
