// earning_widget.dart

import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';


import '../../../../utils/dimension.dart';
import '../../../../utils/style.dart';

class EarningWidget extends StatelessWidget {
  final String title;
  final String? amountText; // Changed from double? to String? for reusability

  const EarningWidget({
    Key? key,
    required this.title,
    required this.amountText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).cardColor,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          amountText != null
              ? Text(
            amountText!, // Display the pre-formatted text directly
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeExtraLarge,
              color: Theme.of(context).cardColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
              : Shimmer(
            duration: const Duration(seconds: 2),
            enabled: amountText == null,
            color: Colors.grey[500]!,
            child: Container(
              height: 20,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
            ),
          ),
        ],
      ),
    );
  }
}