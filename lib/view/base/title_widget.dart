import 'package:flutter/material.dart';

import '../../utils/dimension.dart';
import '../../utils/style.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final Function? onTap;
  final int? orderCount;

  const TitleWidget({
    Key? key,
    required this.title,
    this.onTap,
    this.orderCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge),
        ),
        if (onTap != null)
          InkWell(
            onTap: onTap as void Function()?,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (orderCount != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        orderCount.toString(),
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
      ],
    );
  }
}
