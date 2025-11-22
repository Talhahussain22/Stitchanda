import 'package:flutter/material.dart';
import '../../../../data/models/order_model.dart';


class DriverOrderStatusButton extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onUpdateStatus;

  const DriverOrderStatusButton({
    super.key,
    required this.order,
    required this.onUpdateStatus,
  });

  int? getNextStatus(int current) {
    // Driver-side progression only
    // 1 -> 2 -> 3 and 7 -> 8 -> 9
    switch (current) {
      case 1: return 2;
      case 2: return 3;
      case 7: return 8;
      case 8: return 9;
      default: return null; // 3 and 9 are terminal for driver
    }
  }

  String getButtonText(int nextStatus) {
    switch (nextStatus) {
      case 2: return 'Mark as Picked Up';
      case 3: return 'Complete Delivery to Tailor';
      case 8: return 'Mark as Picked Up from Tailor';
      case 9: return 'Complete Delivery to Customer';
      default: return 'Update Status';
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextStatus = getNextStatus(order.status);
    if (order.status == 9) {
      return Container(
        padding: const EdgeInsets.all(12),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: null,
          child: const Text('Waiting for customer confirmation'),
        ),
      );
    }
    if (nextStatus == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: onUpdateStatus,
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14)),
        child: Text(getButtonText(nextStatus).toUpperCase()),
      ),
    );
  }
}
