import 'package:flutter/material.dart';

import '../../utils/dimension.dart';
import '../../utils/style.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isBackButtonExist;
  final Function? onBackPressed;
  final Widget? actionWidget;
  const CustomAppBar({Key? key, required this.title, this.isBackButtonExist = true, this.onBackPressed, this.actionWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).appBarTheme.titleTextStyle?.color ?? Theme.of(context).colorScheme.onSurface)),
      centerTitle: true,
      leading: isBackButtonExist ? IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: Theme.of(context).appBarTheme.foregroundColor,
        onPressed: (){
          if(onBackPressed != null){
            onBackPressed!();
          }else if(Navigator.canPop(context)){
            Navigator.pop(context);
          }else{
            // Navigator.pushReplacementNamed(context, '/');
          }
        } ,
      ) : const SizedBox(),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      surfaceTintColor: Theme.of(context).appBarTheme.surfaceTintColor,
      elevation: Theme.of(context).appBarTheme.elevation,
      shadowColor: Theme.of(context).appBarTheme.shadowColor,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
          child: actionWidget ?? const SizedBox(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
