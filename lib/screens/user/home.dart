import 'package:flutter/material.dart';
import 'package:sar_web/screens/user/mobileUserHome.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 600) {
          return const MobileUserHome();
        }
        return const Center(
          child: Text("Please Browse From Mobile"),
        );
      },
    ));
  }
}
