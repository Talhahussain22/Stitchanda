class OrderDetailModel {
  final String detailsId;
  final String orderId;
  final String tailorId;
  final String customerName;
  final String description;
  final String dueDate;
  final Fabric fabric;
  final Measurements measurements;
  final String imagePath;
  final double price;
  final double totalPrice;

  OrderDetailModel({
    required this.detailsId,
    required this.orderId,
    required this.tailorId,
    required this.customerName,
    required this.description,
    required this.dueDate,
    required this.fabric,
    required this.measurements,
    required this.imagePath,
    required this.price,
    required this.totalPrice,
  });


  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      detailsId: json['details_id'] ?? '',
      orderId: json['order_id'] ?? '',
      tailorId: json['tailor_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['due_date'] ?? json['due_data'] ?? '', // handle typo
      fabric: Fabric.fromJson(json['fabric'] ?? {}),
      measurements: Measurements.fromJson(json['measurements'] ?? {}),
      imagePath: json['image_path'] ?? '',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price'].toString()) ?? 0.0,
      totalPrice: (json['totalprice'] is num)
          ? (json['totalprice'] as num).toDouble()
          : double.tryParse(json['totalprice'].toString()) ?? 0.0,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'details_id': detailsId,
      'order_id': orderId,
      'tailor_id': tailorId,
      'customer_name': customerName,
      'description': description,
      'due_date': dueDate,
      'fabric': fabric.toJson(),
      'measurements': measurements.toJson(),
      'image_path': imagePath,
      'price': price,
      'totalprice': totalPrice,
    };
  }


  OrderDetailModel copyWith({
    String? detailsId,
    String? orderId,
    String? tailorId,
    String? customerName,
    String? description,
    String? dueDate,
    Fabric? fabric,
    Measurements? measurements,
    String? imagePath,
    double? price,
    double? totalPrice,
  }) {
    return OrderDetailModel(
      detailsId: detailsId ?? this.detailsId,
      orderId: orderId ?? this.orderId,
      tailorId: tailorId ?? this.tailorId,
      customerName: customerName ?? this.customerName,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      fabric: fabric ?? this.fabric,
      measurements: measurements ?? this.measurements,
      imagePath: imagePath ?? this.imagePath,
      price: price ?? this.price,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  String toString() {
    return 'OrderDetailModel(detailsId: $detailsId, orderId: $orderId, tailorId: $tailorId, customerName: $customerName, price: $price, totalPrice: $totalPrice)';
  }
}
class Fabric {
  final String dupattaFabric;
  final String shirtFabric;
  final String trouserFabric;

  Fabric({
    required this.dupattaFabric,
    required this.shirtFabric,
    required this.trouserFabric,
  });

  factory Fabric.fromJson(Map<String, dynamic> json) {
    return Fabric(
      dupattaFabric: json['dupata_fabric'] ?? json['dupatta_fabric'] ?? '',
      shirtFabric: json['shirt_fabric'] ?? '',
      trouserFabric: json['trouser_fabric'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dupata_fabric': dupattaFabric,
      'shirt_fabric': shirtFabric,
      'trouser_fabric': trouserFabric,
    };
  }

  @override
  String toString() =>
      'Fabric(dupatta: $dupattaFabric, shirt: $shirtFabric, trouser: $trouserFabric)';
}

class Measurements {
  final double armLength;
  final double chest;
  final double hips;
  final double shoulder;
  final double waist;
  final double wrist;
  final String fittingPreferences;

  Measurements({
    required this.armLength,
    required this.chest,
    required this.hips,
    required this.shoulder,
    required this.waist,
    required this.wrist,
    required this.fittingPreferences,
  });

  factory Measurements.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Measurements(
      armLength: _toDouble(json['arm_length']),
      chest: _toDouble(json['chest']),
      hips: _toDouble(json['hips']),
      shoulder: _toDouble(json['shoulder']),
      waist: _toDouble(json['waist']),
      wrist: _toDouble(json['wrist']),
      fittingPreferences: json['fitting_preferences'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arm_length': armLength,
      'chest': chest,
      'hips': hips,
      'shoulder': shoulder,
      'waist': waist,
      'wrist': wrist,
      'fitting_preferences': fittingPreferences,
    };
  }

  @override
  String toString() => 'Measurements(chest: $chest, waist: $waist, shoulder: $shoulder)';
}
