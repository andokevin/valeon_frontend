import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import 'home_screen.dart';
import 'scan_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // ✅ CORRIGÉ : Passer le callback onNavigate au HomeScreen
          HomeScreenContent(
            onNavigate: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          const ScanScreenContent(),
          const LibraryScreenContent(),
          const ProfileScreenContent(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
