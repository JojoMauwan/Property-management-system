import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import '../configs/colors.dart';
import 'add_property_screen.dart';
import 'dashboard.dart';
import 'property_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = const [
    Dashboard(),
    PropertyListScreen(),
    AddPropertyScreen(),
  ];

  final List<String> screenTitles = const [
    'Dashboard',
    'Property List',
    'Add Property',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitles[selectedIndex]),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: screens[selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: selectedIndex,
        height: 60,
        backgroundColor: AppColors.backgroundColor,
        color: AppColors.primaryColor,
        buttonBackgroundColor: AppColors.primaryColor,
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(Icons.dashboard, size: 28, color: Colors.white),
          Icon(Icons.list_alt, size: 28, color: Colors.white),
          Icon(Icons.add_home, size: 28, color: Colors.white),
          Icon(Icons.settings, size: 28, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
