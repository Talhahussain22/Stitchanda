import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../helper/firebase_error_handler.dart';
import '../models/order_model.dart';

class DriverOrderRepository {

  final _instance=FirebaseAuth.instance;
  final _firestore=FirebaseFirestore.instance;

  Future<List<OrderModel>> fetchUnassignedOrders() async {
    final col = _firestore.collection('order');
    final snapshot = await col.where('status', whereIn: [0, 6]).get();
    final base = snapshot.docs.map((d) => OrderModel.fromJson(d.data())).toList();
    return Future.wait(base.map((o) async {
      final customerSnap = await _firestore.collection('customer').doc(o.customerId).get();
      DocumentSnapshot<Map<String, dynamic>>? tailorSnap;
      if (o.tailorId != null && o.tailorId!.isNotEmpty) {
        tailorSnap = await _firestore.collection('tailor').doc(o.tailorId!).get();
      }
      final customerInfo = (customerSnap.exists && customerSnap.data()!=null)
          ? CustomerInfo.fromJson(customerSnap.data() as Map<String,dynamic>)
          : null;
      final tailorInfo = (tailorSnap!=null && tailorSnap.exists && tailorSnap.data()!=null)
          ? TailorInfo.fromJson(tailorSnap.data() as Map<String,dynamic>)
          : null;
      return o.copyWith(customer: customerInfo, tailor: tailorInfo);
    }));
  }

  Stream<List<OrderModel>> streamUnassignedOrders() {
    final col = _firestore.collection('order');
    final query = col.where('status', whereIn: [0, 6]);
    return query.snapshots().asyncMap((snapshot) async {
      final base = snapshot.docs.map((d) => OrderModel.fromJson(d.data())).toList();
      return Future.wait(base.map((o) async {
        final customerSnap = await _firestore.collection('customer').doc(o.customerId).get();
        DocumentSnapshot<Map<String, dynamic>>? tailorSnap;
        if (o.tailorId != null && o.tailorId!.isNotEmpty) {
          tailorSnap = await _firestore.collection('tailor').doc(o.tailorId!).get();
        }
        final customerInfo = (customerSnap.exists && customerSnap.data()!=null)
            ? CustomerInfo.fromJson(customerSnap.data() as Map<String,dynamic>)
            : null;
        final tailorInfo = (tailorSnap!=null && tailorSnap.exists && tailorSnap.data()!=null)
            ? TailorInfo.fromJson(tailorSnap.data() as Map<String,dynamic>)
            : null;
        return o.copyWith(customer: customerInfo, tailor: tailorInfo);
      }));
    });
  }

  Future<List<OrderModel>> fetchDriverOrders(String riderId) async {
    final col = _firestore.collection('order');
    // First-leg assignments (statuses 1,2) by rider_id
    final firstLegSnap = await col
        .where('rider_id', isEqualTo: riderId)
        .where('status', whereIn: [1, 2])
        .get();
    // Return-leg assignments (statuses 7,8) by drop_off_rider_id
    final returnLegSnap = await col
        .where('drop_off_rider_id', isEqualTo: riderId)
        .where('status', whereIn: [7, 8])
        .get();

    final base = [
      ...firstLegSnap.docs.map((d)=>OrderModel.fromJson(d.data())),
      ...returnLegSnap.docs.map((d)=>OrderModel.fromJson(d.data())),
    ];
    // sort by updated_at if present
    base.sort((a,b)=> b.updatedAt.compareTo(a.updatedAt));

    return Future.wait(base.map((o) async {
      final customerSnap = await _firestore.collection('customer').doc(o.customerId).get();
      DocumentSnapshot<Map<String, dynamic>>? tailorSnap;
      if (o.tailorId != null && o.tailorId!.isNotEmpty) {
        tailorSnap = await _firestore.collection('tailor').doc(o.tailorId!).get();
      }
      final customerInfo = (customerSnap.exists && customerSnap.data()!=null)
          ? CustomerInfo.fromJson(customerSnap.data() as Map<String,dynamic>)
          : null;
      final tailorInfo = (tailorSnap!=null && tailorSnap.exists && tailorSnap.data()!=null)
          ? TailorInfo.fromJson(tailorSnap.data() as Map<String,dynamic>)
          : null;
      return o.copyWith(customer: customerInfo, tailor: tailorInfo);
    }));
  }

