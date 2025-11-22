import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/repository/order_repository.dart';
import '../data/models/order_model.dart';
import '../data/models/order_details_model.dart';

// Order State
abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<OrderModel> inProgressOrders;
  final List<OrderModel> completedOrders;

  const OrdersLoaded({
    required this.inProgressOrders,
    required this.completedOrders,
  });

  @override
  List<Object?> get props => [inProgressOrders, completedOrders];
}

class OrderCreating extends OrderState {}

class OrderCreated extends OrderState {
  final String orderId;

  const OrderCreated(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}

// Order Cubit
class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _orderRepository;

  OrderCubit(this._orderRepository) : super(OrderInitial());

  // Load orders by customer ID
  Future<void> loadOrders(String customerId) async {
    try {
      emit(OrderLoading());

      // Define status groups
      const inProgressStatuses = [-3, -2, -1, 0, 1, 2, 3, 5, 4, 6, 7, 8, 9];
      const completedStatuses = [10, 11];

      final List<OrderModel> inProgressOrders = [];
      for (final s in inProgressStatuses) {
        final list = await _orderRepository.getOrdersByStatus(customerId, s);
        inProgressOrders.addAll(list);
      }
      inProgressOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final List<OrderModel> completedOrders = [];
      for (final s in completedStatuses) {
        final list = await _orderRepository.getOrdersByStatus(customerId, s);
        completedOrders.addAll(list);
      }
      completedOrders.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      emit(OrdersLoaded(
        inProgressOrders: inProgressOrders,
        completedOrders: completedOrders,
      ));
    } catch (e) {
      print('Error loading orders: $e');
      emit(OrderError(e.toString()));
    }
  }

  // Create a new order
  Future<void> createOrder({
    required String customerId,
    required String tailorId,
    String? riderId,
    Location? pickupLocation,
    Location? dropoffLocation,
    required String paymentMethod,
    required String paymentStatus,
    required List<OrderDetailsModel> orderDetails,
    required double totalPrice,
    required DateTime due_date,
  }) async {
    try {
      emit(OrderCreating());

      final orderId = await _orderRepository.createOrder(
        customerId: customerId,
        tailorId: tailorId,
        riderId: riderId,
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        orderDetails: orderDetails,
        totalPrice: totalPrice,
        due_date: due_date,
      );

      emit(OrderCreated(orderId));

      // Reload orders after creating
      await loadOrders(customerId);
    } catch (e) {
      print('Error creating order: $e');
      emit(OrderError(e.toString()));
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String customerId, String orderId, int status) async {
    try {
      await _orderRepository.updateOrderStatus(orderId, status);

      // Reload orders after updating
      await loadOrders(customerId);
    } catch (e) {
      print('Error updating order status: $e');
      emit(OrderError(e.toString()));
    }
  }

  // Mark order as delivered
  Future<void> markAsDelivered(String customerId, String orderId) async {
    await updateOrderStatus(customerId, orderId, 2);
  }

  // Refresh orders
  Future<void> refreshOrders(String customerId) async {
    await loadOrders(customerId);
  }

  // Finalize payment
  Future<void> finalizePayment(String customerId, String orderId) async {
    try {
      await _orderRepository.markOrderPaidAndConfirmed(orderId);
      await loadOrders(customerId);
    } catch (e) {
      emit(OrderError('Payment finalize failed: $e'));
    }
  }
}
