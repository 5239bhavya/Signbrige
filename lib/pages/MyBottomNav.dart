import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int)? onTap;

  const MyBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int safeIndex = currentIndex.clamp(0, 3);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: Colors.teal.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.teal[800],
            unselectedItemColor: const Color(0xFF64748B),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            showUnselectedLabels: true,
            currentIndex: safeIndex,
            onTap: (index) async {
              if (index == safeIndex) return;
              await HapticFeedback.selectionClick();
              if (!context.mounted) return;

              if (onTap != null) {
                onTap!(index);
              } else {
                switch (index) {
                  case 0:
                    Navigator.pushReplacementNamed(context, '/home');
                    break;
                  case 1:
                    Navigator.pushReplacementNamed(context, '/youtube');
                    break;
                  case 2:
                    Navigator.pushReplacementNamed(context, '/dictionary');
                    break;
                  case 3:
                    Navigator.pushReplacementNamed(context, '/user');
                    break;
                }
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home, size: 28),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.ondemand_video_outlined),
                activeIcon: Icon(Icons.ondemand_video, size: 28),
                label: "YouTube",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book, size: 28),
                label: "Dictionary",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person, size: 28),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  static int getCurrentIndex(String? routeName) {
    switch (routeName) {
      case '/home':
        return 0;
      case '/youtube':
        return 1;
      case '/dictionary':
        return 2;
      case '/user':
        return 3;
      default:
        return 0;
    }
  }
}
