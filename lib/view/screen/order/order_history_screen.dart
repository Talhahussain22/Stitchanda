import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stichanda_driver/controller/OrderCubit.dart';
import 'package:stichanda_driver/view/base/order_shimmer.dart';
import 'package:stichanda_driver/view/base/order_widget.dart';
import 'order_details.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Stream live history (status 3 and 9)
    context.read<OrderCubit>().subscribeToHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: OrderShimmer(isEnabled: true),
            );
          }
          final orders = state.orders;
          if (orders.isEmpty) {
            return const Center(child: Text('No completed orders yet'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemBuilder: (ctx, i) {
              final o = orders[i];
              return OrderWidget(
                order: o,
                isRunningOrder: false,
                onDetailsPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DriverOrderDetailsScreen(orderId: o.orderId),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: orders.length,
          );
        },
      ),
    );
  }
}

