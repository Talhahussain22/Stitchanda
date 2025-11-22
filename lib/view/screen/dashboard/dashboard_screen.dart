import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stichanda_driver/controller/authCubit.dart';
import 'package:stichanda_driver/view/screen/order/order_history_screen.dart';
import 'package:stichanda_driver/view/screen/profile/profile_screen.dart';
import 'package:stichanda_driver/view/screen/request/order_request.dart';
import 'package:stichanda_driver/modules/chat/screens/conversations_screen.dart';
import 'package:stichanda_driver/controller/dashboard_index_cubit.dart';
import '../../base/confirmation_dialog.dart';

import '../home/home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }
  final _screens=[
    HomeScreenUI(),
    OrderRequestScreen(),
    ConversationsScreen(),
    const OrderHistoryScreen(),
    const ProfileScreen()
  ];

  Future<void> _onNavTap(int index) async {
    if(index==1){
      final availability = context.read<AuthCubit>().state.profile?.availabilityStatus ?? 0;
      final isassigned = context.read<AuthCubit>().state.profile?.isAssigned ?? 0;

      if(availability!=1 ){
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx)=> ConfirmationDialog(
            icon: Icons.wifi_off_rounded,
            title: 'Offline',
            description: 'You are offline now. You have to go online to view order requests.',
            confirmText: 'OK',
            showCancelButton: false,
            onConfirm: (){},
          ),
        );
        return;
      }

      else if(isassigned==1){
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx)=> ConfirmationDialog(
            icon: Icons.timelapse_rounded,
            title: 'Busy',
            description: 'You are assigned to an order. You cannot view new order requests now.',
            confirmText: 'OK',
            showCancelButton: false,
            onConfirm: (){},
          ),
        );
        return;
      }
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if(!serviceEnabled){
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx)=> ConfirmationDialog(
            icon: Icons.location_off_rounded,
            title: 'Location disabled',
            description: 'Please enable your device location to view order requests.',
            confirmText: 'OK',
            showCancelButton: false,
            onConfirm: (){},
          ),
        );
        return;
      }
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx)=> ConfirmationDialog(
            icon: Icons.my_location_rounded,
            title: 'Permission required',
            description: 'We need location permission to show requests near you.',
            confirmText: 'OK',
            showCancelButton: false,
            onConfirm: (){},
          ),
        );
        return;
      }
    }
    context.read<DashboardIndexCubit>().setIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardIndexCubit, int>(
      builder: (context, selectedIndex) {
        return Scaffold(
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              margin: const EdgeInsets.only(left: 12, right: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withValues(alpha: 0.98),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  onTap: (i){ _onNavTap(i); },
                  type: BottomNavigationBarType.fixed,
                  currentIndex: selectedIndex,
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
                  items: [
                    BottomNavigationBarItem(icon: Icon(Icons.home, color: selectedIndex==0?Theme.of(context).colorScheme.primary:Theme.of(context).hintColor), label: 'Home'),
                    BottomNavigationBarItem(icon: Icon(Icons.list_alt, color: selectedIndex==1?Theme.of(context).colorScheme.primary:Theme.of(context).hintColor), label: 'Orders'),
                    BottomNavigationBarItem(icon: Icon(Icons.chat, color: selectedIndex==2?Theme.of(context).colorScheme.primary:Theme.of(context).hintColor), label: 'Chats'),
                    BottomNavigationBarItem(icon: Icon(Icons.shopping_bag, color: selectedIndex==3?Theme.of(context).colorScheme.primary:Theme.of(context).hintColor), label: 'History'),
                    BottomNavigationBarItem(icon: Icon(Icons.person, color: selectedIndex==4?Theme.of(context).colorScheme.primary:Theme.of(context).hintColor), label: 'Profile'),
                  ],
                ),
              ),
            ),
          ),
          body: _screens[selectedIndex],
        );
      },
    );
  }
}
