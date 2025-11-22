// home_screen_ui.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stichanda_driver/view/base/order_widget.dart';

import 'package:stichanda_driver/view/screen/home/widget/count_card.dart';
import 'package:stichanda_driver/view/screen/home/widget/homepage_appbar.dart';

import '../../../controller/OrderCubit.dart';
import '../../../utils/dimension.dart';
import '../../../utils/style.dart';
import '../../base/order_shimmer.dart';
import '../../base/title_widget.dart';

class HomeScreenUI extends StatefulWidget {
  // Data for the screen

  HomeScreenUI({Key? key}) : super(key: key);

  @override
  State<HomeScreenUI> createState() => _HomeScreenUIState();
}

class _HomeScreenUIState extends State<HomeScreenUI> {

  @override
  void initState() {
    super.initState();
    // subscribe to current order in realtime

    context.read<OrderCubit>().subscribeToCurrentOrder();
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        final bool hasActiveOrder = state.currentOrder != null;

        return Scaffold(
          appBar: HomepageAppBar(),
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Orders Section
                if (hasActiveOrder) Text('Active Order', style: robotoMedium),

                if (state.isLoading || hasActiveOrder)
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                if (state.isLoading)
                  const OrderShimmer(isEnabled: true)
                else if (hasActiveOrder)
                  OrderWidget(order: state.currentOrder!, isRunningOrder: true),

                if (state.isLoading || hasActiveOrder)
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                // Orders Count Section
                const TitleWidget(title: 'Orders'),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Row(
                  children: [
                    Expanded(
                      child: CountCard(
                        title: 'Today\'s Orders',
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        height: 150,
                        value: state.todaysOrderCount.toString(),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Expanded(
                      child: CountCard(
                        title: 'Week\'s Orders',
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        height: 150,
                        value: state.weeklyOrderCount.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                CountCard(
                  title: 'Total Orders',
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  height: 135,
                  value: state.totalOrderCount.toString(),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Cash In Hand Section
              ],
            ),
          ),
        );
      },
    );
  }
}
