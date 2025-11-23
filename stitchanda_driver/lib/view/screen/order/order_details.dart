import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:stichanda_driver/controller/OrderCubit.dart';
import 'package:stichanda_driver/modules/chat/cubit/chat_cubit.dart';
import 'package:stichanda_driver/modules/chat/screens/chat_screen.dart';
import 'package:stichanda_driver/data/models/order_model.dart';

class DriverOrderDetailsScreen extends StatefulWidget {
  final String orderId;
  const DriverOrderDetailsScreen({super.key, required this.orderId});

  @override
  State<DriverOrderDetailsScreen> createState() =>
      _DriverOrderDetailsScreenState();
}

class _DriverOrderDetailsScreenState extends State<DriverOrderDetailsScreen> {

  @override
  void initState() {
    context.read<OrderCubit>().loadOrderById(widget.orderId);
    super.initState();
  }
  void _onAdvanceStatus(OrderModel order) async {
    final orderCubit = context.read<OrderCubit>();
    final next = _nextStatus(order.status);
    if (next == null) return;

    // Check if this is a completion status (3, 9, or 10)
    if (next == 3 || next == 9 || next == 10) {
      await orderCubit.completeSelectedOrder(next);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order marked as ${order.copyWith(status: next).statusLabel}'))
      );
      Navigator.of(context).pop(true);


    } else {
      orderCubit.updateOrderStatus(order.orderId, next);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order marked as ${order.copyWith(status: next).statusLabel}'))
      );
    }
  }

  int? _nextStatus(int currentStatus) {

    switch (currentStatus) {
      case 1: return 2; // Assigned → Picked up from Customer
      case 2: return 3; // Picked up → Delivered to Tailor (driver completes first leg)
      case 7: return 8; // Assigned to Rider → Picked up from Tailor
      case 8: return 9; // Picked up from Tailor → Delivered to Customer (driver completes second leg)
      default: return null; // 3 and 9 (and others) have no driver action
    }
  }

  Future<void> _openDirections(double lat, double lng) async {

    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&mode=d';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch: $url')));
    }
  }

  Future<void> _call(String number) async {
    if (number.isEmpty) return;

    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {

      await launchUrl(uri, mode: LaunchMode.externalApplication,);
    }
  }

  Future<void> _startChat(String otherUserId) async {
    final me = FirebaseAuth.instance.currentUser?.uid;
    if (me == null || otherUserId.isEmpty) return;
    final cubit = context.read<ChatCubit>();
    final conv = await cubit.startConversation(me, otherUserId);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)),
    );
  }

  Widget _sectionCard({required Widget child, Widget? trailing}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            child,
            if (trailing != null) Positioned(top: 0, right: 0, child: trailing),
          ],
        ),
      ),
    );
  }

  Widget _basicInfo(OrderModel o) {

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Order #${o.orderId}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              o.statusLabel,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

  }

  Widget _contactRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(radius: 16, child: Icon(icon, size: 18)),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(value.isEmpty ? '-' : value),
      onTap: onTap,
    );
  }

  Widget _personCard(OrderModel o, {required bool isSender}) {

    final person = isSender ? o.sender : o.receiver;
    final addr = isSender ? o.currentPickupLocation : o.currentDropoffLocation;
    final personId = isSender
        ? (o.status >= 0 && o.status <= 3 ? o.customerId : o.tailorId ?? '')
        : (o.status >= 0 && o.status <= 3 ? o.tailorId ?? '' : o.customerId);

    final lat = double.tryParse(addr.latitude);
    final lng = double.tryParse(addr.longitude);

    return _sectionCard(
      trailing:
          (lat != null && lng != null)
              ? IconButton(
                tooltip: 'Directions',
                icon: Icon(Icons.directions, color: Theme.of(context).primaryColor),
                onPressed: () => _openDirections(lat, lng),
              )
              : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSender ? Icons.person_outline : Icons.location_on,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isSender ? 'Pickup From' : 'Deliver To',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _contactRow(
            icon: Icons.person,
            label: 'Name',
            value: person?.name ?? '-',
          ),
          _contactRow(
            icon: Icons.location_on,
            label: 'Address',
            value: addr.location,
          ),
          _contactRow(
            icon: Icons.phone,
            label: 'Phone',
            value: person?.phone ?? '-',
            onTap: () => _call(person?.phone ?? ''),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.call),
                  label: const Text('Call'),
                  onPressed:
                      (person?.phone ?? '').isEmpty
                          ? null
                          : () => _call(person?.phone ?? ''),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat'),
                  onPressed: personId.isEmpty ? null : () => _startChat(personId),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        final isLoading = state.isLoading && (state.selectedOrder == null);
        final selected = state.selectedOrder;
        final canUpdate =
            selected != null && _nextStatus(selected.status) != null;

        return Scaffold(
          appBar: AppBar(title: const Text('Order Details')),
          body:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : selected == null
                  ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 240),
                      Center(child: Text('No order found')),
                    ],
                  )
                  : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _basicInfo(selected),
                              _personCard(selected, isSender: true),
                              _personCard(selected, isSender: false),
                            ],
                          ),
                        ),
                      ),
                      if (canUpdate)
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _onAdvanceStatus(selected),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: Text(
                                  _getButtonText(selected.status),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
        );
      },
    );
  }

  String _getButtonText(int status) {
    final next = _nextStatus(status);
    if (status == 9) return 'Waiting for customer confirmation';
    if (status == 3) return 'Completed';
    if (next == null) return 'No Action Available';

    switch (next) {
      case 2: return 'Mark as Picked Up';
      case 3: return 'Complete Delivery to Tailor';
      case 8: return 'Mark as Picked Up from Tailor';
      case 9: return 'Complete Delivery to Customer';
      default: return 'Update Status';
    }
  }
}
