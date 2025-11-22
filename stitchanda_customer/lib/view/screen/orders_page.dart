import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../controller/payment_cubit.dart';
import '../base/bottom_nav_scaffold.dart';
import '../../data/models/order_model.dart';
import '../../controller/order_cubit.dart';
import '../../controller/auth_cubit.dart';
import '../../controller/rider_cubit.dart';
import '../../modules/chat/cubit/chat_cubit.dart';
import '../../modules/chat/screens/chat_screen.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  double? _driverLat;
  double? _driverLng;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final authCubit = context.read<AuthCubit>();
    final customer = authCubit.currentCustomer;

    if (customer != null) {
      context.read<OrderCubit>().loadOrders(customer.customerId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inShell = context.findAncestorWidgetOfExactType<BottomNavScaffold>() != null;
    if (!inShell) {
      return const BottomNavScaffold(initialIndex: 3);
    }

    final accent = const Color(0xFFD29356);

    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading || state is OrderInitial) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Orders',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
            ),
            body: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD29356)),
              ),
            ),
          );
        }

        List<OrderModel> inProgressOrders = [];
        List<OrderModel> completedOrders = [];

        if (state is OrdersLoaded) {
          inProgressOrders = state.inProgressOrders;
          completedOrders = state.completedOrders;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Orders',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadOrders,
                tooltip: 'Refresh',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: accent,
              unselectedLabelColor: Colors.grey,
              indicatorColor: accent,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              tabs: [
                Tab(
                  text: 'In Progress (${inProgressOrders.length})',
                ),
                Tab(
                  text: 'Completed (${completedOrders.length})',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              RefreshIndicator(
                onRefresh: _loadOrders,
                color: accent,
                child: _buildOrdersList(inProgressOrders, accent, isInProgress: true),
              ),
              RefreshIndicator(
                onRefresh: _loadOrders,
                color: accent,
                child: _buildOrdersList(completedOrders, accent, isInProgress: false),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders, Color accent, {required bool isInProgress}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isInProgress ? Icons.hourglass_empty : Icons.check_circle_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isInProgress ? 'No orders in progress' : 'No completed orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isInProgress ? 'Place an order to get started' : 'Your completed orders will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index], accent, isInProgress);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order, Color accent, bool isInProgress) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showOrderDetails(order, accent, isInProgress),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order status pill
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: order.status == 12
                          ? Colors.red.withValues(alpha: 0.1)
                          : isInProgress ? accent.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: order.status == 12
                            ? Colors.red
                            : isInProgress ? accent : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tailor Info
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5E6D7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(order.tailorId),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tailor: ${order.tailorId}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Order Items: ${order.itemCount}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),


              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: order.items.map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isInProgress ? 'Created' : 'Delivered',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isInProgress
                            ? _formatDate(order.createdAt)
                            : _formatDate(order.deliveryDate ?? order.updatedAt),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isInProgress ? accent : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Price',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'PKR ${order.totalPrice}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Distance & rider cost (only if we have both pickup and dropoff coordinates)
              Builder(builder: (context) {
                final pickup = order.pickupLocation;
                final drop = order.dropoffLocation;
                if (pickup == null || drop == null) {
                  return const SizedBox.shrink();
                }
                final distanceKm = _calculateDistanceKm(pickup.latitude,pickup.longitude, drop.latitude, drop.longitude);
                final riderPrice = (distanceKm * 30).ceil();
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[200]!)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.route, size: 18, color: accent),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Distance: ${distanceKm.toStringAsFixed(2)} km',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            'Est. Rider: PKR $riderPrice',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: accent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Pickup: ${pickup.fullAddress}',
                              style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Drop: ${drop.fullAddress}',
                              style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Open in Maps',
                            icon: const Icon(Icons.location_on_outlined, color: Colors.blueAccent),
                            onPressed: () async {
                              await _ensureDriverLocation(fallbackLat: pickup.latitude, fallbackLng: pickup.longitude);
                              final name = drop.fullAddress;
                              await _openGoogleMaps(drop.latitude, drop.longitude, name);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              // Action buttons based on status (-1 or 9)
              const SizedBox(height: 12),
              _buildOrderActions(context, order, accent),
            ],
          ),
        ),
      ));
  }

  double _calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    final meters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    if (meters.isNaN || meters.isInfinite || meters < 0) return 0.0;
    return meters / 1000.0;
  }

  // Ensure we have origin coordinates; try device location; fallback to pickup
  Future<void> _ensureDriverLocation({double? fallbackLat, double? fallbackLng}) async {
    if (_driverLat != null && _driverLng != null) return;
    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      _driverLat = pos.latitude;
      _driverLng = pos.longitude;
    } catch (_) {
      if (fallbackLat != null && fallbackLng != null) {
        _driverLat = fallbackLat;
        _driverLng = fallbackLng;
      }
    }
  }

  Future<void> _openGoogleMaps(double destLat, double destLng, String destinationName) async {
    if (_driverLat == null || _driverLng == null) return;


    final url = 'https://www.google.com/maps/dir/?api=1&origin=$_driverLat,$_driverLng&destination=$destLat,$destLng&travelmode=driving';
    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch directions to $destinationName')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch directions to $destinationName')),
      );
    }
  }


  Widget _buildOrderActions(BuildContext context, OrderModel order, Color accent) {
    final customerId = context.read<AuthCubit>().currentCustomer?.customerId;
    if (customerId == null) return const SizedBox.shrink();

    // For status 1 or 3 (Assigned to Rider): show rider details button
    if (order.status == 1 && order.riderId != null && order.riderId!.isNotEmpty) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showRiderDetails(order.riderId!, accent, order),
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: const Icon(Icons.two_wheeler),
          label: const Text('See Ride Details', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      );
    }

    // For just created orders: offer rider booking or self delivery
    if (order.status == -1) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                await context.read<OrderCubit>().updateOrderStatus(customerId, order.orderId, 0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Book Rider', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                await context.read<OrderCubit>().updateOrderStatus(customerId, order.orderId, 11);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Self Delivery', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      );
    }

    // For orders delivered to customer (status 9): ask for confirmation to set 10
    if (order.status == 9) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () async {
              final paymentCubit = context.read<PaymentCubit>();
              final usdAmount = order.totalPrice / 280; // same conversion logic
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (sheetCtx) {
                  return BlocConsumer<PaymentCubit, PaymentState>(
                    bloc: paymentCubit,
                    listener: (sheetCtx, payState) async {
                      if (payState is PaymentSuccess) {
                        final customerId = context.read<AuthCubit>().currentCustomer?.customerId;
                        if (customerId != null) {
                          await context.read<OrderCubit>().finalizePayment(customerId, order.orderId);
                        }
                        if (Navigator.of(sheetCtx).canPop()) {
                          Navigator.of(sheetCtx).pop();
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment successful & order confirmed'), backgroundColor: Colors.green),
                        );
                      } else if (payState is PaymentFailure) {
                        ScaffoldMessenger.of(sheetCtx).showSnackBar(
                          SnackBar(content: Text(payState.message), backgroundColor: Colors.red),
                        );
                      }
                    },
                    builder: (sheetCtx, payState) {
                      final loading = payState is PaymentLoading;
                      return Padding(
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 24,
                          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text('Pay & Confirm', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accent)),
                            const SizedBox(height: 8),
                            Text('Order Total (PKR): ${order.totalPrice.toStringAsFixed(2)}'),
                            const SizedBox(height: 4),
                            Text('Converted (USD test): ${usdAmount.toStringAsFixed(2)}'),
                            const SizedBox(height: 16),
                            ElevatedButton(

                              onPressed: loading
                                  ? null
                                  : () async {
                                      paymentCubit.payWithPaymentSheet(
                                        orderId: order.orderId,
                                        tailorId: order.tailorId,
                                        amountMajor: usdAmount,
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: loading
                                  ? Center(child: const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                                  : Center(child: const Text('Open Secure Payment', style: TextStyle(fontWeight: FontWeight.w600))),
                            ),
                            const SizedBox(height: 12),
                            const Text('Test Mode: Use Stripe test cards. A Stripe secure sheet will appear.'),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Pay & Confirm Received', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }


  void _showOrderDetails(OrderModel order, Color accent, bool isInProgress) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: order.status == 12
                            ? Colors.red.withValues(alpha: 0.1)
                            : isInProgress ? accent.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.statusLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: order.status == 12
                              ? Colors.red
                              : isInProgress ? accent : Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Details',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order.orderId,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDetailSection('Tailor ID', order.tailorId, subtitle: 'Items: ${order.itemCount}'),
                    const Divider(height: 32),
                    _buildDetailSection('Order Date', _formatDateLong(order.createdAt)),
                    const SizedBox(height: 16),
                    _buildDetailSection(
                      isInProgress ? 'Created On' : 'Delivered On',
                      _formatDateLong(isInProgress ? order.createdAt : (order.deliveryDate ?? order.updatedAt)),
                    ),
                    const Divider(height: 32),
                    const Text(
                      'Order Items',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...order.orderDetails.asMap().entries.map((entry) {
                      final index = entry.key;
                      final detail = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${index + 1}. ${detail.itemType}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Text(
                                  'PKR ${detail.price}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: accent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.checkroom, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  'Cloth: ${detail.clothType}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            if (detail.description != null && detail.description!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.description, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      detail.description!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Price',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'PKR ${order.totalPrice}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
            },
          );
        },
    );
  }

  Widget _buildDetailSection(String label, String value, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateLong(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'T';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  void _showRiderDetails(String riderId, Color accent, OrderModel order) {

    // Fetch rider details using RiderCubit
    context.read<RiderCubit>().fetchRiderById(riderId);
    // Show rider details modal with BlocBuilder
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return BlocBuilder<RiderCubit, RiderState>(
          builder: (context, state) {
            if (state is RiderLoading) {
              return const Padding(
                padding: EdgeInsets.all(100.0),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD29356)),
                  ),
                ),
              );
            }

            if (state is RiderError) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(modalContext),
                      child: const Text('Close'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }

            if (state is! RiderLoaded) {
              return const SizedBox.shrink();
            }

            final rider = state.rider;

            // Calculate distance and ETA
            double? distanceKm;
            int? etaMinutes;

            if (rider.currentLatitude != null &&
                rider.currentLongitude != null &&
                order.pickupLocation != null) {
              distanceKm = _calculateDistanceKm(
                rider.currentLatitude!,
                rider.currentLongitude!,
                order.pickupLocation!.latitude,
                order.pickupLocation!.longitude
              );
              // Average bike speed in city: 30 km/h
              etaMinutes = ((distanceKm / 30) * 60).ceil();
            }

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    'Ride Details',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Rider Photo and Name
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: accent.withValues(alpha: 0.2),
                          backgroundImage: (rider.photoUrl != null && rider.photoUrl!.isNotEmpty)
                              ? NetworkImage(rider.photoUrl!)
                              : null,
                          child: (rider.photoUrl == null || rider.photoUrl!.isEmpty)
                              ? Icon(Icons.person, size: 50, color: accent)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          rider.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your Rider',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ETA and Distance Information
                  if (distanceKm != null && etaMinutes != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accent.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 24, color: accent),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Estimated Arrival',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$etaMinutes min',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey[300],
                                margin: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Distance',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${distanceKm.toStringAsFixed(1)} km',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Vehicle Information (if available)
                  // if (rider.vehicleNumber != null && rider.vehicleNumber!.isNotEmpty) ...[
                  //   Container(
                  //     padding: const EdgeInsets.all(16),
                  //     decoration: BoxDecoration(
                  //       color: Colors.grey[50],
                  //       borderRadius: BorderRadius.circular(12),
                  //       border: Border.all(color: Colors.grey[200]!),
                  //     ),
                  //     child: Row(
                  //       children: [
                  //         Icon(Icons.motorcycle, size: 30, color: accent),
                  //         const SizedBox(width: 12),
                  //         Expanded(
                  //           child: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Text(
                  //                 'Vehicle Number',
                  //                 style: TextStyle(
                  //                   fontSize: 12,
                  //                   color: Colors.grey[600],
                  //                 ),
                  //               ),
                  //               const SizedBox(height: 4),
                  //               Text(
                  //                 rider.vehicleNumber!,
                  //                 style: const TextStyle(
                  //                   fontSize: 16,
                  //                   fontWeight: FontWeight.bold,
                  //                   color: Colors.black87,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  //   const SizedBox(height: 20),
                  // ],

                  // Action Buttons (Chat and Call)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // Get current customer ID
                            final customerId = context.read<AuthCubit>().currentCustomer?.customerId;
                            if (customerId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please login to chat')),
                              );
                              return;
                            }

                            try {
                              // Start or get existing conversation with rider
                              final conversation = await context.read<ChatCubit>().startConversation(
                                customerId,
                                rider.riderId,
                              );

                              // Navigate to chat screen
                              if (!mounted) return;
                              Navigator.pop(modalContext); // Close rider details modal
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => ChatScreen(conversation: conversation),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to start chat: $e')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.chat),
                          label: const Text(
                            'Chat',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (rider.phoneNumber != null && rider.phoneNumber!.isNotEmpty) {
                              await _makePhoneCall(rider.phoneNumber!);
                            } else {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Phone number not available')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.call),
                          label: const Text(
                            'Call',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Clean the phone number - remove spaces, dashes, parentheses
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    final url = 'tel:$cleanedNumber';

    try {
      final canLaunch = await canLaunchUrlString(url);

      if (canLaunch) {
        await launchUrlString(url);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot make call to $cleanedNumber')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
