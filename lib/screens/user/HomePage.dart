// ignore_for_file: camel_case_types
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding_resolver/geocoding_resolver.dart';
import 'package:intl/intl.dart';
import 'package:sar_web/screens/user/UserLogBook.dart';
import 'package:sar_web/screens/user/PersonalNote.dart';
import 'package:sar_web/screens/user/attendanceHistory.dart';
import 'package:sar_web/screens/user/userlibrary.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sar_web/widgets/btn.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  bool _clockInStatus = false;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _upTime = '';
  late Timer _timer;
  late String _uid;
  List<String> pagetitles = [
    "Library",
    "Notes",
    "Log Book",
    "Attendance History",
  ];

  List<StatefulWidget> pages = [
    const UserLibrary(),
    const PersonalNote(),
    const LogBook(),
    const AttendanceHistory(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _getUpTime();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.deepPurple,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          spreadRadius: .2,
                          blurRadius: 55,
                          color: _clockInStatus
                              ? Colors.lightGreen.shade100
                              : Colors.deepPurple.shade100)
                    ],
                    borderRadius: BorderRadius.circular(30),
                    color: _clockInStatus
                        ? Colors.lightGreen.shade300
                        : Colors.deepPurple.shade100),
                child: _clockInStatus ? _ClockOut() : _ClockIn(),
              ),
              const SizedBox(height: 30),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.follow_the_signs),
                  SizedBox(width: 10),
                  Text("Navigate"),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                  child: ListView.builder(
                      itemCount: pages.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => pages[index]));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: Container(
                              height: 60,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 4,
                                      spreadRadius: 2,
                                      color: Colors.grey.shade400,
                                      offset: const Offset(3, 2))
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    pagetitles[index],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Icon(Icons.arrow_circle_right_outlined)
                                ],
                              ),
                            ),
                          ),
                        );
                      })),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _uid = prefs.getString('uid') ?? '';
    _getClockInStatus();
    _getUpTime();
  }

  Future<void> _getClockInStatus() async {
    var res = await _db.collection('users').doc(_uid).get();
    if (res.exists) {
      var data = res.data()!;
      setState(() {
        _clockInStatus = data['clock-in-status'] ?? false;
      });
    }
  }

  void _getUpTime() async {
    try {
      var res = await _db.collection('users').doc(_uid).get();
      if (res.exists) {
        var data = res.data()!;
        String lastClockIn = data['last-clock-in-id'];
        var time = await _db
            .collection('users')
            .doc(_uid)
            .collection('attendance')
            .doc(lastClockIn)
            .get();
        if (time.exists) {
          var timeStamp = time.data()!['clock-in-time'] as Timestamp;
          var currentTimeStamp = Timestamp.now();
          DateTime previousDateTime = timeStamp.toDate();
          DateTime currentDateTime = currentTimeStamp.toDate();
          Duration difference = currentDateTime.difference(previousDateTime);
          setState(() {
            _upTime = _formatDuration(difference);
          });
        }
      }
    } catch (e) {
      print('Error fetching up time: $e');
    }
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')} : ${minutes.toString().padLeft(2, '0')}';
  }

  String _timeStampToDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('dd, MMM yyyy').format(date);
  }

  Widget _ClockIn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const Text("Clock In from",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black54)),
        Text(_upTime.isEmpty ? "-- : --" : _upTime,
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ButtonAll(
          buttonText: const Text("Clock-In",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          onPressed: _onClockIn,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _ClockOut() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const Text("Clock In from",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black54)),
        Text(_upTime,
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ButtonAll(
          buttonText: const Text("Clock-Out",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          onPressed: () => _showFeedbackDialog(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showFeedbackDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How was your day?'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _feedbackButton(Colors.red, "Bad"),
            _feedbackButton(Colors.yellow, "Good"),
            _feedbackButton(Colors.green, "Excited"),
          ],
        ),
      ),
    );
  }

  Widget _feedbackButton(Color color, String mood) {
    return GestureDetector(
      onTap: () {
        _onClockOut(mood); // Pass the mood to the clock-out function
        Navigator.of(context).pop(); // Close the dialog after selection
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Center(child: Text(mood)),
      ),
    );
  }

  Future<void> _onClockIn() async {
    var location = await getLocation();
    var userRef = _db.collection('users').doc(_uid);
    var upDate = await userRef.collection('attendance').add({
      'clock-in-location': location,
      'clock-in-time': FieldValue.serverTimestamp()
    });
    await userRef.set({'clock-in-status': true, 'last-clock-in-id': upDate.id},
        SetOptions(merge: true));
    setState(() {
      _getUpTime();
      _clockInStatus = true;
    });
    // Show Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You have successfully clocked in!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _onClockOut(String mood) async {
    var location = await getLocation();
    var userRef = _db.collection('users').doc(_uid);
    DocumentSnapshot<Map<String, dynamic>> res = await userRef.get();
    if (res.exists) {
      Map<String, dynamic> data = res.data()!;
      String lastClockIn = data['last-clock-in-id'];
      var time = await userRef.collection('attendance').doc(lastClockIn).get();
      var timeStamp = time.data()!['clock-in-time'] as Timestamp;
      var currentTimeStamp = Timestamp.now();
      DateTime previousDateTime = timeStamp.toDate();
      DateTime currentDateTime = currentTimeStamp.toDate();
      Duration difference = currentDateTime.difference(previousDateTime);
      String formattedDifference = _formatDuration(difference);
      await userRef.collection('attendance').doc(lastClockIn).set({
        'clock-out-location': location,
        'clock-out-time': FieldValue.serverTimestamp(),
        'upTime': formattedDifference,
        'mood': mood,
      }, SetOptions(merge: true));
      await userRef.set({'clock-in-status': false, 'last-clock-in-id': ""},
          SetOptions(merge: true));
      setState(() {
        _clockInStatus = false;
        _getUpTime();
        _upTime = '';
      });
      // Show Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have successfully clocked out!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

// Future<void> _captureAndUploadImage() async {
//   final ImagePicker _picker = ImagePicker();
//   // Capture an image
//   final XFile? image = await _picker.pickImage(source: ImageSource.camera);
//   if (image != null) {
//     // Get a reference to the Firebase Storage
//     final storageRef = FirebaseStorage.instance.ref().child('userImages/${DateTime.now().toIso8601String()}.jpg');
//     // Upload the file
//     try {
//       await storageRef.putBlob(await image.readAsBytes());
//       String downloadUrl = await storageRef.getDownloadURL();
//       print("Image uploaded. URL: $downloadUrl");
//       // You can now store this URL in Firestore or do something else with it
//     } catch (e) {
//       print("Error uploading image: $e");
//     }
//   } else {
//     print("No image captured.");
//   }
// }

  Future<Geoposition?> getCurrentLocation() async {
    if (!isGeolocationSupported()) {
      return null;
    }

    try {
      var position = await window.navigator.geolocation
          .getCurrentPosition(enableHighAccuracy: true);
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Future<Map<String, Object>?> getLocation() async {
    var position = await getCurrentLocation();
    if (position != null) {
      GeoCoder geoCoder = GeoCoder();
      Address address = await geoCoder.getAddressFromLatLng(
          latitude: position.coords!.latitude!.toDouble(),
          longitude: position.coords!.longitude!.toDouble());
      var googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=${position.coords!.latitude!.toDouble()},${position.coords!.longitude!.toDouble()}';
      var res = {
        "latitude": position.coords!.latitude!.toDouble(),
        "longitude": position.coords!.longitude!.toDouble(),
        "address": address.displayName,
        "url": googleMapsUrl,
      };
      return res;
    } else {
      print('Failed to get location.');
      return null;
    }
  }

  bool isGeolocationSupported() => window.navigator.geolocation != null;
}
