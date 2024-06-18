import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:sar_web/screens/splashscreen.dart';
import 'package:sar_web/widgets/btn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool passVisible = true;
  String uid = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent.shade100.withOpacity(0.1),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    spreadRadius: .5,
                    blurRadius: 30,
                    color: Colors.grey.shade400,
                  )
                ],
              ),
              width: 350,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.deepPurple,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 30.0,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    controller: _email,
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  TextField(
                    controller: _pass,
                    obscureText: passVisible,
                    onSubmitted: (pass) => _loginFunc(_email.text, pass),
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      suffixIcon: IconButton(
                        icon: Icon(passVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () {
                          setState(() {
                            passVisible = !passVisible;
                          });
                        },
                      ),
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    height: 50,
                    child: ButtonAll(
                      onPressed: () => _loginFunc(_email.text, _pass.text),
                      buttonText: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _loginFunc(String email, String pass) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      if (credential.user != null) {
        uid = credential.user!.uid;
        pref.setString("uid", uid);
        // SplashScreen.uid = uid;
        bool admin = await isAdmin(uid);
        print("Login Successfull");
        if (admin) {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/UserHome');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<bool> isAdmin(uid) async {
    var res = await db.collection('users').doc(uid).get();
    if (res.exists) {
      var data = res.data();
      return data?['admin'] ?? false;
    }
    return false;
  }
}
