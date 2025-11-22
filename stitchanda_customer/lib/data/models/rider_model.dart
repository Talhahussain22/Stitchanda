class RiderModel {
  final String riderId;
  final String name;
  final String? photoUrl;
  final String? phoneNumber;
  final double? currentLatitude;
  final double? currentLongitude;

  const RiderModel({
    required this.riderId,
    required this.name,
    this.photoUrl,
    this.phoneNumber,
    this.currentLatitude,
    this.currentLongitude,
  });

  factory RiderModel.fromJson(Map<String, dynamic> json) {
    print('🔍 RiderModel.fromJson: Parsing JSON data: $json');

    // Helper function to convert to double
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    final riderId = (json['driver_id'] ?? json['riderId'] ?? json['id'] ?? '').toString();
    final name = (json['name'] ?? json['rider_name'] ?? '').toString();
    final photoUrl = json['image_path'] ?? json['photoUrl'] ?? json['profile_picture'];
    final phoneNumber = json['phone'] ?? json['phoneNumber'];

    // Parse nested current_location object
    double? currentLatitude;
    double? currentLongitude;

    if (json['current_location'] != null && json['current_location'] is Map) {
      final locationData = json['current_location'] as Map<String, dynamic>;
      currentLatitude = _toDouble(locationData['latitude']);
      currentLongitude = _toDouble(locationData['longitude']);
      print('📍 Found current_location: lat=$currentLatitude, lng=$currentLongitude');
    } else {
      // Fallback to direct fields if current_location doesn't exist
      currentLatitude = _toDouble(json['current_latitude'] ?? json['currentLatitude'] ?? json['latitude']);
      currentLongitude = _toDouble(json['current_longitude'] ?? json['currentLongitude'] ?? json['longitude']);
      print('📍 Using fallback location: lat=$currentLatitude, lng=$currentLongitude');
    }

    print('📝 RiderModel.fromJson: riderId=$riderId, name=$name, photoUrl=$photoUrl, phoneNumber=$phoneNumber, lat=$currentLatitude, lng=$currentLongitude');

    return RiderModel(
      riderId: riderId,
      name: name,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      currentLatitude: currentLatitude,
      currentLongitude: currentLongitude,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'driver_id': riderId,
      'name': name,
      'image_path': photoUrl,
      'phone': phoneNumber,
    };

    // Add nested current_location if both coordinates are available
    if (currentLatitude != null && currentLongitude != null) {
      json['current_location'] = {
        'latitude': currentLatitude,
        'longitude': currentLongitude,
      };
    }

    return json..removeWhere((k, v) => v == null);
  }

  @override
  String toString() => 'RiderModel(riderId: $riderId, name: $name)';

  @override
  bool operator ==(Object other) => identical(this, other) || (other is RiderModel && other.riderId == riderId);

  @override
  int get hashCode => riderId.hashCode;
}

