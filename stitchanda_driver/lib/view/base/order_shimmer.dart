import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../utils/dimension.dart';

class OrderShimmer extends StatelessWidget {
  final bool isEnabled;
  const OrderShimmer({Key? key, required this.isEnabled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey[300]!;
    final highlight = Colors.grey[100]!;
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        interval: const Duration(milliseconds: 250),
        colorOpacity: 0.1,
        color: baseColor,
        enabled: isEnabled,
        child: Column(children: [

          Row(children: [
            Container(height: 16, width: 110, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(6))),
            const Expanded(child: SizedBox()),
            Container(width: 8, height: 8, decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle)),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Container(height: 16, width: 80, decoration: BoxDecoration(color: highlight, borderRadius: BorderRadius.circular(6))),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Expanded(child: Container(height: 16, decoration: BoxDecoration(color: highlight, borderRadius: BorderRadius.circular(6)))),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
            const Icon(Icons.location_on, size: 20),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Expanded(child: Container(height: 16, decoration: BoxDecoration(color: highlight, borderRadius: BorderRadius.circular(6)))),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Row(children: [
            Expanded(child: Container(height: 48, decoration: BoxDecoration(color: highlight, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: Container(height: 48, decoration: BoxDecoration(color: highlight, borderRadius: BorderRadius.circular(10)))),
          ]),
        ]),
      ),
    );
  }
}
