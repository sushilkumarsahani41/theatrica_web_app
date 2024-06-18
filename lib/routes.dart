import 'package:flutter/material.dart';
import 'package:sar_web/screens/admin/adminHome.dart';
import 'package:sar_web/screens/user/home.dart';
import 'package:sar_web/screens/user/loginScreen.dart';
import 'package:sar_web/screens/splashscreen.dart';

class Routes {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/UserHome':
        return MaterialPageRoute(builder: (_) => const UserHomePage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/admin':
        return MaterialPageRoute(builder: (_) => const AdminHomePage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Error: Page not found'),
            ),
          ),
        );
    }
  }
}
