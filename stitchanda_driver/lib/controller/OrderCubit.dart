import 'dart:async';
import 'dart:math' as math;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stichanda_driver/data/models/order_model.dart';
import 'package:stichanda_driver/data/repository/order_repo.dart';

import '../helper/firebase_error_handler.dart';

class OrderState extends Equatable {
  final bool isLoading;
  final List<OrderModel> orders;
  final OrderModel? currentOrder;
  final String? errorMessage;
  final OrderModel? selectedOrder;
  final int todaysOrderCount;
  final int totalOrderCount;
  final int weeklyOrderCount;
  const OrderState({
    this.isLoading = false,
    this.orders = const [],
    this.errorMessage,
    this.selectedOrder,
    this.currentOrder,
    this.todaysOrderCount = 0,
    this.weeklyOrderCount = 0,
    this.totalOrderCount = 0,
  });

  OrderState copyWith({
    bool? isLoading,
    List<OrderModel>? orders,
    String? errorMessage,
    OrderModel? selectedOrder,
    OrderModel? currentOrder,
    bool clearCurrentOrder = false,
    int? todaysOrderCount,
    int? weeklyOrderCount,
    int? totalOrderCount,
  }) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      errorMessage: errorMessage,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      currentOrder: clearCurrentOrder ? null : (currentOrder ?? this.currentOrder),
      todaysOrderCount: todaysOrderCount ?? this.todaysOrderCount,
      weeklyOrderCount: weeklyOrderCount ?? this.weeklyOrderCount,
      totalOrderCount: totalOrderCount ?? this.totalOrderCount,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    orders,
    errorMessage,
    selectedOrder,
    currentOrder,
    todaysOrderCount,
    weeklyOrderCount,
    totalOrderCount,
  ];
}

class OrderCubit extends Cubit<OrderState> {
  final DriverOrderRepository _orderRepository;
  StreamSubscription<List<OrderModel>>? _unassignedSub;
  StreamSubscription<List<OrderModel>>? _assignedSub;
  StreamSubscription<List<OrderModel>>? _historySub;

  // Cache of driver's current location for filtering
  double? _filterLat;
  double? _filterLng;
  static const double _maxDistanceKm = 5.0;

