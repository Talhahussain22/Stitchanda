// count_card.dart

import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../../utils/dimension.dart';
import '../../../../utils/style.dart';

class CountCard extends StatelessWidget {
  final Color backgroundColor; // treated as accent color
  final String title;
  final String? value;
  final double height;

  const CountCard({
    Key? key,
    required this.backgroundColor,
    required this.title,
    required this.value,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accent = backgroundColor;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 4,
            width: 32,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          value != null
              ? AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: robotoBlack.copyWith(fontSize: 32, color: accent),
                  child: Text(
                    value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : Shimmer(
                  duration: const Duration(seconds: 2),
                  enabled: value == null,
                  color: Colors.grey[500]!,
                  child: Container(
                    height: 36,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                  ),
                ),
          const SizedBox(height: 6),
          Text(
            title,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}