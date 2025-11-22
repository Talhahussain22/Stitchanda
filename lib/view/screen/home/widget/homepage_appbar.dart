import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../controller/authCubit.dart';
import '../../../../utils/dimension.dart';
import '../../../../utils/style.dart';

class HomepageAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size(1170, 56);

  const HomepageAppBar({super.key});

  @override
  State<HomepageAppBar> createState() => _HomepageAppBarState();
}

class _HomepageAppBarState extends State<HomepageAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).cardColor,
      centerTitle: true,
      elevation: 0,
      title: Text(
        'Stichanda Driver',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: robotoBold.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: Dimensions.fontSizeExtraLarge,
          letterSpacing: 0.4,
        ),
      ),
      actions: [
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isActive = (state.profile?.availabilityStatus ?? 0) == 1;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: FlutterSwitch(
                width: 72,
                height: 30,
                valueFontSize: Dimensions.fontSizeExtraSmall,
                showOnOff: true,
                activeText: 'online',
                inactiveText: 'offline',
                activeColor: Colors.green,
                inactiveColor: Colors.grey,
                value: isActive,
                onToggle: (bool value) async {
                  if (state.isLoading) return;
                  final authCubit = context.read<AuthCubit>();
                  final newStatus = value ? 1 : 0;
                  final ok = await authCubit.updateActiveStatus(newStatus);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? (newStatus == 1 ? "You're now ONLINE" : "You're now OFFLINE")
                            : 'Could not update availability. Please try again.',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