  OrderCubit({required DriverOrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(const OrderState());

  // Haversine distance in km
  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371.0; // Earth radius in km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (math.pi / 180.0);

  bool _isWithinRadius(OrderModel o) {
    print('aay');
    if (_filterLat == null || _filterLng == null) return true; // no filter available
    final latStr = o.pickupLocation.latitude;
    final lngStr = o.pickupLocation.longitude;
    final lat = double.tryParse(latStr);
    final lng = double.tryParse(lngStr);
    if (lat == null || lng == null) return false;
    final dist = _distanceKm(_filterLat!, _filterLng!, lat, lng);
    print('distance: $dist km');
    return dist < _maxDistanceKm;
  }

  void subscribeToUnassignedOrders({double? currentLat, double? currentLng}) {

    if (currentLat != null && currentLng != null) {
      if (currentLat.abs() > 0.0001 || currentLng.abs() > 0.0001) {
        _filterLat = currentLat;
        _filterLng = currentLng;
      }
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));
    _unassignedSub?.cancel();
    _unassignedSub = _orderRepository
        .streamUnassignedOrders()
        .listen((orders) {

      final filtered = orders.where(_isWithinRadius).toList();

      emit(state.copyWith(isLoading: false, orders: filtered, errorMessage: null));
    }, onError: (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    });
  }

  Future<void> refreshKpis() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final kpis = await _orderRepository.getCompletedKpis(uid);

      emit(state.copyWith(
        todaysOrderCount: kpis['today'] ?? 0,
        weeklyOrderCount: kpis['week'] ?? 0,
        totalOrderCount: kpis['total'] ?? 0,
      ));

    } catch (_) {
    }
  }

  void subscribeToCurrentOrder() {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(state.copyWith(isLoading: false, clearCurrentOrder: true));
      return;
    }
    _assignedSub?.cancel();
    _assignedSub = _orderRepository
        .streamDriverOrders(user.uid)
        .listen((orders) {
      final current = orders.isNotEmpty ? orders.first : null;
      emit(state.copyWith(
        isLoading: false,
        currentOrder: current,
        clearCurrentOrder: current == null,
      ));
      refreshKpis();
    }, onError: (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    });
    refreshKpis();
  }

  void subscribeToHistory() {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }
    _historySub?.cancel();
    _historySub = _orderRepository.streamHistoryOrders(user.uid).listen((orders) {
      emit(state.copyWith(isLoading: false, orders: orders));
    }, onError: (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    });
  }



  Future<bool> acceptOrder(String orderId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      bool success = await _orderRepository.acceptOrder(orderId);
      if (success) {
        final futures = await Future.wait([
          _orderRepository.fetchUnassignedOrders(),
          _orderRepository.fetchDriverOrders(FirebaseAuth.instance.currentUser!.uid),
        ]);
        var unassigned = futures[0];
        final assigned = futures[1];
        // Apply distance filter to refreshed unassigned orders
        unassigned = unassigned.where(_isWithinRadius).toList();
        final current = assigned.isNotEmpty ? assigned.first : null;

        emit(state.copyWith(
          isLoading: false,
          orders: unassigned,
          currentOrder: current,
          clearCurrentOrder: current == null,
        ));
        return true;
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to accept order',
        ));
        return false;
      }
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: FirebaseErrorHandler.getErrorMessage(e, context: 'acceptOrder'),
      ));
      return false;
    }
    catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  void selectOrder(OrderModel order) {
    emit(state.copyWith(selectedOrder: order));
  }

  Future<void> loadOrderById(String orderId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final order = await _orderRepository.getOrderById(orderId);
      emit(state.copyWith(isLoading: false, selectedOrder: order));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: FirebaseErrorHandler.getErrorMessage(e, context: 'loadOrderById'),
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void updateOrderStatus(String orderId, int newStatus) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      await _orderRepository.updateOrderStatus(orderId, newStatus);
      final updatedOrders = state.orders.map((order) {
        if (order.orderId == orderId) {
          return order.copyWith(status: newStatus);
        }
        return order;
      }).toList();

      final updatedSelected = (state.selectedOrder != null && state.selectedOrder!.orderId == orderId)
          ? state.selectedOrder!.copyWith(status: newStatus)
          : state.selectedOrder;

      OrderModel? updatedCurrent = (state.currentOrder != null && state.currentOrder!.orderId == orderId)
          ? state.currentOrder!.copyWith(status: newStatus)
          : state.currentOrder;

      // If order reached a completion status, clear currentOrder so Home screen no longer shows it
      final bool isCompletion = newStatus == 3 || newStatus == 9 || newStatus == 10;
      emit(state.copyWith(
        isLoading: false,
        orders: updatedOrders,
        selectedOrder: updatedSelected,
        currentOrder: updatedCurrent,
        clearCurrentOrder: isCompletion,
      ));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: FirebaseErrorHandler.getErrorMessage(e, context: 'updateOrderStatus'),
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> completeSelectedOrder(int completionStatus) async {
    final sel = state.selectedOrder;
    if (sel == null) return;
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _orderRepository.completeOrder(sel.orderId, completionStatus);
      final updatedOrders = state.orders.map((o) =>
          o.orderId == sel.orderId ? o.copyWith(status: completionStatus) : o).toList();
      final updatedSelected = sel.copyWith(status: completionStatus);

      // Always clear current order when completion occurs
      emit(state.copyWith(
        isLoading: false,
        orders: updatedOrders,
        selectedOrder: updatedSelected,
        clearCurrentOrder: true,
      ));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: FirebaseErrorHandler.getErrorMessage(e, context: 'completeSelectedOrder'),
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }


  void clearOrders() {
    emit(const OrderState());
  }



  @override
  Future<void> close() {
    _unassignedSub?.cancel();
    _assignedSub?.cancel();
    _historySub?.cancel();
    return super.close();
  }
}
