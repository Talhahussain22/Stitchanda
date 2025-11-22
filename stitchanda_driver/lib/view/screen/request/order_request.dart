import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stichanda_driver/controller/dashboard_index_cubit.dart';
import 'package:stichanda_driver/view/screen/request/widget/order_request_widget.dart';

import '../../../controller/OrderCubit.dart';
import '../../../controller/authCubit.dart';

class OrderRequestScreen extends StatefulWidget {
  const OrderRequestScreen({super.key});

  @override
  State<OrderRequestScreen> createState() => _OrderRequestScreenState();
}

class _OrderRequestScreenState extends State<OrderRequestScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final profile = context.read<AuthCubit>().state.profile;
      final lat = profile?.currentLocation.latitude;
      final lng = profile?.currentLocation.longitude;
      context.read<OrderCubit>().subscribeToUnassignedOrders(
            currentLat: lat,
            currentLng: lng,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderCubit, OrderState>(
      listener: (ctx, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          if (!mounted) return;
          _scaffoldKey.currentState?.showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (ctx, state) {
        if (state.isLoading && state.orders.isEmpty) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (state.orders.isEmpty) {
          return const Scaffold(body: Center(child: Text("No order requests available")));
        }
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: const Text('Order Requests'),
            centerTitle: true,
          ),
          body: ListView.builder(
            itemCount: state.orders.length,
            padding: const EdgeInsets.all(12),
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (itemCtx, index) {
              final order = state.orders[index];
              return OrderRequestWidget(
                order: order,
                onAccept: () async {
                  // Use the screen's context instead of itemCtx to avoid deactivated context after await
                  final orderCubit = context.read<OrderCubit>();
                  final dashboardCubit = context.read<DashboardIndexCubit>();

                  if (state.currentOrder != null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'You already have an active order. Please complete it before accepting a new one.',
                        ),
                      ),
                    );
                    return;
                  }

                  final success = await orderCubit.acceptOrder(order.orderId);
                  if (!mounted) return;
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order accepted successfully.')),
                    );
                    dashboardCubit.setIndex(0);
                    if (!mounted) return;
                    // Safely pop using the screen context
                    await Navigator.maybePop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order was already accepted by someone else.')),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