  Stream<List<OrderModel>> streamDriverOrders(String riderId) {
    final col = _firestore.collection('order');
    final firstLegQuery = col
        .where('rider_id', isEqualTo: riderId)
        .where('status', whereIn: [1, 2]);

    final returnLegQuery = col
        .where('drop_off_rider_id', isEqualTo: riderId)
        .where('status', whereIn: [7, 8]);

    // Merge two streams
    return firstLegQuery.snapshots().asyncExpand((firstSnap) {
      return returnLegQuery.snapshots().asyncMap((returnSnap) async {
        final base = [
          ...firstSnap.docs.map((d)=>OrderModel.fromJson(d.data())),
          ...returnSnap.docs.map((d)=>OrderModel.fromJson(d.data())),
        ];
        // sort by updated_at string (serverTimestamp string) if comparable
        base.sort((a,b)=> b.updatedAt.compareTo(a.updatedAt));
        return Future.wait(base.map((o) async {
          final customerSnap = await _firestore.collection('customer').doc(o.customerId).get();
          DocumentSnapshot<Map<String, dynamic>>? tailorSnap;
          if (o.tailorId != null && o.tailorId!.isNotEmpty) {
            tailorSnap = await _firestore.collection('tailor').doc(o.tailorId!).get();
          }
          final customerInfo = (customerSnap.exists && customerSnap.data()!=null)
              ? CustomerInfo.fromJson(customerSnap.data() as Map<String,dynamic>)
              : null;
          final tailorInfo = (tailorSnap!=null && tailorSnap.exists && tailorSnap.data()!=null)
              ? TailorInfo.fromJson(tailorSnap.data() as Map<String,dynamic>)
              : null;
          return o.copyWith(customer: customerInfo, tailor: tailorInfo);
        }));
      });
    });
  }

