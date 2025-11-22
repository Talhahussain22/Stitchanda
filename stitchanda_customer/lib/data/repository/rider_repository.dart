import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rider_model.dart';

class RiderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch rider details by riderId
  Future<RiderModel?> getRiderById(String riderId) async {

    try {
      if (riderId.isEmpty) {
        return null;
      }

      print('🔍 RiderRepository: Fetching rider with ID: $riderId');
      final riderDoc = await _firestore.collection('driver').doc(riderId).get();

      print('📄 RiderRepository: Document exists: ${riderDoc.exists}');

      if (!riderDoc.exists) {
        return null;
      }

      final data = riderDoc.data();

      if (data == null) {
        return null;
      }

      final rider = RiderModel.fromJson(data);
      return rider;

    } catch (e) {
      print('❌ RiderRepository: Error fetching rider: $e');
      throw Exception('Failed to fetch rider: $e');
    }
  }
}

