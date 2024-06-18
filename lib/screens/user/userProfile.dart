import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sar_web/widgets/btn.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool dataFetched = false;
  late Map<String, dynamic> userData;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.deepPurple,
      body: dataFetched
          ? Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 80,
                      child: Image.asset(
                        userData['gender'] == 'male'
                            ? 'assets/male.png'
                            : 'assets/female.png',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Hello, ${userData['name']}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ButtonAll(
                      onPressed: () {
                        // Implement change password functionality here
                      },
                      buttonText: const Text(
                        "Change Password",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.popAndPushNamed(context, '/');
                      },
                      child: const Text(
                        "Log Out",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    if (uid == null) {
      // Handle case where UID is not found
      Navigator.popAndPushNamed(context, '/login');
      return;
    }

    try {
      var res = await db.collection('users').doc(uid).get();
      var data = res.data();
      if (data != null) {
        setState(() {
          dataFetched = true;
          userData = data;
        });
      } else {
        // Handle case where no user data is available
      }
    } catch (e) {
      // Handle errors like permissions, network issues, etc.
      print("Error fetching user data: $e");
    }
  }
}
