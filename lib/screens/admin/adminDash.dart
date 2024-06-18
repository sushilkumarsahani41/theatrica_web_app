import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sar_web/screens/admin/LibraryPage.dart';
import 'package:sar_web/screens/admin/LogBook.dart';
import 'package:sar_web/screens/admin/dashboardPage.dart';
import 'package:sar_web/screens/admin/leaves_page.dart';
import 'package:sar_web/screens/admin/newOrganisationPage.dart';
import 'package:sar_web/screens/admin/newuserPage.dart';

class AdminHomeView extends StatefulWidget {
  const AdminHomeView({super.key});

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  final List<Widget> _pages = [
    const DashBoardPage(),
    const AdminOrgPage(),
    const AdminUserPage(),
    const LeavesPage(),
    const LibraryPage(),
    const AdminLogBook(),
  ];

  int _selectedIndex = 0;
  final List<String> _menuTitles = [
    "Dashboard",
    "School/Org",
    "User",
    "Leaves",
    "Library",
    "Log Book",
    "Logout",
  ];

  final List<IconData> _menuIcons = [
    Icons.dashboard,
    Icons.domain,
    Icons.person,
    Icons.calendar_month,
    Icons.file_copy,
    Icons.book,
    Icons.exit_to_app,
  ];

  final Color _backgroundColor = Colors.deepPurple.shade100;
  final Color _selectedItemColor = Colors.deepPurple;
  final Color _iconColor = Colors.white;

  void _onItemTapped(int index) async {
    if (index == 6) {
      try {
        await FirebaseAuth.instance.signOut();
        Navigator.popAndPushNamed(context, '/');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to log out: $e'),
        ));
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              backgroundColor: _backgroundColor,
              selectedIconTheme: IconThemeData(color: _iconColor),
              selectedLabelTextStyle: const TextStyle(color: Colors.black),
              unselectedIconTheme: const IconThemeData(color: Colors.black),
              unselectedLabelTextStyle: const TextStyle(color: Colors.black),
              labelType: NavigationRailLabelType.all,
              destinations: List.generate(_menuTitles.length, (index) {
                return NavigationRailDestination(
                  icon: Icon(_menuIcons[index]),
                  selectedIcon: Icon(_menuIcons[index]),
                  label: Text(_menuTitles[index]),
                );
              }),
              indicatorColor: _selectedItemColor,
            ),
            Expanded(
              child: _pages[_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }
}
