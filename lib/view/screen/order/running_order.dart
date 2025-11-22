import 'package:flutter/material.dart';
import 'package:stichanda_driver/data/models/order_model.dart';
import 'package:stichanda_driver/view/screen/order/widget/history_order.dart';

import '../../../utils/dimension.dart';
import '../../base/custom_app_bar.dart';



// IMPORTANT NOTE: The Active Running Orders are diffderent from the Running Orders Screen
// Active Running Orders are the orders which are currently being delivered by the driver
// Running Orders Screen shows all the orders which are currently in progress (picked up but not yet


class RunningOrderScreen extends StatelessWidget {
  final List<OrderModel> currentorders;
  const RunningOrderScreen({super.key,required this.currentorders});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Running Orders'),
      // body: BlocBuilder<OrderCubit, OrderState>(builder: (context, orderState) {
      //   // final OrderCubit orderCubit = context.read<OrderCubit>();
      //
      //   return orderState.currentOrderList != null
      //       ? orderState.currentOrderList!.isNotEmpty
      //       ? RefreshIndicator(
      //     onRefresh: () async {
      //       await orderCubit.getCurrentOrders();
      //     },
          body: Scrollbar(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                    child: SizedBox(
                      width: 1170,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        // itemCount: orderState.currentOrderList!.length,
                        itemCount: currentorders.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return HistoryOrderWidget(
                              orderModel: currentorders[index],
                              isRunning: true,
                              index: index);
                        },
                      ),
                    )),
              )));

            // : Center(child: Text('no_order_found'.tr))
            // : const Center(child: CircularProgressIndicator());
      }

  }
