import 'package:flutter/material.dart';
import '../screens/umum_home_screen.dart';
import '../screens/my_tickets_screen.dart';
import '../screens/profile_screen.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTabChange;
  static const Color blue = Color(0xFF64B9F2);
  static const Color whiteBox = Color(0xFFE9E9E9);

  const AppBottomNavBar({super.key, required this.currentIndex, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: whiteBox,
      selectedItemColor: blue,
      unselectedItemColor: Colors.black,
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index != currentIndex) onTabChange(index);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.confirmation_num_outlined),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: '',
        ),
      ],
    );
  }
} 