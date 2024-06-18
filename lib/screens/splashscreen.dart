import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/logo.png'),
            const SizedBox(height: 20.0),
            const CircularProgressIndicator(color: Colors.deepPurple),
          ],
        ),
      ),
    );
  }

  void _checkAuthentication() {
    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('uid', user.uid);
        bool isAdmin = await _checkAdminStatus(user.uid);
        Navigator.pushReplacementNamed(
            context, isAdmin ? '/admin' : '/UserHome');
      }
    });
  }

  Future<bool> _checkAdminStatus(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> res =
          await _db.collection('users').doc(uid).get();
      if (res.exists && res.data() != null) {
        return res.data()!['admin'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }
}
