import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import '../../controller/payment_cubit.dart';
import '../../controller/order_cubit.dart';
import '../../controller/auth_cubit.dart';
import '../../data/models/order_model.dart';

class PaymentPage extends StatefulWidget {
  final OrderModel order;
  final Color accent;
  const PaymentPage({super.key, required this.order, required this.accent});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _cardComplete = false; // track CardField completion

  Future<void> _showSuccessDialogAndPop() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Payment Successful'),
        content: const Text('Your payment was processed and the order is confirmed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  double _pkrToUsd(double pkr) {
    // Basic rough conversion for test mode purposes only
    const rate = 280.0; // keep aligned with previous logic
    return pkr / rate;
  }

  @override
  Widget build(BuildContext context) {
    final paymentCubit = context.read<PaymentCubit>();
    // Avoid resetting state on every build; caller can reset explicitly
    final order = widget.order;
    final accent = widget.accent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: SafeArea(
        child: BlocConsumer<PaymentCubit, PaymentState>(
          listener: (context, state) async {
            if (state is PaymentSuccess) {
              final customerId = context.read<AuthCubit>().currentCustomer?.customerId;
              if (customerId != null) {
                await context.read<OrderCubit>().finalizePayment(customerId, order.orderId);
              }
              if (mounted) {
                await _showSuccessDialogAndPop();
              }
            } else if (state is PaymentFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            final loading = state is PaymentLoading;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Order Total (PKR): ${order.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Secure Card Input', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        stripe.CardField(
                          autofocus: true,
                          onCardChanged: (details) {
                            setState(() {
                              _cardComplete = details?.complete == true;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _cardComplete
                              ? 'Card details complete'
                              : 'Enter full card details (test cards only)',
                          style: TextStyle(
                            fontSize: 12,
                            color: _cardComplete ? Colors.green : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: (!_cardComplete || loading)
                        ? null
                        : () async {
                            // Stripe test mode: convert PKR to USD for test PaymentIntent
                            final usdAmount = _pkrToUsd(order.totalPrice);
                            paymentCubit.payWithSdkCard(
                              orderId: order.orderId,
                              tailorId: order.tailorId,
                              amountMajor: usdAmount,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Pay Now', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Test Mode: Use Stripe test cards like 4242 4242 4242 4242. Real cards will not work.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
