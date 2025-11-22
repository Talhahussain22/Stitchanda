import 'package:flutter/material.dart';

import '../../utils/dimension.dart';
import '../../utils/style.dart';

class CustomButton extends StatelessWidget {
  final Function? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? fontSize;
  final Color? color;
  final IconData? icon;
  final double radius;
  final Gradient? gradient; // optional gradient skin
  const CustomButton({Key? key, this.onPressed, required this.buttonText, this.transparent = false, this.margin,
    this.width, this.height, this.fontSize, this.color, this.icon, this.radius = Dimensions.radiusSmall, this.gradient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;
    final Color resolvedBg = isDisabled
        ? Theme.of(context).disabledColor
        : (transparent ? Colors.transparent : (color ?? Theme.of(context).primaryColor));

    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      backgroundColor: gradient != null ? Colors.transparent : resolvedBg,
      minimumSize: Size(width != null ? width! : 1170, height != null ? height! : 48),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      foregroundColor: transparent ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
    );

    Widget child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,

      children: [
        icon != null ? Icon(icon, color: transparent ? Theme.of(context).primaryColor : Theme.of(context).cardColor) : const SizedBox(),
        SizedBox(width: icon != null ? Dimensions.paddingSizeSmall : 0),
        Text(
          buttonText,
          textAlign: TextAlign.center,
          style: (robotoBold.copyWith(
            color: transparent ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
            fontSize: fontSize ?? Dimensions.fontSizeLarge,
          )),
        ),
      ],
    );

    // Wrap with gradient decoration if provided
    if (gradient != null) {
      child = Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Container(
          alignment: Alignment.center,
          width: width ?? 1170,
          height: height ?? 48,
          child: child,
        ),
      );
    }

    return Padding(
      padding: margin == null ? const EdgeInsets.all(0) : margin!,
      child: TextButton(
        onPressed: onPressed as void Function()?,
        style: flatButtonStyle,
        child: gradient == null
            ? child
            : ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: child,
              ),
      ),
    );
  }
}
