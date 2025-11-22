import 'package:flutter/material.dart';
import '../screen/home_page.dart';
import '../screen/profile_page.dart';
import '../screen/orders_page.dart';
import 'package:stichanda_customer/modules/chat/screens/conversations_screen.dart';

class BottomNavScaffold extends StatefulWidget {
  final int initialIndex;
  const BottomNavScaffold({super.key, this.initialIndex = 2});

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  late int _index;
  final Color _accent = const Color(0xFFD29356);

  final List<Widget> _pages = const [
    ConversationsScreen(),
    ProfilePage(),
    HomePage(),
    OrdersPage(),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: _accent,
        unselectedItemColor: Colors.grey[500],
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Orders',
          ),
        ],
        onTap: (i) {
          setState(() {
            _index = i;
          });
        },
      ),
    );
  }
}
