import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tailor_model.dart';

class TailorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Tailor>> getAllTailors() async {
    try {
      final snapshot = await _firestore.collection('tailor').get();
      final tailors = snapshot.docs.map((doc) {
        final data = doc.data();
        final json = Map<String, dynamic>.from(data);
        // Always use document ID as the primary identifier
        json['id'] = doc.id;
        // Set tailor_id to document ID if it's missing or invalid
        if (json['tailor_id'] == null || json['tailor_id'] == 'tailorid' || json['tailor_id'] == '') {
          json['tailor_id'] = doc.id;
        }
        return Tailor.fromJson(json);
      }).toList();
      return tailors;
    } catch (e) {
      try {
        final snapshot = await _firestore.collection('tailors').get();
        final tailors = snapshot.docs.map((doc) {
          final data = doc.data();
          final json = Map<String, dynamic>.from(data);
          // Always use document ID as the primary identifier
          json['id'] = doc.id;
          // Set tailor_id to document ID if it's missing or invalid
          if (json['tailor_id'] == null || json['tailor_id'] == 'tailorid' || json['tailor_id'] == '') {
            json['tailor_id'] = doc.id;
          }
          return Tailor.fromJson(json);
        }).toList();
        return tailors;
      } catch (_) {
        rethrow;
      }
    }
  }

  Future<Tailor?> getTailorById(String tailorId) async {
    try {
      final doc = await _firestore.collection('tailor').doc(tailorId).get();
      if (!doc.exists) return null;
      final data = doc.data()!..putIfAbsent('id', () => doc.id);
      return Tailor.fromJson(data);
    } catch (_) {
      try {
        final doc = await _firestore.collection('tailors').doc(tailorId).get();
        if (!doc.exists) return null;
        final data = doc.data()!..putIfAbsent('id', () => doc.id);
        return Tailor.fromJson(data);
      } catch (e) {
        return null;
      }
    }
  }
}
