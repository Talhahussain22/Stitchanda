import 'package:flutter/material.dart';

import '../../../../data/models/order_model.dart';
import '../../../../helper/date_convertor.dart';
import '../../../../utils/dimension.dart';
import '../../../../utils/style.dart';


class HistoryOrderWidget extends StatelessWidget {
  const HistoryOrderWidget(
      {super.key,
        required this.orderModel,
        required this.isRunning,
        required this.index});
  final OrderModel orderModel;
  final bool isRunning;
  final int index;

  @override
  Widget build(BuildContext context) {



    return Material(
      color: Colors.transparent,
      child: InkWell(
        // onTap: () => Get.toNamed(
        //   RouteHelper.getOrderDetailsRoute(orderModel.id),
        //   arguments: OrderDetailsScreen(
        //       orderId: orderModel.id,
        //       isRunningOrder: isRunning,
        //       orderIndex: index),
        // ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(children: [
            // Enhanced image container
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),

                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                // child: CustomImage(
                //   image: Image.network(),
                //   height:  78,
                //   width: 78,
                //   fit: BoxFit.cover,
                // ),
                child: Icon(Icons.shopping_bag, size: 40, color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with order ID and badges
                  Row(
                    children: [
                      // Removed order id display per requirement
                      const Spacer(),
                      // space for potential future badges
                    ],
                  ),

                  // Store/Category name

                  const SizedBox(height: 8),
                  // Date and time
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          DateConverter.dateTimeStringToDateTime(
                              orderModel.createdAt!),
                          style: robotoRegular.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withValues(alpha: 0.6),
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                      ),
                      // Arrow indicator
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