  Future<void> updateOrderStatus(String orderId, int newStatus) async {
    try {
      await _firestore.collection('order').doc(orderId).update({
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorHandler.getErrorMessage(e, context: 'updateOrderStatus');
    }
  }


  Future<void> completeOrder(String orderId, int completionStatus) async {
    String currentRiderId=_instance.currentUser!.uid;
    try {
      await _firestore.collection('order').doc(orderId).update({
        'status': completionStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('driver').doc(currentRiderId).update({
        'is_assigned': 0,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorHandler.getErrorMessage(e, context: 'completeOrder');
    }
  }

  Future<bool> acceptOrder(String orderId) async {
    final String currentRiderId = _instance.currentUser!.uid;
    final orderRef = _firestore.collection('order').doc(orderId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(orderRef);
        if (!snapshot.exists) {
          throw Exception('Order does not exist.');
        }
        final data = snapshot.data() as Map<String, dynamic>;
        final int status = (data['status'] as num).toInt();
        final dynamic rider = data['rider_id'];
        final dynamic dropOffRider = data['drop_off_rider_id'];

        // For first leg (0-5), we assign rider_id when status becomes 1 or 2 path
        // For return leg (6+), we assign drop_off_rider_id when status becomes 7 or 8 path
        final bool isReturnLeg = status >= 6;
        final bool alreadyAssignedFirst = rider != null && rider.toString().isNotEmpty && rider.toString() != 'null';
        final bool alreadyAssignedReturn = dropOffRider != null && dropOffRider.toString().isNotEmpty && dropOffRider.toString() != 'null';

        if (!isReturnLeg) {
          // Expect status == 0 to accept
          if (status != 0 || alreadyAssignedFirst) {
            throw Exception('Order already accepted by another driver.');
          }
          final int newStatus = 1; // Assigned
          transaction.update(orderRef, {
            'rider_id': currentRiderId,
            'status': newStatus,
            'updated_at': FieldValue.serverTimestamp(),
          });
        } else {
          // Expect status == 6 to accept for return leg
          if (status != 6 || alreadyAssignedReturn) {
            throw Exception('Order already accepted by another driver.');
          }
          final int newStatus = 7; // Assigned to Rider for return leg
          transaction.update(orderRef, {
            'drop_off_rider_id': currentRiderId,
            'status': newStatus,
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      });

      await _firestore.collection('driver').doc(currentRiderId).update({
        'is_assigned': 1,
        'updated_at': FieldValue.serverTimestamp(),
      });

      return true;
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorHandler.getErrorMessage(e, context: 'acceptOrder');
    } catch (e) {
      return false;
    }
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('order').doc(orderId).get();
      if (!doc.exists) return null;
      final base = OrderModel.fromJson(doc.data() as Map<String, dynamic>);

      final customerSnap = await _firestore.collection('customer').doc(base.customerId).get();
      DocumentSnapshot<Map<String, dynamic>>? tailorSnap;
      if (base.tailorId != null && base.tailorId!.isNotEmpty) {
        tailorSnap = await _firestore.collection('tailor').doc(base.tailorId!).get();
      }

      final customerInfo = (customerSnap.exists && (customerSnap.data() != null))
          ? CustomerInfo.fromJson(customerSnap.data() as Map<String, dynamic>)
          : null;
      final tailorInfo = (tailorSnap != null && tailorSnap.exists && (tailorSnap.data() != null))
          ? TailorInfo.fromJson(tailorSnap.data() as Map<String, dynamic>)
          : null;



      return base.copyWith(customer: customerInfo, tailor: tailorInfo);
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorHandler.getErrorMessage(e, context: 'getOrderById');
    }
  }



  Stream<List<OrderModel>> streamHistoryOrders(String riderId) {
    final col = _firestore.collection('order');
    // Completed legs for both directions
    final firstLegQuery = col
        .where('rider_id', isEqualTo: riderId)
        .where('status', whereIn: [3]);
    final returnLegQuery = col
        .where('drop_off_rider_id', isEqualTo: riderId)
        .where('status', whereIn: [9]);

    return firstLegQuery.snapshots().asyncExpand((firstSnap) {
      return returnLegQuery.snapshots().asyncMap((returnSnap) async {
        final base = [
          ...firstSnap.docs.map((d)=>OrderModel.fromJson(d.data())),
          ...returnSnap.docs.map((d)=>OrderModel.fromJson(d.data())),
        ];
        base.sort((a,b)=> b.updatedAt.compareTo(a.updatedAt));
        return Future.wait(base.map((o) async {
          final customerSnap = await _firestore.collection('customer').doc(o.customerId).get();
          DocumentSnapshot<Map<String, dynamic>>? tailorSnap;
          if (o.tailorId != null && o.tailorId!.isNotEmpty) {
            tailorSnap = await _firestore.collection('tailor').doc(o.tailorId!).get();
          }
          final customerInfo = (customerSnap.exists && customerSnap.data()!=null)
              ? CustomerInfo.fromJson(customerSnap.data() as Map<String,dynamic>)
              : null;
          final tailorInfo = (tailorSnap!=null && tailorSnap.exists && tailorSnap.data()!=null)
              ? TailorInfo.fromJson(tailorSnap.data() as Map<String,dynamic>)
              : null;
          return o.copyWith(customer: customerInfo, tailor: tailorInfo);
        }));
      });
    });
  }

  Future<Map<String, int>> getCompletedKpis(String riderId) async {
    final col = _firestore.collection('order');
    final firstSnap = await col
        .where('rider_id', isEqualTo: riderId)
        .where('status', whereIn: [3])
        .get();
    final returnSnap = await col
        .where('drop_off_rider_id', isEqualTo: riderId)
        .where('status', whereIn: [9])
        .get();

    final all = [
      ...firstSnap.docs,
      ...returnSnap.docs,
    ];

    int total = 0;
    int today = 0;
    int last7 = 0;

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    for (final doc in all) {
      final data = doc.data();
      DateTime ts;
      final updated = data['updated_at'];
      final created = data['created_at'];
      if (updated is Timestamp) {
        ts = updated.toDate();
      } else if (created is Timestamp) {
        ts = created.toDate();
      } else {
        // If no timestamp, count toward total but not date-bounded metrics
        total += 1;
        continue;
      }
      total += 1;
      if (ts.isAfter(startOfToday)) today += 1;
      if (ts.isAfter(sevenDaysAgo)) last7 += 1;
    }

    return {
      'today': today,
      'week': last7,
      'total': total,
    };
  }

}
