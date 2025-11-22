import 'package:flutter/material.dart';
import '../../../../data/models/order_model.dart';


class DriverOrderHeader extends StatelessWidget {
  final OrderModel order;

  const DriverOrderHeader({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Order #${order.orderId}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Chip(
          label: Text(order.statusLabel.toUpperCase()),
          backgroundColor: _statusColor(order.status).withValues(alpha: 0.1),
          labelStyle: TextStyle(color: _statusColor(order.status)),
        ),
      ),
    );
  }

  Color _statusColor(int status) {
    // Status colors based on int status
    // 0-3: Customer to Tailor (orange/blue)
    // 4-5: Tailor processing (purple)
    // 6-10: Tailor to Customer (green/teal)
    if (status == 0 || status == 6) return Colors.orange; // Unassigned
    if (status == 1 || status == 7) return Colors.blue;   // Assigned
    if (status == 2 || status == 8) return Colors.purple; // Picked up
    if (status == 3 || status == 9) return Colors.teal;   // Delivered/Completed
    if (status == 4 || status == 5) return Colors.amber;  // Tailor processing
    if (status == 10) return Colors.green;                // Final completion
    return Colors.grey;
  }
}
