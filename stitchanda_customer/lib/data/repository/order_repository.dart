import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/order_details_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createOrder({
    required String customerId,
    required String tailorId,
    String? riderId,
    Location? pickupLocation,
    Location? dropoffLocation,
    required String paymentMethod,
    required String paymentStatus,
    required List<OrderDetailsModel> orderDetails,
    required double totalPrice,
    required DateTime due_date
  }) async {
    try {
      if (customerId.isEmpty) {
        throw Exception('Customer ID is empty');
      }
      if (orderDetails.isEmpty) {
        throw Exception('No order details provided');
      }

      final orderRef = _firestore.collection('order').doc();
      final orderId = orderRef.id;

      final orderData = <String, dynamic>{
        'order_id': orderId,
        'customer_id': customerId,
        'tailor_id': tailorId,
        'rider_id': null,
        'drop_off_rider_id': null, // second leg rider (tailor -> customer) not assigned yet
        'status': -2,
        'total_price': totalPrice,
        'payment_method': paymentMethod,
        'payment_status': paymentStatus,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'delivery_date': null,
      };


      if (pickupLocation != null) {
        orderData['pickup_location'] = {
          'full_address': pickupLocation.fullAddress,
          'latitude': pickupLocation.latitude,
          'longitude': pickupLocation.longitude,
        };
      }

      if (dropoffLocation != null) {
        orderData['dropoff_location'] = {
          'full_address': dropoffLocation.fullAddress,
          'latitude': dropoffLocation.latitude,
          'longitude': dropoffLocation.longitude,
        };
      }

      final batch = _firestore.batch();


      batch.set(orderRef, orderData);


      for (var detail in orderDetails) {
        final detailRef = _firestore.collection('order_details').doc();
        final detailsId = detailRef.id;


        final updatedDetail = detail.copyWith(
          detailsId: detailsId,
          orderId: orderId,
        );

        final detailData = updatedDetail.toJson();
        batch.set(detailRef, detailData);
      }

      await batch.commit();

      return orderId;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }


  Future<List<OrderModel>> getOrdersByStatus(String customerId, int status) async {
    try {
      final ordersSnapshot = await _firestore
           .collection('order')
           .where('customer_id', isEqualTo: customerId)
          .where('status', isEqualTo: status)
          .orderBy('created_at', descending: true)
           .get();

      List<OrderModel> orders = [];

      for (var doc in ordersSnapshot.docs) {
        final data = doc.data();
        final docOrderId = data['order_id'] ?? doc.id;

        // Fetch order details from main order_details collection
        final detailsSnapshot = await _firestore
            .collection('order_details')
            .where('order_id', isEqualTo: docOrderId)
            .get();

        final details = detailsSnapshot.docs
            .map((d) => OrderDetailsModel.fromJson(d.data()))
            .toList();

        final orderMap = Map<String, dynamic>.from(data);
        orderMap['order_id'] = docOrderId;
        orderMap['orderDetails'] = details.map((e) => e.toJson()).toList();

        orders.add(OrderModel.fromJson(orderMap));
      }

      return orders;
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  // Get all orders by customer ID
  Future<List<OrderModel>> getAllOrders(String customerId) async {
    try {
      final ordersSnapshot = await _firestore
          .collection('order')
          .where('customer_id', isEqualTo: customerId)
          .orderBy('created_at', descending: true)
           .get();

      List<OrderModel> orders = [];

      for (var doc in ordersSnapshot.docs) {
        final data = doc.data();
        final docOrderId = data['order_id'] ?? doc.id;

        // Fetch order details from main order_details collection
        final detailsSnapshot = await _firestore
            .collection('order_details')
            .where('order_id', isEqualTo: docOrderId)
            .get();

        final details = detailsSnapshot.docs
            .map((d) => OrderDetailsModel.fromJson(d.data()))
            .toList();

        final orderMap = Map<String, dynamic>.from(data);
        orderMap['order_id'] = docOrderId;
        orderMap['orderDetails'] = details.map((e) => e.toJson()).toList();

        orders.add(OrderModel.fromJson(orderMap));
      }

      return orders;
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, int status) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (status == 2) {
         updates['delivery_date'] = FieldValue.serverTimestamp();
       }

      await _firestore.collection('order').doc(orderId).update(updates);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Get single order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('order').doc(orderId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      final docOrderId = data['order_id'] ?? doc.id;

      // Fetch order details from main order_details collection
      final detailsSnapshot = await _firestore
          .collection('order_details')
          .where('order_id', isEqualTo: docOrderId)
          .get();

      final details = detailsSnapshot.docs
          .map((d) => OrderDetailsModel.fromJson(d.data()))
          .toList();

      final orderMap = Map<String, dynamic>.from(data);
      orderMap['order_id'] = docOrderId;
      orderMap['orderDetails'] = details.map((e) => e.toJson()).toList();

      return OrderModel.fromJson(orderMap);
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  // Mark order as paid and confirmed
  Future<void> markOrderPaidAndConfirmed(String orderId) async {
    try {
      await _firestore.collection('order').doc(orderId).update({
        'payment_status': 'paid',
        'status': 10, // customer confirmed
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark order paid: $e');
    }
  }
}
