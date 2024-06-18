import 'package:flutter/material.dart';
import 'package:sar_web/screens/user/UserLogBook.dart';
import 'package:sar_web/screens/user/HomePage.dart';
import 'package:sar_web/screens/user/userLeave.dart';
import 'package:sar_web/screens/user/userProfile.dart';

class MobileUserHome extends StatefulWidget {
  const MobileUserHome({super.key});

  @override
  State<MobileUserHome> createState() => _MobileUserHomeState();
}

class _MobileUserHomeState extends State<MobileUserHome> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      // initialIndex: ,
      child: Scaffold(
        // padding: EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 10),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              // border: Border.all(color: Colors.deepPurple.shade200, width: 2),
              boxShadow: [
                BoxShadow(
                    spreadRadius: .5,
                    blurRadius: 20,
                    color: Colors.grey.shade400)
              ],
              color: Colors.deepPurple.shade100,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30), topLeft: Radius.circular(30))),
          // Adjust as needed
          child: const TabBar(
            splashBorderRadius: BorderRadius.all(Radius.circular(20)),
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: TextStyle(color: Colors.white),
            indicator: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.deepPurple,
            ),
            // co
            tabs: [
              Tab(
                icon: Icon(Icons.home),
              ),
              Tab(
                icon: Icon(Icons.book),
              ),
              Tab(icon: Icon(Icons.edit_calendar_outlined)),
              Tab(
                icon: Icon(Icons.person_2_outlined),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AttendancePage(),
            LogBook(),
            UserLeaveScreen(),
            UserProfile(),
          ],
        ),
      ),
    );
  }
}
