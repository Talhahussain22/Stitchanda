// online_switch.dart

import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../../../../utils/dimension.dart';


class OnlineSwitch extends StatelessWidget {
  final bool isOnline;
  final ValueChanged<bool> onToggle;

  const OnlineSwitch({
    Key? key,
    required this.isOnline,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterSwitch(
      width: 75,
      height: 30,
      valueFontSize: Dimensions.fontSizeExtraSmall,
      showOnOff: true,
      activeText: 'Online',
      inactiveText: 'Offline',
      activeColor: Theme.of(context).primaryColor,
      inactiveColor: Colors.grey,
      value: isOnline,
      onToggle: onToggle,
    );
  }
}