import 'package:flutter/material.dart';
import '../app/router.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0: Navigator.pushNamed(context, AppRoutes.map); break;
          case 1: Navigator.pushNamed(context, AppRoutes.exhibits); break;
          case 2: Navigator.pushNamed(context, AppRoutes.chat); break;
          case 3: Navigator.pushNamed(context, AppRoutes.quiz); break;
          case 4: Navigator.pushNamed(context, AppRoutes.settings); break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
        BottomNavigationBarItem(icon: Icon(Icons.museum), label: "Exhibits"),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: "Quiz"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}
