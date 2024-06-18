import 'package:flutter/material.dart';
import 'package:sar_web/screens/admin/adminDash.dart';
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return const AdminHomeView();
        }
        return const Center(
          child: Text("Please Browse From Desktop"),
        );
      },
    ));
  }
}
